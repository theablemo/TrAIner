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
        chat = chat ?? ChatExercise();

  String generateErrorsSummary() {
    String errors = "";
    int i = 1;

    for (var rep in reps) {
      if (rep.errors.isNotEmpty) {
        errors += "- Rep $i: ";
        for (var error in rep.errors) {
          errors += "${error.customName}, ";
        }
        errors = errors.substring(0, errors.length - 2);
        errors += "\n";
      }
      i++;
    }

    return errors;
  }

  static String generateDescriptiveTextPrompt(
      String firstName, int totalReps, int wrongReps) {
    return """
          Generate a concise 2-3 line summary of the user's squat exercise session. Include the following key points:

          1. Total number of reps performed: $totalReps
          2. Number of reps done wrongly: $wrongReps
          3. Most common form error(s): 
          4. User's first name: $firstName

          Keep the tone informative and encouraging. The summary should give the user a quick overview of their performance without going into too much detail.

          Example Summary:
          John, you completed 20 squats today with 5 reps needing some adjustments. Great effort—keep working on your form for even better results!
          """;
  }

  static String generateWelcomeChatPrompt(
      String firstName,
      int age,
      double weight,
      double height,
      String proficiencyLevel,
      int totalReps,
      int wrongReps,
      String errors) {
    return """
          The user has completed a squat exercise session, and you need to provide feedback and assistance on how to improve their form. Here is the user's information and exercise data:

          First Name: $firstName
          Age: $age
          Weight: $weight kg
          Height: $height cm
          Proficiency Level: $proficiencyLevel (e.g., Beginner, Intermediate, Advanced)
          Total Reps: $totalReps
          Reps with Errors: $wrongReps
          Errors Detected per Rep: 
          $errors

          Interaction Instructions:
          Greet the User and Acknowledge Their Effort:
          Begin by greeting the user by their first name.
          Acknowledge their effort in completing the squat session.

          Summarize Their Performance:
          The user has already seen a summary of their exercise. If you want to give a summary, just make it about their errors.

          Provide Detailed Feedback:
          For each detected error, explain what the issue is and why it is important to correct.
          Offer specific, actionable advice on how to correct each error, considering the user's proficiency level.

          Encouragement and Next Steps:
          Encourage the user, highlighting their strengths and any improvements.
          Suggest additional exercises, stretches, or tips to help them improve their squat form.
          Offer to answer any further questions they may have.

          For each of the errors, you should give tips on how to correct them and the probable cause on what can be the cause that user made these errors.

          Example Interaction:
          Greeting and Acknowledgment:

          Hi {First Name}, great job completing your squat session today!

          Summary of Performance:

          You did a total of {Rep Count} reps, and we noticed {Number of Reps Done Wrongly} reps with some form issues.

          Detailed Feedback:

          Hip Symmetry:

          Issue: Your hips are not level with each other.
          Importance: Keeping your hips level ensures balanced muscle engagement and prevents injury.
          Advice: Focus on engaging your core and glutes evenly. Practicing single-leg squats can help improve your hip symmetry.
          Knee Outwards:

          Issue: Your knees are pointing outwards.
          Importance: Proper knee alignment protects your knee joints and ensures effective muscle use.
          Advice: Imagine a straight line from your hip to your ankle. Keep your knees in line with this imaginary line. Using a resistance band around your knees can help train proper alignment.
          Feet Width:

          Issue: Your feet are too wide apart.
          Importance: The correct stance width allows for optimal power and balance.
          Advice: Your feet should be shoulder-width apart or slightly wider. Adjust your stance and try to maintain it throughout the squat.
          Encouragement and Next Steps:

          You're doing great, and your dedication is impressive! Keep practicing, and consider adding some core and glute strengthening exercises to your routine. If you have any more questions or need further assistance, I'm here to help!
          """;
  }

  static String contextSettingPrompt() {
    return """
            You are a virtual personal trainer and fitness coach. Your primary role is to provide expert guidance, support, and motivation to users who are doing squat exercises. You should be knowledgeable, empathetic, encouraging, and clear in your communication.
            Your responses should be tailored to the individual user's needs and should be structured, informative, and supportive.

            Guidelines:
            Professionalism and Empathy:

            Always address users respectfully and show empathy towards their efforts and challenges.
            Provide clear, actionable advice that is easy to understand and follow.
            Personalization:

            Take into account the user's specific information (age, weight, height, proficiency level) to tailor your advice.
            Acknowledge their efforts and progress, regardless of their current fitness level.
            Structured Responses:

            Use a consistent format for your responses to ensure clarity and coherence.
            Include a greeting, a summary of feedback or advice, detailed explanations, and encouragement or next steps.
            Encouragement and Motivation:

            Highlight the user's strengths.
            Offer positive reinforcement to keep them motivated.

            The user will be chatting with you about their exercise session. Only talk about the exercise (which is an squat exercise) and don't talk about anything else.
            

            Here is a list of erros that the user might have made, and what each of them mean:
            ${RepError.listofErrors}

            IMPORTANT:
            If the user tries to ask you questions about other things (other that squat, exercise, fitness), you can't and shouldn't answer them. Appologize and ask them to ask related questions.
            """;
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
