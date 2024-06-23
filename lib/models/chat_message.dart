enum MessageSender { llm, user }

class ChatMessage {
  MessageSender sender;
  String content;
  DateTime timestamp;

  ChatMessage(
      {required this.sender, required this.content, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'sender': sender.toString().split('.').last,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: MessageSender.values
          .firstWhere((e) => e.toString().split('.').last == json['sender']),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
