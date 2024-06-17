import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

class CameraProvider extends ChangeNotifier {
  // bool isReadytoDetect = false;
  CameraController? cameraController;

  // void setReadytoDetect(bool value) {
  //   isReadytoDetect = value;
  //   notifyListeners();
  // }

  void setCameraController(CameraController? controller) {
    cameraController = controller;
    notifyListeners();
  }
}
