import 'dart:io';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trainerproject/controllers/providers/chat_provider.dart';
import 'package:trainerproject/controllers/providers/exercise_provider.dart';
import 'package:trainerproject/controllers/providers/user_info_provider.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/models/rep.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as GenAI;
import 'package:trainerproject/models/user_info.dart';
import 'package:trainerproject/view/pages/exercise_chat_page.dart';
import 'package:trainerproject/view/placeholders.dart';

class ExerciseOverviewPage extends StatefulWidget {
  // final int totalReps;
  // final int correctReps;
  // final int wrongReps;
  // final List<String> wrongRepsImages;
  final Exercise exercise;
  final bool isOverViewing;

  ExerciseOverviewPage({
    // required this.totalReps,
    // required this.correctReps,
    // required this.wrongReps,
    // required this.wrongRepsImages,
    required this.exercise,
    required this.isOverViewing,
  });

  @override
  State<ExerciseOverviewPage> createState() => _ExerciseOverviewPageState();
}

class _ExerciseOverviewPageState extends State<ExerciseOverviewPage> {
  late final Exercise exercise;
  Map<int, Rep> wrongReps = {};
  Map<int, String> wrongRepsImages = {};
  late String overviewText;
  late bool isOverviewing;
  bool isOverviewGenerating = true;
  @override
  void initState() {
    isOverviewing = widget.isOverViewing;
    exercise = widget.exercise;
    final reps = exercise.reps;

    // get wrong reps
    for (int i = 0; i < reps.length; i++) {
      if (reps[i].isWrong) {
        if (File(reps[i].picturePath).existsSync()) {
          wrongReps[i + 1] = reps[i];
        }
      }
    }

    wrongRepsImages =
        wrongReps.map((index, rep) => MapEntry(index, rep.picturePath));

    // wrongRepsImages = wrongReps.map((rep) => rep.picturePath).toList();

    overviewText = exercise.descriptiveText;
    if (overviewText.isNotEmpty) {
      isOverviewGenerating = false;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateOverview();
      });
    }
    super.initState();
  }

  void _generateOverview() async {
    final apiKey = Provider.of<ChatProvider>(context, listen: false).apiKey;
    UserInfo userInfo =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo!;
    final model = GenAI.GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      systemInstruction: GenAI.Content.text(
        Exercise.contextSettingPrompt(),
      ),
    );
    try {
      final response = await model.generateContent([
        GenAI.Content.text(
          Exercise.generateDescriptiveTextPrompt(
            userInfo.firstName,
            exercise.totalReps,
            exercise.wrongReps,
          ),
        ),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        setState(() {
          overviewText =
              'Great job, ${userInfo.firstName}! You completed a total of ${widget.exercise.totalReps} reps. Out of these, '
              '${widget.exercise.correctReps} were performed correctly and ${widget.exercise.wrongReps} were incorrect. '
              'Keep practicing to improve your form.';
          isOverviewGenerating = false;
        });
      } else {
        setState(() {
          overviewText = text.trim();
          isOverviewGenerating = false;
        });
      }
    } catch (e) {
      // print(e);
    } finally {
      exercise.descriptiveText = overviewText;
    }
  }

  // void _dismissExercise(BuildContext context) {
  //   // Handle exercise dismissal
  //   Navigator.of(context).pop();
  // }

  void _saveExercise() {
    // Handle exercise saving
    isOverviewing
        ? context.read<ExerciseProvider>().saveModifiedExercise(exercise)
        : context.read<ExerciseProvider>().addExercise(exercise);
    Navigator.of(context).pop();
  }

  void _aiRecommendation(Rep wrongRep, int repIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (context) => RepChatPage(
        //   wrongRep: wrongRep,
        // ),
        builder: (context) => ExerciseChatPage(
          exercise: exercise,
          isGeneralChat: false,
          rep: wrongRep,
        ),
      ),
    );
  }

  void _chatAboutExercise(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseChatPage(
          exercise: exercise,
          isGeneralChat: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.close),
        //   onPressed: () => _dismissExercise(context),
        // ),
        title: const Text("Exercise Overview"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveExercise,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Column(
                        children: [
                          const Text('Total Reps',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.exercise.totalReps}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Column(
                            children: [
                              const Text(
                                'Correct Reps',
                                style: TextStyle(fontSize: 16),
                              ),
                              // SizedBox(height: 8),
                              Text(
                                '${widget.exercise.correctReps}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Column(
                            children: [
                              const Text('Wrong Reps',
                                  style: TextStyle(fontSize: 16)),
                              // SizedBox(height: 8),
                              Text(
                                '${widget.exercise.wrongReps}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isOverviewGenerating
                  ? Shimmer.fromColors(
                      enabled: isOverviewGenerating,
                      baseColor:
                          isOverviewGenerating ? Colors.grey : Colors.black,
                      highlightColor: Colors.white,
                      child: TitlePlaceholder(
                        width: MediaQuery.of(context).size.width * 0.8,
                      ),
                    )
                  : Text(
                      overviewText,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.auto_awesome),
                label: Text('Chat about this exercise with LLM'),
                onPressed: () {
                  _chatAboutExercise(exercise);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              if (wrongRepsImages.isNotEmpty) ...[
                Text(
                  'Review Your Wrong Reps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                CarouselSlider.builder(
                    itemCount: wrongRepsImages.length,
                    options: CarouselOptions(
                      height: 300,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      aspectRatio: 2.0,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration: Duration(milliseconds: 2000),
                      viewportFraction: 0.8,
                    ),
                    itemBuilder: (BuildContext context, int itemIndex,
                        int pageViewIndex) {
                      final repIndex = wrongRepsImages.keys.toList()[itemIndex];
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Hero(
                            tag: 'rep$repIndex',
                            child: Image.file(
                              File(wrongRepsImages[repIndex]!),
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            child: Container(
                              color: Colors.black54,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Text(
                                'Rep ${repIndex}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.auto_awesome),
                              label: Text('AI recommendation on this'),
                              onPressed: () => _aiRecommendation(
                                  wrongReps[repIndex]!, repIndex),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(12),
                              ),
                            ),
                          )
                        ],
                      );
                    }),
                // SizedBox(height: 20),
                // ElevatedButton.icon(
                //   icon: Icon(Icons.auto_awesome),
                //   label: Text('AI recommendation on this'),
                //   onPressed: _aiRecommendation,
                //   style: ElevatedButton.styleFrom(
                //     padding: EdgeInsets.symmetric(vertical: 12),
                //   ),
                // ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  final String view;

  NextPage({required this.view});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$view Page'),
      ),
      body: Center(
        child: Text('Details for $view'),
      ),
    );
  }
}
