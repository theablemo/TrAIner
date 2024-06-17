import 'package:intl/intl.dart';
import 'package:trainerproject/models/chat_exercise.dart';
import 'package:trainerproject/models/rep.dart';

enum ViewType {
  front,
  side,
}

extension ViewTypeExtension on ViewType {
  String get customName {
    switch (this) {
      case ViewType.front:
        return "Front View";
      case ViewType.side:
        return "Side View";
      default:
        return "";
    }
  }
}

class Exercise {
  int totalReps;
  int correctReps;
  int wrongReps;
  List<Rep> reps;
  String title;
  DateTime dateTime;
  String descriptiveText;
  ChatExercise chat;
  ViewType viewType;

  Exercise({
    this.totalReps = 0,
    this.correctReps = 0,
    this.wrongReps = 0,
    List<Rep>? reps,
    String? title,
    DateTime? dateTime,
    this.descriptiveText = '',
    ChatExercise? chat,
    required this.viewType,
  })  : reps = reps ?? [],
        title = title ??
            DateFormat('yyyy-MM-dd – kk:mm').format(dateTime ?? DateTime.now()),
        dateTime = dateTime ?? DateTime.now(),
        chat = chat ?? ChatExercise(messages: []);

  static String generateDescriptiveTextPrompt(
      int totalReps, int correctReps, int wrongReps) {
    return 'This exercise consists of $totalReps reps, where $correctReps reps were done correctly and $wrongReps reps were done wrong. Provide a detailed analysis.';
  }

  static String contextSettingPrompt() {
    return 'You are a personal trainer analyzing the form and performance of a user doing squats. Provide specific and constructive feedback based on the given data.';
  }

  Map<String, dynamic> toJson() => {
        'totalReps': totalReps,
        'correctReps': correctReps,
        'wrongReps': wrongReps,
        'reps': reps.map((r) => r.toJson()).toList(),
        'title': title,
        'dateTime': dateTime.toIso8601String(),
        'descriptiveText': descriptiveText,
        'chat': chat.toJson(),
        'viewType': viewType.toString().split('.').last,
      };

  static Exercise fromJson(Map<String, dynamic> json) {
    return Exercise(
      totalReps: json['totalReps'],
      correctReps: json['correctReps'],
      wrongReps: json['wrongReps'],
      reps: (json['reps'] as List).map((i) => Rep.fromJson(i)).toList(),
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      descriptiveText: json['descriptiveText'],
      chat: ChatExercise.fromJson(json['chat']),
      viewType: ViewType.values
          .firstWhere((e) => e.toString().split('.').last == json['viewType']),
    );
  }
}
