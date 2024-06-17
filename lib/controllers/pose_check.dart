import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:trainerproject/controllers/providers/pose_provider.dart';

class PoseCheck {
  // double? leftKneeAngle;
  // double? righKneeAngle;
  // bool? kneeCavingIn;
  // double? shoulderDistance;
  // double? kneeDistance;

  // double calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
  //   final ab = [b.x - a.x, b.y - a.y, b.z - a.z];
  //   final bc = [c.x - b.x, c.y - b.y, c.z - b.z];
  //   final dotProduct = ab[0] * bc[0] + ab[1] * bc[1] + ab[2] * bc[2];
  //   final magAB = sqrt(ab[0] * ab[0] + ab[1] * ab[1] + ab[2] * ab[2]);
  //   final magBC = sqrt(bc[0] * bc[0] + bc[1] * bc[1] + bc[2] * bc[2]);
  //   final cosAngle = dotProduct / (magAB * magBC);

  //   // Clamp the cosine value to the range [-1, 1] to avoid NaN due to floating point errors
  //   final clampedCosine = cosAngle.clamp(-1.0, 1.0);

  //   final angle = acos(clampedCosine) * (180.0 / pi);
  //   return angle;
  // }

  // double getLeftKneeAngle(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  //   final leftHip = landmarks[PoseLandmarkType.leftHip];
  //   final leftKnee = landmarks[PoseLandmarkType.leftKnee];
  //   final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];

  //   if (leftHip == null || leftKnee == null || leftAnkle == null) {
  //     // throw ArgumentError('Missing required landmarks');
  //     return 0;
  //   }

  //   leftKneeAngle = calculateAngleThreePoints(leftHip, leftKnee, leftAnkle);
  //   // notifyListeners();
  //   return leftKneeAngle!;
  // }

  // double getRightKneeAngle(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  //   final rightHip = landmarks[PoseLandmarkType.rightHip];
  //   final rightKnee = landmarks[PoseLandmarkType.rightKnee];
  //   final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

  //   if (rightHip == null || rightKnee == null || rightAnkle == null) {
  //     return 0;
  //   }

  //   righKneeAngle = calculateAngleThreePoints(rightHip, rightKnee, rightAnkle);
  //   // notifyListeners();
  //   return righKneeAngle!;
  // }

  // Function to calculate the angle between two vectors

  double _calculateAngleTwoPoints(PoseLandmark point1, PoseLandmark point2) {
    final aX = point1.x;
    final aY = point1.y;
    final bX = point2.x;
    final bY = point2.y;

    final dotProduct = aX * bX + aY * bY;
    final magnitudeA = sqrt(aX * aX + aY * aY);
    final magnitudeB = sqrt(bX * bX + bY * bY);

    final cosineAngle = dotProduct / (magnitudeA * magnitudeB);

    // Clamp the cosine value to the range [-1, 1] to avoid NaN due to floating point errors
    final clampedCosine = cosineAngle.clamp(-1.0, 1.0);

    return acos(clampedCosine) * (180 / pi);
  }

  // Function to calculate the angle between three vectors
  double _calculateAngleThreePoints(
      PoseLandmark point1, PoseLandmark point2, PoseLandmark point3) {
    final baX = point1.x - point2.x;
    final baY = point1.y - point2.y;
    final bcX = point3.x - point2.x;
    final bcY = point3.y - point2.y;

    final baLength = sqrt(baX * baX + baY * baY);
    final bcLength = sqrt(bcX * bcX + bcY * bcY);

    final dotProduct = (baX * bcX) + (baY * bcY);
    final cosineAngle = dotProduct / (baLength * bcLength);

    // Clamp the cosine value to the range [-1, 1] to avoid NaN due to floating point errors
    final clampedCosine = cosineAngle.clamp(-1.0, 1.0);

    return acos(clampedCosine) * (180 / pi);
  }

  double _calculateDistance(PoseLandmark point1, PoseLandmark point2) {
    final dx = point2.x - point1.x;
    final dy = point2.y - point1.y;
    return sqrt(dx * dx + dy * dy);
  }

  double _calculateHipTiltAngle(PoseLandmark leftHip, PoseLandmark rightHip) {
    double yDiff = (leftHip.y - rightHip.y).abs();
    double xDiff = (leftHip.x - rightHip.x).abs();

    double angleRadians = xDiff != 0 ? atan(yDiff / xDiff) : pi / 2;
    double angleDegrees = angleRadians * 180 / pi;

    // return angle degrees with up to 2 decimal places
    return double.parse((angleDegrees).toStringAsFixed(2));
  }

  bool isHipSymmetric(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    if (leftHip == null || rightHip == null) {
      return false;
    }
    final hipAngle = _calculateHipTiltAngle(leftHip, rightHip);

    return hipAngle <= 4;
  }

  bool isKneeOutwards(Map<PoseLandmarkType, PoseLandmark> landmarks,
      ExercisePhase exercisePhase) {
    if (exercisePhase == ExercisePhase.up) {
      // this.kneeCavingIn = false;
      // notifyListeners();
      return true;
    }
    // Get Positions
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    if (leftKnee == null ||
        rightKnee == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return false;
    }

    // Run Checks
    final kneeDistance = (leftKnee.x - rightKnee.x).abs();
    final shoulderDistance = (leftShoulder.x - rightShoulder.x).abs();
    // this.kneeDistance = kneeDistance;
    // this.shoulderDistance = shoulderDistance;

    final kneeCavingIn = kneeDistance < shoulderDistance * 1.5;
    // this.kneeCavingIn = kneeCavingIn;
    // notifyListeners();

    return !kneeCavingIn;
  }

