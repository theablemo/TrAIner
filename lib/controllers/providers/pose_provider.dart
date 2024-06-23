import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/models/rep.dart';

enum ExercisePhase { up, down }

enum SideView { right, left }

class PoseProvider extends ChangeNotifier {
  Pose? currentPose;
  ExercisePhase? exercisePhase;
  SideView? sideView;
  Exercise? exercise;
  bool? isHeelGrounded;
  bool? isHeepSymmetric;
  bool? isTorsoUpright;
  bool? isKneeOutwards;
  bool? isKneeOverToe;
  bool? isFootWideEnough;
  bool? isFootOutwards;
  Set<RepError> repErrors = {};
  bool isReadytoDetect = false;
  bool isCameraDisposed = false;

  void setCameraDisposed(bool value) {
    isCameraDisposed = value;
    notifyListeners();
  }

  void setReadytoDetect(bool value) {
    isReadytoDetect = value;
    notifyListeners();
  }

  void updateExercise(Exercise ex) {
    exercise = ex;
    // notifyListeners();
  }

  void clearExercise() {
    exercise = null;
    notifyListeners();
  }

  void updatePose(Pose pose) {
    currentPose = pose;
    notifyListeners();
  }

  void clearPose() {
    currentPose = null;
    notifyListeners();
  }

  void updateExerciePhase(ExercisePhase pose) {
    exercisePhase = pose;
    notifyListeners();
  }

  void clearExercisePhase() {
    exercisePhase = null;
    notifyListeners();
  }

  void updateSideView(SideView view) {
    sideView = view;
    notifyListeners();
  }

  void clearSideView() {
    sideView = null;
    notifyListeners();
  }

  void updateHeelGrounded(bool value) {
    isHeelGrounded = value;
    value
        ? repErrors.remove(RepError.heelGrounded)
        : repErrors.add(RepError.heelGrounded);

    notifyListeners();
  }

  void clearHeelGrounded() {
    isHeelGrounded = null;
    repErrors.remove(RepError.heelGrounded);

    notifyListeners();
  }

  void updateHeepSymmetric(bool value) {
    isHeepSymmetric = value;
    value
        ? repErrors.remove(RepError.hipSymmetry)
        : repErrors.add(RepError.hipSymmetry);

    notifyListeners();
  }

  void clearHeepSymmetric() {
    isHeepSymmetric = null;
    repErrors.remove(RepError.hipSymmetry);

    notifyListeners();
  }

  void updateTorsoUpright(bool value) {
    isTorsoUpright = value;
    value
        ? repErrors.remove(RepError.torsoAngle)
        : repErrors.add(RepError.torsoAngle);

    notifyListeners();
  }

  void clearTorsoUpright() {
    isTorsoUpright = null;
    repErrors.remove(RepError.torsoAngle);

    notifyListeners();
  }

  void updateKneeOutwards(bool value) {
    isKneeOutwards = value;
    value
        ? repErrors.remove(RepError.kneeOutwards)
        : repErrors.add(RepError.kneeOutwards);

    notifyListeners();
  }

  void clearKneeOutwards() {
    isKneeOutwards = null;
    repErrors.remove(RepError.kneeOutwards);

    notifyListeners();
  }

  void updateKneeOverToe(bool value) {
    isKneeOverToe = value;
    value
        ? repErrors.remove(RepError.kneeOverToe)
        : repErrors.add(RepError.kneeOverToe);

    notifyListeners();
  }

  void clearKneeOverToe() {
    isKneeOverToe = null;
    repErrors.remove(RepError.kneeOverToe);

    notifyListeners();
  }

  void updateFootWideEnough(bool value) {
    isFootWideEnough = value;
    value
        ? repErrors.remove(RepError.feetWidth)
        : repErrors.add(RepError.feetWidth);

    notifyListeners();
  }

  void clearFootWideEnough() {
    isFootWideEnough = null;
    repErrors.remove(RepError.feetWidth);

    notifyListeners();
  }

  void updateFootOutwards(bool value) {
    isFootOutwards = value;
    value
        ? repErrors.remove(RepError.feetOutwards)
        : repErrors.add(RepError.feetOutwards);

    notifyListeners();
  }

  void clearFootOutwards() {
    isFootOutwards = null;
    repErrors.remove(RepError.feetOutwards);

    notifyListeners();
  }

  void clearAll() {
    currentPose = null;
    exercisePhase = null;
    sideView = null;
    exercise = null;
    isHeelGrounded = null;
    isHeepSymmetric = null;
    isTorsoUpright = null;
    isKneeOutwards = null;
    isKneeOverToe = null;
    isFootWideEnough = null;
    isFootOutwards = null;
    isReadytoDetect = false;
    isCameraDisposed = false;
    repErrors.clear();
  }

  void addRep(Rep rep) {
    exercise!.reps.add(rep);
    exercise!.totalReps += 1;
    rep.isWrong ? exercise!.wrongReps += 1 : exercise!.correctReps += 1;

    notifyListeners();
  }
}
