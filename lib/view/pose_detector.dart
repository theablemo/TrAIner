import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:trainerproject/controllers/pose_check.dart';
import 'package:trainerproject/controllers/providers/camera_provider.dart';
import 'package:trainerproject/controllers/providers/pose_provider.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/models/rep.dart';
import 'package:trainerproject/view/pose_detector_helper/camera_view.dart';

import 'pose_detector_helper/painters/pose_painter.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  bool _isCaptureBusy = false;
  CustomPaint? _customPaint;
  final _cameraLensDirection = CameraLensDirection.front;

  late final Interpreter interpreter;
  late final List<double> means;
  late final List<double> stds;

  final List<ExercisePhase> exercisePhaseMajorityVote =
      List.empty(growable: true);
  final List<SideView> sideViewMajorityVote = List.empty(growable: true);
  final List<bool> exercisePhaseChangedMajorityVote =
      List.empty(growable: true);
  final PoseCheck poseCheck = PoseCheck();
  bool isFirstFrame = true;
  late ExercisePhase lastExercisePhase;
  late Rep currentRep;
  // CameraDescription? _camera;
  // CameraController? _cameraController;
  // Error Majority Votes
  final List<bool> isHeelGroundedMajorityVote = List.empty(growable: true);
  final List<bool> isHeepSymmetricMajorityVote = List.empty(growable: true);
  final List<bool> isTorsoUprightMajorityVote = List.empty(growable: true);
  final List<bool> isKneeOutwardsMajorityVote = List.empty(growable: true);
  final List<bool> isKneeOverToeMajorityVote = List.empty(growable: true);
  final List<bool> isFeetWideEnoughMajorityVote = List.empty(growable: true);
  final List<bool> isFootOutwardsMajorityVote = List.empty(growable: true);
  static const int FRAMESTODECIDE = 5;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // initializeCamera();
      initializeInterpreter();
      loadMeans();
      loadStds();
    });
    super.initState();
  }

  @override
  void dispose() async {
    if (mounted) {
      // context.read<PoseProvider>().clearExercisePhase();
      // context.read<PoseProvider>().clearPose();
      // context.read<PoseProvider>().clearSideView();
      // context.read<PoseProvider>().clearAll();
    }
    _canProcess = false;
    // interpreter.close();
    _poseDetector.close();
    super.dispose();
  }

  // void initializeCamera() async {
  //   if (_camera == null) {
  //     print("inja hastam 0");
  //     // put the front camera in _camera
  //     final cameras = await availableCameras();
  //     setState(() {
  //       _camera = cameras.firstWhere(
  //         (camera) => camera.lensDirection == CameraLensDirection.front,
  //       );
  //     });
  //     // _camera = cameras.firstWhere(
  //     //   (camera) => camera.lensDirection == CameraLensDirection.front,
  //     // );
  //     print("inja hastam ${_camera.toString()}");
  //   }
  //   setState(() {
  //     _cameraController = CameraController(
  //       _camera!,
  //       // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
  //       ResolutionPreset.high,
  //       enableAudio: false,
  //       imageFormatGroup: Platform.isAndroid
  //           ? ImageFormatGroup.nv21
  //           : ImageFormatGroup.bgra8888,
  //     );
  //   });
  //   // _cameraController = CameraController(
  //   //   _camera!,
  //   //   // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
  //   //   ResolutionPreset.high,
  //   //   enableAudio: false,
  //   //   imageFormatGroup: Platform.isAndroid
  //   //       ? ImageFormatGroup.nv21
  //   //       : ImageFormatGroup.bgra8888,
  //   // );
  // }

  // Generic function to find the most frequent element
  T findMostFrequentElement<T>(List<T> list) {
    // Create a Map to store the count of each element
    Map<T, int> countMap = {};

    // Iterate through the list and update the count
    for (T element in list) {
      countMap[element] = (countMap[element] ?? 0) + 1;
    }

    // Find the element with the maximum count
    int maxCount = 0;
    late T mostFrequentElement;

    countMap.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        mostFrequentElement = key;
      }
    });

    return mostFrequentElement;
  }

  void initializeInterpreter() async {
    interpreter =
        await Interpreter.fromAsset('assets/models/squat/side/model.tflite');
  }

  // Future<List<double>> loadMeans() async {
  //   final data = await rootBundle.loadString('assets/means.json');
  //   return List<double>.from(json.decode(data));
  // }

  Future<void> loadMeans() async {
    final data =
        await rootBundle.loadString('assets/models/squat/side/means.json');
    means = List<double>.from(json.decode(data));
  }

  // Future<List<double>> loadStds() async {
  //   final data = await rootBundle.loadString('assets/stds.json');
  //   return List<double>.from(json.decode(data));
  // }

  Future<void> loadStds() async {
    final data =
        await rootBundle.loadString('assets/models/squat/side/stds.json');
    stds = List<double>.from(json.decode(data));
  }

  List<double> standardize(
      List<double> input, List<double> means, List<double> stds) {
    List<double> standardized = [];
    for (int i = 0; i < input.length; i++) {
      standardized.add((input[i] - means[i]) / stds[i]);
    }
    return standardized;
  }

  void interpretPose(List<double> input) {
    var output = List.filled(1 * 1, 0).reshape([1, 1]);

// inference
    interpreter.run(input, output);

    final outputValue = (output[0][0] as double).round();

    final finalDecisionThisRound =
        outputValue == 1 ? ExercisePhase.up : ExercisePhase.down;

    if (isFirstFrame) {
      if (mounted) {
        context.read<PoseProvider>().updateExerciePhase(finalDecisionThisRound);
        lastExercisePhase = finalDecisionThisRound;
        currentRep = Rep();
      }
    }

    if (exercisePhaseMajorityVote.length < FRAMESTODECIDE) {
      exercisePhaseMajorityVote.add(finalDecisionThisRound);
    } else {
      final finalDecision = findMostFrequentElement(exercisePhaseMajorityVote);
      exercisePhaseMajorityVote.clear();
      if (mounted) {
        context.read<PoseProvider>().updateExerciePhase(finalDecision);
      }
    }
  }

  Future<void> updateExercisePhase(List<Pose> poses) async {
    final excludedLandmarkTypes = [
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftPinky,
      PoseLandmarkType.rightPinky,
      PoseLandmarkType.leftIndex,
      PoseLandmarkType.rightIndex,
      PoseLandmarkType.leftThumb,
      PoseLandmarkType.rightThumb,
    ];
    final List<double> data = [];
    poses.first.landmarks.values.forEach((element) {
      if (!excludedLandmarkTypes.contains(element.type)) {
        data.add(element.x);
        data.add(element.y);
        // data.add(element.z);
      }
    });

    final standardizedData = standardize(data, means, stds);
    if (_canProcess) {
      interpretPose(standardizedData);
    } else {
      interpreter.close();
      return;
    }

    // interpretPose(data);
  }

  void updateSideView(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (leftShoulder == null || rightShoulder == null) {
      return;
    }

    final finalDecisionThisRound =
        leftShoulder.z < rightShoulder.z ? SideView.left : SideView.right;

    if (isFirstFrame) {
      if (mounted) {
        context.read<PoseProvider>().updateSideView(finalDecisionThisRound);
      }
    }

    if (sideViewMajorityVote.length < FRAMESTODECIDE) {
      sideViewMajorityVote.add(finalDecisionThisRound);
    } else {
      final finalDecision = findMostFrequentElement(sideViewMajorityVote);
      sideViewMajorityVote.clear();
      if (mounted) {
        context.read<PoseProvider>().updateSideView(finalDecision);
      }
    }
  }

  void checkFrontViewErrors(Map<PoseLandmarkType, PoseLandmark> landmarks,
      ExercisePhase exercisePhase) {
    // Hip Symmetric
    final isHipSymmetric = poseCheck.isHipSymmetric(landmarks);
    if (isFirstFrame) {
      if (mounted) {
        context.read<PoseProvider>().updateHeepSymmetric(isHipSymmetric);
      }
    }

    if (isHeepSymmetricMajorityVote.length < FRAMESTODECIDE) {
      isHeepSymmetricMajorityVote.add(isHipSymmetric);
    } else {
      final finalDecision =
          findMostFrequentElement(isHeepSymmetricMajorityVote);
      isHeepSymmetricMajorityVote.clear();
      if (mounted) {
        context.read<PoseProvider>().updateHeepSymmetric(finalDecision);
      }
    }

    // Knee Outwards
    final isKneeOutwards = poseCheck.isKneeOutwards(landmarks, exercisePhase);
    if (isFirstFrame) {
      if (mounted) {
        context.read<PoseProvider>().updateKneeOutwards(isKneeOutwards);
      }
    }

    if (isKneeOutwardsMajorityVote.length < FRAMESTODECIDE) {
      isKneeOutwardsMajorityVote.add(isKneeOutwards);
    } else {
      final finalDecision = findMostFrequentElement(isKneeOutwardsMajorityVote);
      isKneeOutwardsMajorityVote.clear();
      if (mounted) {
        context.read<PoseProvider>().updateKneeOutwards(finalDecision);
      }
    }

    // Feet Width
    final isFootWideEnough = poseCheck.isFeetWidthOk(landmarks);
    if (isFirstFrame) {
      if (mounted) {
        context.read<PoseProvider>().updateFootWideEnough(isFootWideEnough);
      }
    }

    if (isFeetWideEnoughMajorityVote.length < FRAMESTODECIDE) {
      isFeetWideEnoughMajorityVote.add(isFootWideEnough);
    } else {
      final finalDecision =
          findMostFrequentElement(isFeetWideEnoughMajorityVote);
      isFeetWideEnoughMajorityVote.clear();
      if (mounted) {
        context.read<PoseProvider>().updateFootWideEnough(finalDecision);
      }
    }

    // Feet Outwards
    final isFootOutwards = poseCheck.isFeetOutwards(landmarks, exercisePhase);
    if (isFirstFrame) {
      if (mounted) {
        context.read<PoseProvider>().updateFootOutwards(isFootOutwards);
      }
    }

    if (isFootOutwardsMajorityVote.length < 50) {
      isFootOutwardsMajorityVote.add(isFootOutwards);
    } else {
      final finalDecision = findMostFrequentElement(isFootOutwardsMajorityVote);
      isFootOutwardsMajorityVote.clear();
      if (mounted) {
        context.read<PoseProvider>().updateFootOutwards(finalDecision);
      }
    }
  }

  void checkSideViewErrors(Map<PoseLandmarkType, PoseLandmark> landmarks,
      ExercisePhase exercisePhase, SideView sideView) {
    // Heel Lifted
    final isHeelGrounded =
        poseCheck.isHeelGrounded(landmarks, exercisePhase, sideView);
    if (isFirstFrame) {
      if (mounted) {
        context.read<PoseProvider>().updateHeelGrounded(isHeelGrounded);
      }
    }

    if (isHeelGroundedMajorityVote.length < FRAMESTODECIDE) {
      isHeelGroundedMajorityVote.add(isHeelGrounded);
    } else {
      final finalDecision = findMostFrequentElement(isHeelGroundedMajorityVote);
      isHeelGroundedMajorityVote.clear();
      if (mounted) {
        context.read<PoseProvider>().updateHeelGrounded(finalDecision);
      }
    }

    // Torso Upright
    final isTorsoUpright = poseCheck.isTorsoAngleCorrect(landmarks, sideView);
    if (isFirstFrame) {
      if (mounted) {
        context.read<PoseProvider>().updateTorsoUpright(isTorsoUpright);
      }
    }

    if (isTorsoUprightMajorityVote.length < FRAMESTODECIDE) {
      isTorsoUprightMajorityVote.add(isTorsoUpright);
    } else {
      final finalDecision = findMostFrequentElement(isTorsoUprightMajorityVote);
      isTorsoUprightMajorityVote.clear();
      if (mounted) {
        context.read<PoseProvider>().updateTorsoUpright(finalDecision);
      }
    }

    // Knee over Toe
    final isKneeOverToe = poseCheck.isKneeOverToe(landmarks, sideView);
    if (isFirstFrame) {
      if (mounted) {
        context.read<PoseProvider>().updateKneeOverToe(isKneeOverToe);
      }
    }

    if (isKneeOverToeMajorityVote.length < FRAMESTODECIDE) {
      isKneeOverToeMajorityVote.add(isKneeOverToe);
    } else {
      final finalDecision = findMostFrequentElement(isKneeOverToeMajorityVote);
      isKneeOverToeMajorityVote.clear();
      if (mounted) {
        context.read<PoseProvider>().updateKneeOverToe(finalDecision);
      }
    }
  }

  void updateRep() {
    // if (exercisePhaseChangedMajorityVote.length < 10) {
    //   if (mounted) {
    //     if (context.read<PoseProvider>().exercisePhase != lastExercisePhase) {
    //       exercisePhaseChangedMajorityVote.add(true);
    //     }
    //     {
    //       exercisePhaseChangedMajorityVote.add(false);
    //     }
    //   }
    // } else {
    //   final isChanged =
    //       findMostFrequentElement(exercisePhaseChangedMajorityVote);
    //   exercisePhaseChangedMajorityVote.clear();
    //   if (isChanged && mounted) {
    //     context.read<PoseProvider>().addRep(currentRep);
    //     lastExercisePhase = context.read<PoseProvider>().exercisePhase!;
    //     currentRep = Rep();
    //   }
    // }
    if (mounted) {
      if (context.read<PoseProvider>().exercisePhase != lastExercisePhase) {
        if (lastExercisePhase == ExercisePhase.down) {
          context.read<PoseProvider>().addRep(currentRep);
          currentRep = Rep();
        }
        lastExercisePhase = context.read<PoseProvider>().exercisePhase!;
      }
    }
  }

  void takePictureofErrors() {
    if (mounted) {
      if (context.read<PoseProvider>().repErrors.isNotEmpty) {
        if (!currentRep.isWrong ||
            currentRep.errors.length <
                context.read<PoseProvider>().repErrors.length) {
          if (currentRep.isWrong) {
            File(currentRep.picturePath).delete();
          }

          currentRep.isWrong = true;
          currentRep.errors.addAll(context.read<PoseProvider>().repErrors);

          // Take Picture
          if (!context
              .read<CameraProvider>()
              .cameraController!
              .value
              .isInitialized) return;
          if (context
              .read<CameraProvider>()
              .cameraController!
              .value
              .isTakingPicture) return;
          if (!_canProcess) return;

          // if (_isCaptureBusy) return;
          // _isCaptureBusy = true;
          // setState(() {});
          context
              .read<CameraProvider>()
              .cameraController!
              .takePicture()
              .then((pictureFile) {
            // currentRep.picturePath = pictureFile.path;
            // final directory = await getApplicationDocumentsDirectory();
            getApplicationDocumentsDirectory().then((directory) {
              final path =
                  '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

              currentRep.picturePath = path;

              File file = File(pictureFile.path);
              file.copy(path).then((file) {});
            });
            // final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
            // File file = File(pictureFile!.path);
            // file = await file.copy(path);
            // _isCaptureBusy = false;

            if (!_canProcess) {
              context.read<CameraProvider>().cameraController!.dispose();
            }

            // setState(() {});
          });
        }
      }
    }
  }

  String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  void takePictureofErrorsAsync() async {
    if (mounted) {
      if (context.read<PoseProvider>().repErrors.isNotEmpty) {
        if (!currentRep.isWrong ||
            currentRep.errors.length <
                context.read<PoseProvider>().repErrors.length) {
          if (currentRep.isWrong) {
            File(currentRep.picturePath).delete();
          }

          currentRep.isWrong = true;
          currentRep.errors.addAll(context.read<PoseProvider>().repErrors);

          // Take Picture
          if (!context
              .read<CameraProvider>()
              .cameraController!
              .value
              .isInitialized) return;
          if (context
              .read<CameraProvider>()
              .cameraController!
              .value
              .isTakingPicture) return;
          if (!_canProcess) return;

          final pictureFile = await context
              .read<CameraProvider>()
              .cameraController!
              .takePicture();
          final directory = await getApplicationDocumentsDirectory();
          final path =
              '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          currentRep.picturePath = path;
          File file = File(pictureFile.path);
          file.copy(path).then((file) {});

          if (!_canProcess) {
            Provider.of<CameraProvider>(context, listen: false)
                .cameraController!
                .dispose();
          }
        }
      }
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});

    List<Pose> poses = [];

    if (context.read<PoseProvider>().isReadytoDetect) {
      // print("dar khedmatim");
      poses = await _poseDetector.processImage(inputImage);
    }

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null &&
        poses.isNotEmpty) {
      // 1. Update Poses
      if (mounted) {
        context.read<PoseProvider>().updatePose(poses.first);
      }
      // 2. Update SideView (right or left)
      if (mounted) {
        if (context.read<PoseProvider>().exercise!.viewType == ViewType.side) {
          updateSideView(poses.first);
        }
      }
      // 3. Update Phase (up or down)
      updateExercisePhase(poses).then((_) {});
      // 4. Update Rep
      updateRep();
      // 5. Update Errors
      if (mounted) {
        if (context.read<PoseProvider>().exercise!.viewType == ViewType.front) {
          checkFrontViewErrors(
            poses.first.landmarks,
            context.read<PoseProvider>().exercisePhase!,
          );
        } else {
          checkSideViewErrors(
            poses.first.landmarks,
            context.read<PoseProvider>().exercisePhase!,
            context.read<PoseProvider>().sideView!,
          );
        }
      }
      // 6. Take Picture if errors
      takePictureofErrorsAsync();

      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
      isFirstFrame = false;
    } else {
      if (mounted) {
        // context.read<PoseProvider>().clearExercisePhase();
        // context.read<PoseProvider>().clearPose();
        // context.read<PoseProvider>().clearSideView();
        // context.read<PoseProvider>().clearAll();
      }
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(customPaint: _customPaint, onImage: _processImage);
  }
}
