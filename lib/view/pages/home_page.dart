import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:trainerproject/constants.dart';
import 'package:trainerproject/controllers/providers/exercise_provider.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/view/pages/exercise_selection_page.dart';
import 'package:trainerproject/view/pages/profile_page.dart';

class HomePage extends StatelessWidget {
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
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('About This App'),
                    content: const Text(
                        'This app helps athletes to track and analyze their squats. Created by Your Name.'),
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
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      background: Container(
                        color: errorColor,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseDetailPage(),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: Icon(
                            exercises[index].correctReps /
                                        exercises[index].totalReps >
                                    0.5
                                ? Icons.check
                                : Icons.warning,
                            color: exercises[index].correctReps /
                                        exercises[index].totalReps >
                                    0.5
                                ? accentColor
                                : warningColor,
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
        onPressed: () {
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