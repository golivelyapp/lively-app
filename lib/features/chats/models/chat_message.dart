class ChatMessage {
  const ChatMessage({
    required this.senderName,
    required this.text,
    required this.sentAt,
    this.isSystem = false,
  });

  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isSystem;
}
