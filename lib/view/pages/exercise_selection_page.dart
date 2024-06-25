import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trainerproject/constants.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/models/rep.dart';
import 'package:trainerproject/view/pages/exercise_page.dart';

class ExerciseSelectionPage extends StatefulWidget {
  @override
  _ExerciseSelectionPageState createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  bool isSquatExpanded = false;

  Widget sideViewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            """In this view, you should perform the squat with the phone on your right or left side.\n The application will realize which side of your body is closer to the phone."""),
        const Text("In this view, the following errors will be detected:"),
        const SizedBox(
          height: 10,
        ),
        ExpansionTile(
          leading: Chip(
              // avatar: Icon(Icons.abc),
              backgroundColor: errorColor,
              side: BorderSide.none,
              label: Text(
                RepError.torsoAngle.customName,
                // style: TextStyle(color: errorColor),
              )),
          title: Text(""),
          children: [
            Text(RepError.torsoAngle.customDescription),
          ],
        ),
        ExpansionTile(
          leading: Chip(
              // avatar: Icon(Icons.abc),
              backgroundColor: errorColor,
              side: BorderSide.none,
              label: Text(
                RepError.heelGrounded.customName,
                // style: TextStyle(color: errorColor),
              )),
          title: Text(""),
          children: [
            Text(RepError.heelGrounded.customDescription),
          ],
        ),
        ExpansionTile(
          leading: Chip(
              // avatar: Icon(Icons.abc),
              backgroundColor: errorColor,
              side: BorderSide.none,
              label: Text(
                RepError.kneeOverToe.customName,
                // style: TextStyle(color: errorColor),
              )),
          title: Text(""),
          children: [
            Text(RepError.kneeOverToe.customDescription),
          ],
        ),
        // Row(
        //   children: [
        //     Chip(
        //         // avatar: Icon(Icons.abc),
        //         backgroundColor: errorColor,
        //         side: BorderSide.none,
        //         label: Text(
        //           RepError.heelGrounded.customName,
        //           // style: TextStyle(color: errorColor),
        //         ))
        //   ],
        // )
      ],
    );
  }

  Widget frontViewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            "In this view, you place the phone in front of you. This view is preferred as you can see the rep count and have a better understanding of what problems you are having as you perform the squat."),
        const Text("In this view, the following errors will be detected:"),
        const SizedBox(
          height: 10,
        ),
        ExpansionTile(
          leading: Chip(
            // avatar: Icon(Icons.abc),
            backgroundColor: errorColor,
            side: BorderSide.none,
            label: Text(
              RepError.feetOutwards.customName,
              // style: TextStyle(color: errorColor),
            ),
          ),
          title: const Text(""),
          children: [
            Text(RepError.feetOutwards.customDescription),
          ],
        ),
        ExpansionTile(
          leading: Chip(
            // avatar: Icon(Icons.abc),
            backgroundColor: errorColor,
            side: BorderSide.none,
            label: Text(
              RepError.feetWidth.customName,
              // style: TextStyle(color: errorColor),
            ),
          ),
          title: const Text(""),
          children: [
            Text(RepError.feetWidth.customDescription),
          ],
        ),
        ExpansionTile(
          leading: Chip(
            // avatar: Icon(Icons.abc),
            backgroundColor: errorColor,
            side: BorderSide.none,
            label: Text(
              RepError.hipSymmetry.customName,
              // style: TextStyle(color: errorColor),
            ),
          ),
          title: const Text(""),
          children: [
            Text(RepError.hipSymmetry.customDescription),
          ],
        ),
        ExpansionTile(
          leading: Chip(
            // avatar: Icon(Icons.abc),
            backgroundColor: errorColor,
            side: BorderSide.none,
            label: Text(
              RepError.kneeOutwards.customName,
              // style: TextStyle(color: errorColor),
            ),
          ),
          title: const Text(""),
          children: [
            Text(RepError.kneeOutwards.customDescription),
          ],
        ),
      ],
    );
  }

  void _showInfoDialog(ViewType view) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${view.customName} Information'),
          content: SingleChildScrollView(
            child:
                view == ViewType.side ? sideViewContent() : frontViewContent(),
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
                              onPressed: () => _showInfoDialog(ViewType.side),
                            ),
                            onTap: () => _navigateToNextPage(ViewType.side),
                          ),
                          ListTile(
                            title: Text(ViewType.front.customName),
                            trailing: IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () => _showInfoDialog(ViewType.front),
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
