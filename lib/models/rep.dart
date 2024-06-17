import 'package:trainerproject/models/chat_rep.dart';

enum RepError {
  hipSymmetry,
  kneeOutwards,
  feetWidth,
  feetOutwards,
  heelGrounded,
  torsoAngle,
  kneeOverToe,
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

  static String contextSettingPrompt() {
    return 'Analyze the user’s squat form and provide feedback based on the errors observed. The errors include: {errors}. Provide suggestions for improvement.';
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
