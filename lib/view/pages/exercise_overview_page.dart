import 'dart:io';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/models/rep.dart';
import 'package:trainerproject/view/pages/exercise_chat_page.dart';

class ExerciseOverviewPage extends StatefulWidget {
  // final int totalReps;
  // final int correctReps;
  // final int wrongReps;
  // final List<String> wrongRepsImages;
  final Exercise exercise;

  ExerciseOverviewPage({
    // required this.totalReps,
    // required this.correctReps,
    // required this.wrongReps,
    // required this.wrongRepsImages,
    required this.exercise,
  });

  @override
  State<ExerciseOverviewPage> createState() => _ExerciseOverviewPageState();
}

class _ExerciseOverviewPageState extends State<ExerciseOverviewPage> {
  late final Exercise exercise;
  late final List<Rep> wrongReps;
  late final List<String> wrongRepsImages;
  @override
  void initState() {
    exercise = widget.exercise;
    wrongReps = exercise.reps.where((rep) => rep.isWrong).toList();
    wrongRepsImages = wrongReps.map((rep) => rep.picturePath).toList();
    super.initState();
  }

  void _dismissExercise(BuildContext context) {
    // Handle exercise dismissal
    Navigator.of(context).pop();
  }

  void _saveExercise() {
    // Handle exercise saving
  }

  void _chatAboutExercise(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
            // userName: 'John', // replace with actual user name
            // wrongRepsDetails: [
            //   {
            //     'repNumber': 1,
            //     'error': 'Knee Position',
            //     'originalImage': 'assets/test/original1.jpg',
            //     'correctedImage': 'assets/test/corrected1.jpg'
            //   },
            //   {
            //     'repNumber': 2,
            //     'error': 'Back Position',
            //     'originalImage': 'assets/test/original2.jpg',
            //     'correctedImage': 'assets/test/corrected2.jpg'
            //   },
            // ],
            ),
      ),
    );
  }

  void _aiRecommendation() {
    // Handle AI recommendation
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
              SizedBox(height: 20),
              Text(
                'Great job! You completed a total of ${widget.exercise.totalReps} reps. Out of these, '
                '${widget.exercise.correctReps} were performed correctly and ${widget.exercise.wrongReps} were incorrect. '
                'Keep practicing to improve your form.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.auto_awesome),
                label: Text('Chat about this exercise with LLM'),
                // onPressed: () => _chatAboutExercise(context),
                onPressed: () {},
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
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    viewportFraction: 0.8,
                  ),
                  itemBuilder: (BuildContext context, int itemIndex,
                          int pageViewIndex) =>
                      Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Image.file(
                        File(wrongRepsImages[itemIndex]),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Positioned(
                        top: 10,
                        child: Container(
                          color: Colors.black54,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'Rep ${itemIndex + 1}',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      Positioned(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.auto_awesome),
                          label: Text('AI recommendation on this'),
                          onPressed: _aiRecommendation,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(12),
                          ),
                        ),
                        bottom: 5,
                      )
                    ],
                  ),
                ),
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
