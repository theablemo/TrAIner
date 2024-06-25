import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:flutter_gemma/flutter_gemma_interface.dart';

import 'package:provider/provider.dart';
import 'package:trainerproject/constants.dart';
import 'package:trainerproject/controllers/providers/exercise_provider.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/view/pages/exercise_overview_page.dart';
import 'package:trainerproject/view/pages/exercise_selection_page.dart';
import 'package:trainerproject/view/pages/profile_page.dart';

class HomePage extends StatelessWidget {
  void _deleteExercise(BuildContext context, Exercise exercise) {
    context.read<ExerciseProvider>().removeExercise(exercise);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TrAIner',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('About This App'),
                    content: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MarkdownBody(
                            // shrinkWrap: true,
                            data:
                                'Welcome to the Squat Analyzer, a cutting-edge application developed as part of **Mohammad Abolnejadian**\'s Bachelor\'s project in Computer Science, under the guidance of **Dr. Bardia Safaei** during the Winter and Spring terms of 2024.',
                          ),
                          MarkdownBody(
                            data:
                                'The Squat Analyzer leverages advanced machine learning classifiers to track and count your squat repetitions accurately. By analyzing your body pose in real-time, the application provides personalized feedback and corrective suggestions to ensure you perform each squat correctly, minimizing the risk of injury and maximizing your workout efficiency.',
                          ),
                          MarkdownBody(
                            data: 'Key features include:',
                          ),
                          MarkdownBody(
                            data:
                                '- **Real-time Rep Tracking:** Automatically count your squat reps using state-of-the-art ML classifiers.',
                          ),
                          MarkdownBody(
                            data:
                                '- **Pose Analysis and Correction:** Get instant feedback on your form and receive actionable suggestions to improve your squat technique.',
                          ),
                          MarkdownBody(
                            data:
                                '- **Session History:** Access a comprehensive list of your past squatting sessions to track your progress over time.',
                          ),
                          MarkdownBody(
                            data:
                                '- **AI Assistance:** Chat with a language model to receive exercise recommendations and summaries of your workout sessions.',
                          ),
                          MarkdownBody(
                            data:
                                'With the Squat Analyzer, enhance your squatting technique, track your progress, and achieve your fitness goals with intelligent, personalized guidance.',
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Version 1.0.0",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "June 2024",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: context.watch<ExerciseProvider>().exercises.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No exercise history available.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Time to get moving!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Consumer<ExerciseProvider>(
              builder: (context, exerciseProvider, child) {
                List<Exercise> exercises = exerciseProvider.exercises;
                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(exercises[index].title),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        // Implement deletion logic
                      },
                      confirmDismiss: (direction) {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Exercise'),
                              content: const Text(
                                  'Are you sure you want to delete this exercise?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Delete'),
                                  onPressed: () => _deleteExercise(
                                      context, exercises[index]),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      background: Container(
                        color: errorColor,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseOverviewPage(
                                exercise: exercises[index],
                                isOverViewing: true,
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          // leading: Icon(
                          //   exercises[index].correctReps /
                          //               exercises[index].totalReps >
                          //           0.5
                          //       ? Icons.check
                          //       : Icons.warning,
                          //   color: exercises[index].correctReps /
                          //               exercises[index].totalReps >
                          //           0.5
                          //       ? accentColor
                          //       : warningColor,
                          // ),
                          leading: Chip(
                            label: Text(
                              exercises[index].viewType.name,
                            ),
                            backgroundColor: exercises[index].correctReps /
                                        exercises[index].totalReps >
                                    0.5
                                ? accentColor
                                : warningColor,
                            // padding: EdgeInsets.all(value),
                          ),
                          title: Text(exercises[index].title),
                          subtitle: Text(
                              'Total: ${exercises[index].totalReps}, Correct: ${exercises[index].correctReps}, Wrong: ${exercises[index].totalReps - exercises[index].correctReps}'),
                          trailing: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // final directory = Directory("");
          // final ex = await directory.list();
          // print("manam: ${}");
          // final flutterGemma = FlutterGemmaPlugin.instance;
          // flutterGemma
          //     .getResponseAsync(prompt: 'Tell me something interesting')
          //     .listen((String? token) => print("Hello mammad: ${token}"));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExerciseSelectionPage()),
          );
        },
        icon: const Icon(Icons.fitness_center_rounded),
        label: const Text('Start New Exercise'),
      ),
    );
  }
}

class ExerciseDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
