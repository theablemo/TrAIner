enum MessageSender { llm, user }

class Message {
  MessageSender sender;
  String content;
  DateTime timestamp;

  Message(
      {required this.sender, required this.content, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'sender': sender.toString().split('.').last,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      sender: MessageSender.values
          .firstWhere((e) => e.toString().split('.').last == json['sender']),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
