import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/supabase_client.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';
import '../models/chat_message.dart';
import '../repositories/supabase_chat_repository.dart';

final chatRepositoryProvider = Provider<SupabaseChatRepository>((ref) {
  return const SupabaseChatRepository();
});

/// Tracks which event chats are currently being viewed so their unread
/// badges show 0 while the user is reading live.
final activeChatEventIdsProvider =
    StateProvider<Set<String>>((ref) => const <String>{});

/// Async family notifier for one event's chat. Owns:
///   * the realtime stream of messages (via .stream() — reliable delivery),
///   * the sender-name cache (so bubbles show real names even though
///     .stream() can't do joins),
///   * the optimistic outbound queue (sending → sent | failed).
class ChatController
    extends AutoDisposeFamilyAsyncNotifier<List<ChatMessage>, String> {
  String? _channelId;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  final Map<String, String> _nameCache = <String, String>{};
  final Map<String, ChatMessage> _pending = <String, ChatMessage>{};
  List<Map<String, dynamic>> _lastServerRows = const <Map<String, dynamic>>[];

  SupabaseChatRepository get _repo => ref.read(chatRepositoryProvider);
  SupabaseClient get _c => SupabaseService.client;

  @override
  Future<List<ChatMessage>> build(String eventId) async {
    // Register this chat as "actively viewed" so its unread badge shows 0.
    // Riverpod forbids mutating another provider during a build, so both
    // the add and the dispose-time remove are deferred to a microtask.
    Future<void>.microtask(() {
      final StateController<Set<String>> notifier =
          ref.read(activeChatEventIdsProvider.notifier);
      notifier.state = <String>{...notifier.state, eventId};
    });
    ref.onDispose(() {
      Future<void>.microtask(() {
        try {
          final StateController<Set<String>> notifier =
              ref.read(activeChatEventIdsProvider.notifier);
          notifier.state = <String>{...notifier.state}..remove(eventId);
        } catch (_) {
          // Container already torn down (app exit) — safe to ignore.
        }
      });
    });

    _channelId = await _repo.ensureChannelForEvent(eventId);
    _nameCache.addAll(await _repo.fetchChannelMemberNames(_channelId!));

    final Completer<List<ChatMessage>> firstEmission =
        Completer<List<ChatMessage>>();

    _sub = _repo.streamMessages(_channelId!).listen(
      (rows) async {
        _lastServerRows = rows;
        // Enrich any sender we don't yet know about (new joiners, host).
        final Set<String> unknown = <String>{};
        for (final Map<String, dynamic> row in rows) {
          final String? sid = row['sender_id'] as String?;
          if (sid != null && !_nameCache.containsKey(sid)) unknown.add(sid);
        }
        if (unknown.isNotEmpty) {
          _nameCache.addAll(await _repo.fetchProfileNames(unknown));
        }
        final List<ChatMessage> merged = _mergeState();
        if (!firstEmission.isCompleted) {
          firstEmission.complete(merged);
        } else {
          state = AsyncData(merged);
        }
      },
      onError: (Object e) {
        if (!firstEmission.isCompleted) firstEmission.completeError(e);
      },
    );

    ref.onDispose(() {
      _sub?.cancel();
      _sub = null;
    });

    return firstEmission.future;
  }

  Future<void> sendMessage(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final String? channelId = _channelId;
    if (channelId == null) return;

    final String uid = _c.auth.currentUser!.id;
    final String myName = ref.read(onboardingDraftProvider).name ?? 'You';
    _nameCache[uid] = myName;

    final String tempId = 'tmp_${DateTime.now().microsecondsSinceEpoch}';
    final ChatMessage optimistic = ChatMessage(
      senderName: myName,
      senderId: uid,
      text: trimmed,
      sentAt: DateTime.now(),
      status: ChatMessageStatus.sending,
      clientTempId: tempId,
    );
    _pending[tempId] = optimistic;
    state = AsyncData(_mergeState());

    try {
      await _repo.sendMessage(
        channelId: channelId,
        text: trimmed,
        clientTempId: tempId,
      );
      // Server insert triggers the stream to re-emit; the reconcile step
      // in _mergeState drops this pending once it appears in _lastServerRows.
      // Flip status to 'sent' in the meantime so the tick shows even if
      // the stream re-emission is delayed by a few ms.
      _pending[tempId] = optimistic.copyWith(status: ChatMessageStatus.sent);
      state = AsyncData(_mergeState());
    } catch (_) {
      _pending[tempId] = optimistic.copyWith(status: ChatMessageStatus.failed);
      state = AsyncData(_mergeState());
    }
  }

  Future<void> retry(String clientTempId) async {
    final ChatMessage? pending = _pending[clientTempId];
    final String? channelId = _channelId;
    if (pending == null || channelId == null) return;
    _pending[clientTempId] =
        pending.copyWith(status: ChatMessageStatus.sending);
    state = AsyncData(_mergeState());
    try {
      await _repo.sendMessage(
        channelId: channelId,
        text: pending.text,
        clientTempId: clientTempId,
      );
      _pending[clientTempId] =
          pending.copyWith(status: ChatMessageStatus.sent);
      state = AsyncData(_mergeState());
    } catch (_) {
      _pending[clientTempId] =
          pending.copyWith(status: ChatMessageStatus.failed);
      state = AsyncData(_mergeState());
    }
  }

  /// Bump `last_read_at` on this channel and invalidate the unread caches
  /// so the badges reflect reality immediately.
  Future<void> markRead() async {
    final String? channelId = _channelId;
    if (channelId == null) return;
    await _repo.markChannelRead(channelId);
    ref.invalidate(unreadCountsProvider);
  }

  // ---- internal ---------------------------------------------------------

  ChatMessage _rowToMessage(Map<String, dynamic> row) {
    final String? senderId = row['sender_id'] as String?;
    return ChatMessage(
      id: row['id'] as String?,
      senderId: senderId,
      senderName: senderId == null
          ? 'Lively'
          : (_nameCache[senderId] ?? 'Someone'),
      text: (row['body'] as String?) ?? '',
      isSystem: (row['is_system'] as bool?) ?? false,
      sentAt: DateTime.parse(row['created_at'] as String).toLocal(),
      status: ChatMessageStatus.sent,
      clientTempId:
          (row['metadata'] as Map<String, dynamic>?)?['client_temp_id']
              as String?,
    );
  }

  /// Server rows are authoritative for anything they contain. Local
  /// pending is overlaid on top; any pending whose clientTempId appears
  /// on the server side is dropped from pending (the server row wins).
  List<ChatMessage> _mergeState() {
    final List<ChatMessage> serverMessages =
        _lastServerRows.map(_rowToMessage).toList();
    final Set<String> serverTempIds = <String>{
      for (final ChatMessage m in serverMessages)
        if (m.clientTempId != null) m.clientTempId!,
    };
    _pending.removeWhere((tempId, _) => serverTempIds.contains(tempId));
    final List<ChatMessage> combined = <ChatMessage>[
      ...serverMessages,
      ..._pending.values,
    ]..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return combined;
  }
}

