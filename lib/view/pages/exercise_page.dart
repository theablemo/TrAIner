import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:trainerproject/constants.dart';
import 'package:trainerproject/controllers/providers/pose_provider.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/models/rep.dart';
import 'package:trainerproject/view/pages/exercise_completion_page.dart';
import 'package:trainerproject/view/pose_check_card.dart';
import 'package:trainerproject/view/pose_detector.dart';

class ExercisePage extends StatefulWidget {
  final ViewType viewType;

  const ExercisePage(
    this.viewType, {
    super.key,
  });

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  @override
  void initState() {
    super.initState();
    context.read<PoseProvider>().clearAll();
    context
        .read<PoseProvider>()
        .updateExercise(Exercise(viewType: widget.viewType));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructionsDialog();
    });
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Instructions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.info_outline,
                size: 50,
                color: Colors.blue,
              ),
              SizedBox(height: 10),
              Text(
                '1. Place your phone on a flat surface in portrait mode.\n'
                '2. Stay at least 1 meter away from the phone.\n'
                '3. Ensure your whole body is visible on the screen.',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCountdownDialog();
              },
              child: const Text('OK', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  void _showCountdownDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(15),
            child: CircularCountDownTimer(
              width: 200,
              height: 200,
              duration: 3,
              fillColor: primaryColor,
              ringColor: Colors.transparent,
              strokeWidth: 30,
              isReverse: true,
              isReverseAnimation: true,
              onComplete: () {
                Navigator.of(context).pop();
                _startAnalysis();
              },
            ),
            // child: CountdownIndicator(
            //   countdown: 3,
            //   onCountdownComplete: () {
            //     Navigator.of(context).pop();
            //     _startAnalysis();
            //   },
            // ),
          ),
        );
      },
    );
  }

  void _startAnalysis() {
    context.read<PoseProvider>().setReadytoDetect(true);
  }

  void exerciseFinished() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseCompletionPage(
          exercise: context.read<PoseProvider>().exercise!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   onPressed: () {

        //     Navigator.of(context).pop();

        //   },
        //   icon: const Icon(Icons.arrow_back),
        // ),
        actions: [
          IconButton(
            onPressed: exerciseFinished,
            icon: const Icon(
              Icons.sports_score_rounded,
              size: 40,
            ),
          ),
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //       foregroundColor: Colors.black,
          //       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          //       elevation: 0),
          //   onPressed: () {},
          //   child: Row(
          //     children: [
          //       Text(
          //         "Finish",
          //         style: TextStyle(fontSize: 20),
          //       ),
          //       // SizedBox(width: 20),
          //       Icon(
          //         Icons.sports_score_rounded,
          //         size: 20,
          //       )
          //     ],
          //   ),
          // ),
        ],
        centerTitle: true,
        title: Column(
          children: [
            const Text("Squat"),
            const SizedBox(height: 5),
            Text(
              context.watch<PoseProvider>().exercise!.viewType.customName,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const PoseDetectorView(),
            if (context.watch<PoseProvider>().exercisePhase != null)
              // if (isDetecting)
              Positioned(
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Text(
                      //   "knee:${context.watch<PoseCheck>().kneeDistance}",
                      //   style: TextStyle(
                      //     fontSize: 30,
                      //   ),
                      // ),
                      // Text(
                      //   "shoulder:${context.watch<PoseCheck>().shoulderDistance}",
                      //   style: TextStyle(
                      //     fontSize: 30,
                      //   ),
                      // ),
                      // Text(
                      //   "right:${context.read<PoseCheck>().getLeftKneeAngle(context.read<PoseModel>().currentPose!.landmarks)}",
                      //   style: TextStyle(
                      //     fontSize: 30,
                      //   ),
                      // ),
                      // Text(
                      //   "left:${context.read<PoseCheck>().getRightKneeAngle(context.read<PoseModel>().currentPose!.landmarks)}",
                      //   style: TextStyle(
                      //     fontSize: 30,
                      //   ),
                      // ),
                      // Text(
                      //   "hip:${context.read<PoseCheck>().calculateHipTiltAngle(context.read<PoseModel>().currentPose!.landmarks)}",
                      //   style: TextStyle(
                      //     fontSize: 40,
                      //   ),
                      // ),
                      // Text(
                      //   "hip:${context.read<PoseCheck>().isHeelLifted(context.read<PoseModel>().currentPose!.landmarks, context.read<PoseModel>().exercisePhase!)}",
                      //   style: TextStyle(
                      //     fontSize: 40,
                      //   ),
                      // ),
                      // Text(
                      //   "torso:${context.read<PoseCheck>().calculateTorsoAngle(context.read<PoseModel>().currentPose!.landmarks)}",
                      //   style: TextStyle(
                      //     fontSize: 40,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      // color: Colors.white,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          context
                              .watch<PoseProvider>()
                              .exercise!
                              .totalReps
                              .toString(),
                          style: TextStyle(
                            fontSize: 35,
                            color: backgroundColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      // color: Colors.white,
                      child: Center(
                        child: Text(
                          context.watch<PoseProvider>().exercisePhase == null
                              ? "NONE"
                              : context.watch<PoseProvider>().exercisePhase ==
                                      ExercisePhase.up
                                  ? "Up"
                                  : "Down",
                          style: const TextStyle(
                              fontSize: 35, color: backgroundColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (context.watch<PoseProvider>().currentPose != null)
              Positioned(
                bottom: 10,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        context.watch<PoseProvider>().exercise!.viewType ==
                                ViewType.side
                            ? PoseCheckCard(
                                checkTitle: RepError.heelGrounded.customName,
                                currentSitutation: context
                                    .watch<PoseProvider>()
                                    .isHeelGrounded!,
                              )
                            : PoseCheckCard(
                                checkTitle: RepError.hipSymmetry.customName,
                                currentSitutation: context
                                    .watch<PoseProvider>()
                                    .isHeepSymmetric!,
                              ),
                        context.watch<PoseProvider>().exercise!.viewType ==
                                ViewType.side
                            ? PoseCheckCard(
                                checkTitle: RepError.torsoAngle.customName,
                                currentSitutation: context
                                    .watch<PoseProvider>()
                                    .isTorsoUpright!,
                              )
                            : PoseCheckCard(
                                checkTitle: RepError.kneeOutwards.customName,
                                currentSitutation: context
                                    .watch<PoseProvider>()
                                    .isKneeOutwards!,
                              ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        context.watch<PoseProvider>().exercise!.viewType ==
                                ViewType.side
                            ? PoseCheckCard(
                                checkTitle: RepError.kneeOverToe.customName,
                                currentSitutation: context
                                    .watch<PoseProvider>()
                                    .isKneeOverToe!,
                              )
                            : PoseCheckCard(
                                checkTitle: RepError.feetWidth.customName,
                                currentSitutation: context
                                    .watch<PoseProvider>()
                                    .isFootWideEnough!,
                              ),
                        if (context.watch<PoseProvider>().exercise!.viewType ==
                            ViewType.front)
                          PoseCheckCard(
                            checkTitle: RepError.feetOutwards.customName,
                            currentSitutation:
                                context.watch<PoseProvider>().isFootOutwards!,
                          ),
                      ],
                    ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     PoseCheckCard(
                    //       checkTitle: "Hip Symmetry",
                    //       currentSitutation:
                    //           context.read<PoseCheck>().isHipSymmetric(
                    //                 context
                    //                     .read<PoseProvider>()
                    //                     .currentPose!
                    //                     .landmarks,
                    //               ),
                    //     ),
                    //   ],
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     PoseCheckCard(
                    //       checkTitle: "Knee Carve",
                    //       currentSitutation:
                    //           !context.read<PoseCheck>().isKneeCavingIn(
                    //                 context
                    //                     .read<PoseProvider>()
                    //                     .currentPose!
                    //                     .landmarks,
                    //                 context.read<PoseProvider>().exercisePhase!,
                    //               ),
                    //     ),
                    //     PoseCheckCard(
                    //       checkTitle: "Foot Placement",
                    //       currentSitutation:
                    //           context.read<PoseCheck>().checkFeetPosition(
                    //                 context
                    //                     .read<PoseProvider>()
                    //                     .currentPose!
                    //                     .landmarks,
                    //                 context.read<PoseProvider>().exercisePhase!,
                    //               ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
