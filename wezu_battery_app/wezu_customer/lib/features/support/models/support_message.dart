enum MessageSender { user, support, bot }

class SupportMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final MessageSender sender;
  final String? attachmentUrl;
  final bool isRead;

  SupportMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.sender,
    this.attachmentUrl,
    this.isRead = false,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json,
      {int? currentUserId}) {
    MessageSender sender = MessageSender.support;
    final senderType = json['sender_type']?.toString();
    if (senderType == 'user') {
      sender = MessageSender.user;
    } else if (senderType == 'bot') {
      sender = MessageSender.bot;
    } else if (currentUserId != null &&
        (json['sender_id']?.toString() == currentUserId.toString())) {
      sender = MessageSender.user;
    }

    return SupportMessage(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? json['message']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ??
              json['created_at']?.toString() ??
              '') ??
          DateTime.now(),
      sender: sender,
      attachmentUrl: json['attachment_url'],
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender_type': sender.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
