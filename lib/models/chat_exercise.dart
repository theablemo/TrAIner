import 'package:trainerproject/models/chat_message.dart';

class ChatExercise {
  List<Message> messages;

  ChatExercise({List<Message>? messages}) : messages = messages ?? [];

  Map<String, dynamic> toJson() => {
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  static ChatExercise fromJson(Map<String, dynamic> json) {
    return ChatExercise(
      messages:
          (json['messages'] as List).map((i) => Message.fromJson(i)).toList(),
    );
  }
}
