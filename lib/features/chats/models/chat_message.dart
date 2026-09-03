enum ChatMessageStatus { sending, sent, failed }

class ChatMessage {
  const ChatMessage({
    this.id,
    required this.senderName,
    this.senderId,
    required this.text,
    required this.sentAt,
    this.isSystem = false,
    this.status = ChatMessageStatus.sent,
    this.clientTempId,
  });

  /// Server-assigned uuid; null while a message is still in flight.
  final String? id;

  final String senderName;

  /// Server-side auth id of the sender; null for system messages.
  final String? senderId;

  final String text;
  final DateTime sentAt;
  final bool isSystem;

  /// Delivery state — sender only ever sees status for their own messages.
  final ChatMessageStatus status;

  /// Local uuid used to reconcile the optimistic bubble with the row that
  /// eventually lands back through realtime.
  final String? clientTempId;

  ChatMessage copyWith({
    String? id,
    String? senderName,
    String? senderId,
    String? text,
    DateTime? sentAt,
    bool? isSystem,
    ChatMessageStatus? status,
    String? clientTempId,
  }) => ChatMessage(
        id: id ?? this.id,
        senderName: senderName ?? this.senderName,
        senderId: senderId ?? this.senderId,
        text: text ?? this.text,
        sentAt: sentAt ?? this.sentAt,
        isSystem: isSystem ?? this.isSystem,
        status: status ?? this.status,
        clientTempId: clientTempId ?? this.clientTempId,
      );
}
