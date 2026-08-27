import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/event.dart';
import '../models/chat_message.dart';

/// Chats live only in-memory for now — persistence layer comes with the
/// Supabase migration. Keyed by eventId.
class EventChatsController extends Notifier<Map<String, List<ChatMessage>>> {
  @override
  Map<String, List<ChatMessage>> build() => <String, List<ChatMessage>>{};

  /// Seed the chat for a newly-RSVP'd event: welcome message + join notice
  /// for the current user. Idempotent — a second call for the same event
  /// only adds a "just RSVP'd" system message if the user isn't already in.
  void joinChat({required Event event, required String userName}) {
    final List<ChatMessage> existing = List<ChatMessage>.of(
      state[event.id] ?? const <ChatMessage>[],
    );

    if (existing.isEmpty) {
      final DateTime day = event.startTime;
      final String date =
          '${day.day} ${_month(day.month)}';
      existing.add(ChatMessage(
        senderName: 'Lively',
        text:
            "Welcome! This is the group chat for ${event.title} on $date. "
            "Everyone here is verified. Be respectful and have fun.",
        sentAt: DateTime.now(),
        isSystem: true,
      ));
    }

    existing.add(ChatMessage(
      senderName: 'Lively',
      text: '$userName just RSVP\'d and joined the chat.',
      sentAt: DateTime.now(),
      isSystem: true,
    ));

    state = <String, List<ChatMessage>>{...state, event.id: existing};
  }

  void leaveChat({required String eventId, required String userName}) {
    final List<ChatMessage>? existing = state[eventId];
    if (existing == null) return;
    final List<ChatMessage> next = List<ChatMessage>.of(existing)
      ..add(ChatMessage(
        senderName: 'Lively',
        text: '$userName cancelled their RSVP.',
        sentAt: DateTime.now(),
        isSystem: true,
      ));
    state = <String, List<ChatMessage>>{...state, eventId: next};
  }

  void sendMessage({
    required String eventId,
    required String senderName,
    required String text,
  }) {
    if (text.trim().isEmpty) return;
    final List<ChatMessage> existing = List<ChatMessage>.of(
      state[eventId] ?? const <ChatMessage>[],
    )..add(ChatMessage(
        senderName: senderName,
        text: text.trim(),
        sentAt: DateTime.now(),
      ));
    state = <String, List<ChatMessage>>{...state, eventId: existing};
  }

  static const List<String> _months = <String>[
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',
  ];
  static String _month(int m) => _months[m - 1];
}

final eventChatsProvider =
    NotifierProvider<EventChatsController, Map<String, List<ChatMessage>>>(
  EventChatsController.new,
);

/// Convenience: latest message preview for a given event chat.
final eventChatPreviewProvider = Provider.family<ChatMessage?, String>((ref, eventId) {
  final List<ChatMessage>? msgs = ref.watch(eventChatsProvider)[eventId];
  if (msgs == null || msgs.isEmpty) return null;
  return msgs.last;
});
