import 'package:trainerproject/models/chat_message.dart';

class ChatRep {
  List<ChatMessage> messages;
  String wrongRepImagePath;
  String correctedImagePath;

  ChatRep({
    List<ChatMessage>? messages,
    this.wrongRepImagePath = "",
    this.correctedImagePath = "",
  }) : messages = messages ?? List.empty(growable: true);

  Map<String, dynamic> toJson() => {
        'messages': messages.map((m) => m.toJson()).toList(),
        'wrongRepImagePath': wrongRepImagePath,
        'correctedImagePath': correctedImagePath,
      };

  static ChatRep fromJson(Map<String, dynamic> json) {
    return ChatRep(
      messages: (json['messages'] as List)
          .map((i) => ChatMessage.fromJson(i))
          .toList(),
      wrongRepImagePath: json['wrongRepImagePath'],
      correctedImagePath: json['correctedImagePath'],
    );
  }
}
