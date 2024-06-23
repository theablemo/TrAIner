import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:provider/provider.dart';
import 'package:trainerproject/controllers/providers/camera_provider.dart';
import 'package:trainerproject/controllers/providers/user_info_provider.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/view/pages/exercise_overview_page.dart';

class ExerciseCompletionPage extends StatefulWidget {
  final Exercise exercise;

  ExerciseCompletionPage({
    required this.exercise,
  });

  @override
  _ExerciseCompletionPageState createState() => _ExerciseCompletionPageState();
}

class _ExerciseCompletionPageState extends State<ExerciseCompletionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final String firstName;

  @override
  void initState() {
    UserInfoProvider userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    firstName = userInfoProvider.userInfo!.firstName;
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseOverviewPage(
              exercise: widget.exercise,
              isOverViewing: false,
            ),
            // builder: (context) => /ExerciseOverviewPage(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    Provider.of<CameraProvider>(context, listen: false)
        .cameraController!
        .dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animated_check.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..forward();
              },
            ),
            SizedBox(height: 20),
            Text(
              'Well done, ${firstName}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
