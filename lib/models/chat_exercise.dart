import 'package:trainerproject/models/chat_message.dart';

class ChatExercise {
  List<ChatMessage> messages;

  ChatExercise({List<ChatMessage>? messages})
      : messages = messages ?? List.empty(growable: true);

  Map<String, dynamic> toJson() => {
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  static ChatExercise fromJson(Map<String, dynamic> json) {
    return ChatExercise(
      messages: (json['messages'] as List)
          .map((i) => ChatMessage.fromJson(i))
          .toList(),
    );
  }
}
