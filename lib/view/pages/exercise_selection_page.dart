import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/view/pages/exercise_page.dart';

class ExerciseSelectionPage extends StatefulWidget {
  @override
  _ExerciseSelectionPageState createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  bool isSquatExpanded = false;

  void _showInfoDialog(String view) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$view Information'),
          content: Text('This is the $view of the squat exercise.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToNextPage(ViewType viewType) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => ExerciseCompletionPage(
    //           userName: "Mammad",
    //           totalReps: 12,
    //           correctReps: 1,
    //           wrongReps: 11,
    //           wrongRepsImages: [])),
    // );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisePage(
          viewType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select an Exercise Below'),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          shrinkWrap: true,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.7),
                      Colors.purple.withOpacity(0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/icons/squat.svg',
                              alignment: Alignment.centerLeft,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Squat',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              isSquatExpanded = !isSquatExpanded;
                            });
                          },
                          trailing: Icon(
                            isSquatExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                      ],
                    ),
                    if (isSquatExpanded)
                      Column(
                        children: [
                          ListTile(
                            title: Text(ViewType.side.customName),
                            trailing: IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () =>
                                  _showInfoDialog(ViewType.side.customName),
                            ),
                            onTap: () => _navigateToNextPage(ViewType.side),
                          ),
                          ListTile(
                            title: Text(ViewType.front.customName),
                            trailing: IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () =>
                                  _showInfoDialog(ViewType.front.customName),
                            ),
                            onTap: () => _navigateToNextPage(ViewType.front),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // Add more exercises here when they become available
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.7),
                      Colors.black.withOpacity(0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    'Other Exercise (Coming Soon)',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  enabled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
          ],
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
