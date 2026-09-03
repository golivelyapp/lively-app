import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/supabase_client.dart';

/// Persistence + realtime for event group chats.
///
/// The realtime path uses `client.from('messages').stream(...)` — a
/// higher-level API that internally maintains a resilient postgres
/// changes subscription and emits the full ordered list on every
/// mutation. That trades a bit of bandwidth for a much simpler dedup
/// model in the caller (the last emission is always the truth).
class SupabaseChatRepository {
  const SupabaseChatRepository();

  SupabaseClient get _c => SupabaseService.client;

  // ---- Channels ----------------------------------------------------------

  /// Look up (or lazily create) the event_chat channel for this event.
  /// The 0009 trigger normally creates it on event insert; this fallback
  /// handles events that predate the migration.
  Future<String> ensureChannelForEvent(String eventId) async {
    final Map<String, dynamic>? existing = await _c
        .from('channels')
        .select('id')
        .eq('event_id', eventId)
        .eq('type', 'event_chat')
        .maybeSingle();
    if (existing != null) return existing['id'] as String;

    final Map<String, dynamic> row = await _c
        .from('channels')
        .insert({'event_id': eventId, 'type': 'event_chat'})
        .select('id')
        .single();
    return row['id'] as String;
  }

  // ---- Messages (raw rows — provider maps to ChatMessage) ---------------

  /// Realtime stream of every message in the channel, ordered oldest
  /// → newest. First emission is the full history; subsequent emissions
  /// include appended messages.
  Stream<List<Map<String, dynamic>>> streamMessages(String channelId) {
    return _c
        .from('messages')
        .stream(primaryKey: <String>['id'])
        .eq('channel_id', channelId)
        .order('created_at');
  }

  /// Insert a message. `metadata.client_temp_id` lets the stream reconcile
  /// its echo against the optimistic bubble already on-screen.
  Future<Map<String, dynamic>> sendMessage({
    required String channelId,
    required String text,
    required String clientTempId,
  }) async {
    final String uid = _c.auth.currentUser!.id;
    return await _c
        .from('messages')
        .insert(<String, Object?>{
          'channel_id': channelId,
          'sender_id': uid,
          'body': text,
          'metadata': <String, String>{'client_temp_id': clientTempId},
        })
        .select()
        .single();
  }

  // ---- Sender name cache -------------------------------------------------

  /// One-shot fetch of profile names for the given uids. Used to enrich
  /// stream rows (which don't include joins).
  Future<Map<String, String>> fetchProfileNames(Set<String> uids) async {
    if (uids.isEmpty) return const <String, String>{};
    final List<Map<String, dynamic>> rows = List<Map<String, dynamic>>.from(
      await _c.from('profiles').select('id, name').inFilter('id', uids.toList()),
    );
    return <String, String>{
      for (final Map<String, dynamic> r in rows)
        r['id'] as String: (r['name'] as String?) ?? 'Someone',
    };
  }

  /// Names for every active member of a channel — used to warm the cache
  /// before the message stream starts emitting.
  Future<Map<String, String>> fetchChannelMemberNames(String channelId) async {
    final List<Map<String, dynamic>> rows = List<Map<String, dynamic>>.from(
      await _c
          .from('channel_members')
          .select('profile_id, profile:profiles!profile_id(name)')
          .eq('channel_id', channelId)
          .isFilter('left_at', null),
    );
    final Map<String, String> result = <String, String>{};
    for (final Map<String, dynamic> row in rows) {
      final String? id = row['profile_id'] as String?;
      final Map<String, dynamic>? profile =
          row['profile'] as Map<String, dynamic>?;
      final String? name = profile?['name'] as String?;
      if (id != null && name != null) result[id] = name;
    }
    return result;
  }

  // ---- Unread bookkeeping -----------------------------------------------

  /// Bump `channel_members.last_read_at` for the current user on this
  /// channel to now(). Idempotent.
  Future<void> markChannelRead(String channelId) async {
    final String? uid = _c.auth.currentUser?.id;
    if (uid == null) return;
    await _c
        .from('channel_members')
        .update(
            <String, Object?>{'last_read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('channel_id', channelId)
        .eq('profile_id', uid);
  }

  /// Map of eventId → unread count. Single RPC round-trip.
  Future<Map<String, int>> fetchUnreadCounts() async {
    final dynamic rows = await _c.rpc<dynamic>('my_unread_counts');
    if (rows is! List) return const <String, int>{};
    final Map<String, int> result = <String, int>{};
    for (final dynamic r in rows) {
      if (r is Map<String, dynamic>) {
        final String? eid = r['event_id'] as String?;
        final int? cnt = (r['unread_count'] as num?)?.toInt();
        if (eid != null) result[eid] = cnt ?? 0;
      }
    }
    return result;
  }

  /// Subscribe to every INSERT on `messages` (RLS scopes it to channels
  /// the caller is a member of). The client uses this to invalidate the
  /// unread badges when a message arrives in a chat the user isn't
  /// currently viewing.
  RealtimeChannel subscribeToAllInboxInserts(void Function() onInsert) {
    final RealtimeChannel rt = _c.channel(
      'inbox_${DateTime.now().microsecondsSinceEpoch}',
    );
    rt.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (_) => onInsert(),
    );
    rt.subscribe();
    return rt;
  }
}
