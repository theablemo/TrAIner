import 'package:trainerproject/models/chat_rep.dart';

enum RepError {
  hipSymmetry,
  kneeOutwards,
  feetWidth,
  feetOutwards,
  heelGrounded,
  torsoAngle,
  kneeOverToe;

  static String get listofErrors {
    String returnedValue = "";
    for (var repError in RepError.values) {
      returnedValue =
          '$returnedValue- ${repError.customName}: ${repError.customDescription}\n';
    }
    return returnedValue;
  }
}

extension RepErrorExtension on RepError {
  String get customName {
    switch (this) {
      case RepError.hipSymmetry:
        return "Hip Symmetry";
      case RepError.kneeOutwards:
        return "Knee Outwards";
      case RepError.feetWidth:
        return "Feet Width";
      case RepError.feetOutwards:
        return "Feet Outwards";
      case RepError.heelGrounded:
        return "Heel Grounded";
      case RepError.torsoAngle:
        return "Torso Upright";
      case RepError.kneeOverToe:
        return "Knee Behind Toe";
      default:
        return "";
    }
  }

  String get customDescription {
    switch (this) {
      case RepError.hipSymmetry:
        return "The hips are not level with each other.";
      case RepError.kneeOutwards:
        return "The knees are pointing outwards.";
      case RepError.feetWidth:
        return "The feet are too wide apart.";
      case RepError.feetOutwards:
        return "The feet are pointing outwards.";
      case RepError.heelGrounded:
        return "The heels are not touching the ground.";
      case RepError.torsoAngle:
        return "The torso is not upright.";
      case RepError.kneeOverToe:
        return "The knees are in front of the toes.";
      default:
        return "";
    }
  }
}

class Rep {
  bool isWrong;
  Set<RepError> errors;
  String picturePath;
  ChatRep chat;

  Rep({
    this.isWrong = false,
    Set<RepError>? errors,
    this.picturePath = "",
    ChatRep? chat,
  })  : errors = errors ?? {},
        chat = chat ?? ChatRep();

  static String generateWelcomeChatPrompt(String errors) {
    return """
          Analyze the provided image of the user's squat rep, focusing on the detected error(s). Use the following information:

          - Image: it its attached
          - Detected Error(s) for this error: $errors 

          In your analysis:
          1. Briefly describe the key elements of the squat position shown in the image.
          2. Confirm whether the detected error(s) are visible in the image and explain how you can see them.
          3. Explain the potential impact of these errors on the user's performance and risk of injury.
          4. Provide specific, actionable guidance on how to correct the identified error(s).
          5. Offer a helpful visualization or mental cue to assist the user in maintaining proper form in future reps.

          Remember to be detailed yet concise, and maintain a constructive, educational tone throughout your analysis.
          """;
  }

  static String contextSettingPrompt() {
    return """
          You are an expert squat form analyst with the ability to visually assess exercise technique. Your role is to provide detailed, constructive feedback on specific squat repetitions based on images and detected errors. 
          Your analysis should be precise, educational, and actionable. You should be knowledgeable, empathetic, encouraging, and clear in your communication.

          In this chat, you will be analyzing squat form based on images and providing feedback on detected errors. The detected errors on the squat will be given to you, but you may need to identify and explain any additional errors.
          You should offer advice on how to correct the errors.

          When analyzing a rep, follow this format:

          1. Image Description: Briefly describe the key elements of the squat position shown in the image.
          2. Error Identification: Confirm the detected error(s) and explain how they are visible in the image.
          3. Impact: Explain the potential consequences of the identified error(s) on performance and safety.
          4. Correction Guidance: Provide specific, actionable advice on how to correct the error(s).
          5. Visualization Tip: Offer a mental image or cue to help the user remember proper form.

          Use clear, concise language and maintain a supportive tone. Your goal is to help the user understand their mistakes and learn how to perform the squat correctly and safely.
          After analyzing the image, the user will be chatting with you about the rep they did wrong . Only talk about the rep of the exercise (which is an squat exercise) and don't talk about anything else.

          Here is a list of erros that the user might have made, and what each of them mean:
          ${RepError.listofErrors}

          IMPORTANT:
          If the user tries to ask you questions about other things (other that squat, exercise, fitness), you can't and shouldn't answer them. Appologize and ask them to ask related questions.
          """;
  }

  Map<String, dynamic> toJson() => {
        'isWrong': isWrong,
        'errors': errors.map((e) => e.toString().split('.').last).toList(),
        'picturePath': picturePath,
        'chat': chat.toJson(),
      };

  static Rep fromJson(Map<String, dynamic> json) {
    return Rep(
      isWrong: json['isWrong'],
      errors: (json['errors'] as List)
          .map((e) => RepError.values
              .firstWhere((element) => element.toString().split('.').last == e))
          .toSet(),
      picturePath: json['picturePath'],
      chat: ChatRep.fromJson(json['chat']),
    );
  }
}