final chatMessagesProvider = AutoDisposeAsyncNotifierProvider
    .family<ChatController, List<ChatMessage>, String>(
  ChatController.new,
);

// ---------------------------------------------------------------------------
// Unread counts
// ---------------------------------------------------------------------------

/// Map of eventId → unread count. Single RPC round-trip; invalidated
/// whenever a new message arrives (via [chatInboxWatcherProvider]) or
/// whenever a chat is opened / left (via [ChatController.markRead]).
final unreadCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.read(chatRepositoryProvider).fetchUnreadCounts();
});

final unreadCountForEventProvider = Provider.family<int, String>((ref, eventId) {
  if (ref.watch(activeChatEventIdsProvider).contains(eventId)) return 0;
  final Map<String, int> counts =
      ref.watch(unreadCountsProvider).valueOrNull ?? const <String, int>{};
  return counts[eventId] ?? 0;
});

final totalUnreadCountProvider = Provider<int>((ref) {
  final Map<String, int> counts =
      ref.watch(unreadCountsProvider).valueOrNull ?? const <String, int>{};
  final Set<String> active = ref.watch(activeChatEventIdsProvider);
  int total = 0;
  for (final MapEntry<String, int> entry in counts.entries) {
    if (!active.contains(entry.key)) total += entry.value;
  }
  return total;
});

/// Global realtime subscription: any INSERT on messages (RLS-scoped to
/// channels the user is a member of) invalidates the unread counts so
/// the nav badge + per-row badges update while the user is anywhere in
/// the app. Watch this from a long-lived widget (MainShell) to keep it
/// alive for the session.
final chatInboxWatcherProvider = Provider<void>((ref) {
  try {
    final SupabaseChatRepository repo = ref.read(chatRepositoryProvider);
    final RealtimeChannel channel = repo.subscribeToAllInboxInserts(() {
      ref.invalidate(unreadCountsProvider);
    });
    ref.onDispose(() {
      try {
        SupabaseService.client.removeChannel(channel);
      } catch (_) {}
    });
  } catch (_) {
    // Realtime setup failed — badges won't live-update but the app stays functional.
  }
});

// ---------------------------------------------------------------------------
// Chats-list preview (last message per event)
// ---------------------------------------------------------------------------

final chatPreviewProvider =
    FutureProvider.autoDispose.family<ChatMessage?, String>(
  (ref, eventId) async {
    // Re-fetch whenever unread counts change (driven by chatInboxWatcherProvider
    // invalidating unreadCountsProvider on every message INSERT).
    ref.watch(unreadCountsProvider);

    final SupabaseClient client = SupabaseService.client;
    final Map<String, dynamic>? chan = await client
        .from('channels')
        .select('id')
        .eq('event_id', eventId)
        .eq('type', 'event_chat')
        .maybeSingle();
    if (chan == null) return null;

    final Map<String, dynamic>? row = await client
        .from('messages')
        .select(
          'id, body, created_at, is_system, sender_id, '
          'sender:profiles!sender_id(name)',
        )
        .eq('channel_id', chan['id'] as Object)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    final Map<String, dynamic>? sender = row['sender'] as Map<String, dynamic>?;
    return ChatMessage(
      id: row['id'] as String?,
      senderId: row['sender_id'] as String?,
      senderName: (sender?['name'] as String?) ?? 'Someone',
      text: (row['body'] as String?) ?? '',
      isSystem: (row['is_system'] as bool?) ?? false,
      sentAt: DateTime.parse(row['created_at'] as String).toLocal(),
    );
  },
);