  // Function to check feet position
  bool isFeetWidthOk(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftHeel = landmarks[PoseLandmarkType.leftHeel];
    final rightHeel = landmarks[PoseLandmarkType.rightHeel];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftKnee == null ||
        rightKnee == null ||
        leftHeel == null ||
        rightHeel == null ||
        leftAnkle == null ||
        rightAnkle == null) {
      return false;
    }

    // Calculate shoulder width
    // double shoulderWidth = calculateDistance(leftShoulder, rightShoulder);
    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();

    // Calculate feet distance
    // double feetDistance = calculateDistance(leftHeel, rightHeel);
    double feetDistance = (leftHeel.x - rightHeel.x).abs();

    // Check if feet distance is within an acceptable range of shoulder width (OK)
    bool isFeetWidthCorrect =
        (feetDistance > shoulderWidth) && (feetDistance < shoulderWidth * 3);

    return isFeetWidthCorrect;
  }

  bool isFeetOutwards(Map<PoseLandmarkType, PoseLandmark> landmarks,
      ExercisePhase exercisePhase) {
    if (exercisePhase == ExercisePhase.down) {
      return true;
    }
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftHeel = landmarks[PoseLandmarkType.leftHeel];
    final rightHeel = landmarks[PoseLandmarkType.rightHeel];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final leftFootIndex = landmarks[PoseLandmarkType.leftFootIndex];
    final rightFootIndex = landmarks[PoseLandmarkType.rightFootIndex];

    if (leftKnee == null ||
        rightKnee == null ||
        leftHeel == null ||
        rightHeel == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftFootIndex == null ||
        rightFootIndex == null) {
      return false;
    }

    double rightToeAngle =
        _calculateAngleThreePoints(rightKnee, rightHeel, rightFootIndex);

    double leftToeAngle =
        _calculateAngleThreePoints(leftKnee, leftHeel, leftFootIndex);

    // Check if toes are slightly pointed out (angle between 130 to 160 degrees)
    bool isLeftToeAngleCorrect = (leftToeAngle > 100 && leftToeAngle < 150);
    bool isRightToeAngleCorrect = (rightToeAngle > 100 && rightToeAngle < 150);

    // print("Salam1: " +
    //     double.parse((rightToeAngle).toStringAsFixed(2)).toString());
    // print("Salam2: " +
    //     double.parse((rightToeAngle).toStringAsFixed(2)).toString());

    return isLeftToeAngleCorrect && isRightToeAngleCorrect;
  }

  bool isHeelGrounded(Map<PoseLandmarkType, PoseLandmark> landmarks,
      ExercisePhase exercisePhase, SideView sideView) {
    if (exercisePhase == ExercisePhase.up) {
      return true;
    }
    final leftHeel = landmarks[PoseLandmarkType.leftHeel];
    final rightHeel = landmarks[PoseLandmarkType.rightHeel];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final leftFootIndex = landmarks[PoseLandmarkType.leftFootIndex];
    final rightFootIndex = landmarks[PoseLandmarkType.rightFootIndex];

    if (leftHeel == null ||
        rightHeel == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftFootIndex == null ||
        rightFootIndex == null) {
      return false;
    }

    late final PoseLandmark selectedHeel;
    late final PoseLandmark selectedAnkle;
    late final PoseLandmark selectedFootIndex;

    if (sideView == SideView.left) {
      selectedHeel = leftHeel;
      selectedAnkle = leftAnkle;
      selectedFootIndex = leftFootIndex;
    } else {
      selectedHeel = rightHeel;
      selectedAnkle = rightAnkle;
      selectedFootIndex = rightFootIndex;
    }

    double heelAnkleDistance = _calculateDistance(selectedHeel, selectedAnkle);
    double heelToeYDistance = (selectedHeel.y - selectedFootIndex.y).abs();

    return heelToeYDistance <= heelAnkleDistance * 1.1;
  }

  // Function to calculate the angle between two points and the vertical axis
  double _calculateTorsoAngle(PoseLandmark shoulder, PoseLandmark hip) {
    // Calculate the difference in x and y coordinates
    double deltaX = shoulder.x - hip.x;
    double deltaY = shoulder.y - hip.y; // y increases downwards

    // Calculate the angle in radians
    double angleRadians = atan2(deltaX, deltaY);

    // Convert angle to degrees
    double angleDegrees = angleRadians * (180 / pi);

    // The angle is relative to the vertical, so we take the absolute value
    return angleDegrees.abs();
  }

  // Function to check if the torso angle is less than 45 degrees
  bool isTorsoAngleCorrect(
      Map<PoseLandmarkType, PoseLandmark> landmarks, SideView sideView) {
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (leftHip == null ||
        rightHip == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return false;
    }

    late final PoseLandmark selectedHip;
    late final PoseLandmark selectedShoulder;

    if (sideView == SideView.left) {
      selectedHip = leftHip;
      selectedShoulder = leftShoulder;
    } else {
      selectedHip = rightHip;
      selectedShoulder = rightShoulder;
    }

    double angle = _calculateTorsoAngle(selectedShoulder, selectedHip);
    return angle > 130;
  }

  bool isKneeOverToe(
      Map<PoseLandmarkType, PoseLandmark> landmarks, SideView sideView) {
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftFootIndex = landmarks[PoseLandmarkType.leftFootIndex];
    final rightFootIndex = landmarks[PoseLandmarkType.rightFootIndex];

    if (leftKnee == null ||
        rightKnee == null ||
        leftFootIndex == null ||
        rightFootIndex == null) {
      return false;
    }

    if (sideView == SideView.left) {
      return leftKnee.x > leftFootIndex.x * 0.9;
    } else {
      return rightKnee.x < rightFootIndex.x * 1.1;
    }
  }
}
