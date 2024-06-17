import 'package:trainerproject/models/chat_message.dart';

class ChatRep {
  List<Message> messages;
  String wrongRepImagePath;
  String correctedImagePath;

  ChatRep({
    List<Message>? messages,
    this.wrongRepImagePath = "",
    this.correctedImagePath = "",
  }) : messages = messages ?? [];

  Map<String, dynamic> toJson() => {
        'messages': messages.map((m) => m.toJson()).toList(),
        'wrongRepImagePath': wrongRepImagePath,
        'correctedImagePath': correctedImagePath,
      };

  static ChatRep fromJson(Map<String, dynamic> json) {
    return ChatRep(
      messages:
          (json['messages'] as List).map((i) => Message.fromJson(i)).toList(),
      wrongRepImagePath: json['wrongRepImagePath'],
      correctedImagePath: json['correctedImagePath'],
    );
  }
}
