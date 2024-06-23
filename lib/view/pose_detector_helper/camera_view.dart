import 'dart:io';
// import 'dart:js_interop';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:provider/provider.dart';
import 'package:trainerproject/controllers/providers/camera_provider.dart';
import 'package:trainerproject/controllers/providers/pose_provider.dart';

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.customPaint,
      required this.onImage,
      // required this.camera,
      // required this.controller,
      this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.front})
      : super(key: key);

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;
  // final CameraDescription? camera;
  // final CameraController? controller;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraDescription? _camera;
  CameraController? _controller;
  // int _cameraIndex = -1;

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    _initialize();
    // });
    super.initState();
  }

  void _initialize() async {
    if (_camera == null) {
      // put the front camera in _camera
      final cameras = await availableCameras();
      _camera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);
    }
    // for (var i = 0; i < _cameras.length; i++) {
    //   if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
    //     _cameraIndex = i;
    //     break;
    //   }
    // }
    // if (_cameraIndex != -1) {
    if (_camera != null) {
      print("live kardam 0");
      _startLiveFeed();
    }

    // }
  }

  // void _initialize() {
  //   print("live kardam 0");
  //   _camera = widget.camera;
  //   _controller = widget.controller;
  //   print("live kardam 1");

  //   if (_camera != null) {
  //     print("live kardam 2");
  //     _startLiveFeed();
  //   }
  // }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_camera == null) {
      return const Center(
        child: Text("No Camera is detected"),
      );
    }
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    var camera = _controller!.value;
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Center(
      child: Stack(fit: StackFit.expand, children: [
        RotatedBox(
          quarterTurns: -1,
          child: Transform.flip(
            flipY: true,
            child: AspectRatio(
              aspectRatio: camera.aspectRatio,
              child: CameraPreview(
                _controller!,
                child: Transform.flip(
                  flipY: true,
                  child: RotatedBox(
                    child: widget.customPaint,
                    quarterTurns: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );

    // return ColoredBox(
    //   color: Colors.black,
    //   child: Stack(
    //     fit: StackFit.expand,
    //     children: <Widget>[
    //       Center(
    //         child: CameraPreview(
    //           _controller!,
    //           child: widget.customPaint,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Future _startLiveFeed() async {
    final camera = _camera;
    _controller = CameraController(
      camera!,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    context.read<CameraProvider>().setCameraController(_controller);
    _controller?.initialize().then((_) {
      print("live kardam 1");
      if (!mounted) {
        return;
      }

      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    if (mounted && !context.read<PoseProvider>().isCameraDisposed) {
      context.read<PoseProvider>().setCameraDisposed(true);
      await _controller?.dispose();
    }
    // if (!_controller!.value.isTakingPicture) {

    // }
    _controller = null;
  }

  // Future _switchLiveCamera() async {
  //   setState(() => _changingCameraLens = true);
  //   _cameraIndex = (_cameraIndex + 1) % _cameras.length;

  //   await _stopLiveFeed();
  //   await _startLiveFeed();
  //   setState(() => _changingCameraLens = false);
  // }

  DeviceOrientation _getApplicableOrientation() {
    return _controller!.value.isRecordingVideo
        ? _controller!.value.recordingOrientation!
        : (_controller!.value.previewPauseOrientation ??
            _controller!.value.lockedCaptureOrientation ??
            _controller!.value.deviceOrientation);
  }

  void _processCameraImage(CameraImage image) {
    print("live kardam 2 ${_getApplicableOrientation()}");
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    // if (context.watch<CameraProvider>().isReadytoDetect) {
    widget.onImage(inputImage);
    // }
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _camera!;
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}
