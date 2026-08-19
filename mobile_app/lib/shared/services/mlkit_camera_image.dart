import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

const _orientations = <DeviceOrientation, int>{
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

ImageFormatGroup get mlKitCameraImageFormatGroup =>
    defaultTargetPlatform == TargetPlatform.iOS
    ? ImageFormatGroup.bgra8888
    : ImageFormatGroup.nv21;

class MlKitCameraFrame {
  final InputImage inputImage;
  final Size rotatedSize;

  const MlKitCameraFrame({required this.inputImage, required this.rotatedSize});
}

MlKitCameraFrame? createMlKitCameraFrame(
  CameraImage image,
  CameraController controller,
) {
  final camera = controller.description;
  final rotation = _rotationFor(camera, controller.value.deviceOrientation);
  if (rotation == null) return null;

  if (image.planes.length != 1) return null;

  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null ||
      (defaultTargetPlatform == TargetPlatform.android &&
          format != InputImageFormat.nv21) ||
      (defaultTargetPlatform == TargetPlatform.iOS &&
          format != InputImageFormat.bgra8888)) {
    return null;
  }
  final plane = image.planes.first;

  final swapsDimensions =
      rotation == InputImageRotation.rotation90deg ||
      rotation == InputImageRotation.rotation270deg;
  final rotatedSize = swapsDimensions
      ? Size(image.height.toDouble(), image.width.toDouble())
      : Size(image.width.toDouble(), image.height.toDouble());

  return MlKitCameraFrame(
    inputImage: InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    ),
    rotatedSize: rotatedSize,
  );
}

InputImageRotation? _rotationFor(
  CameraDescription camera,
  DeviceOrientation deviceOrientation,
) {
  final sensorOrientation = camera.sensorOrientation;
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return InputImageRotation.values.cast<InputImageRotation?>().firstWhere(
      (rotation) => rotation?.rawValue == sensorOrientation,
      orElse: () => null,
    );
  }
  if (defaultTargetPlatform != TargetPlatform.android) return null;

  final deviceRotation = _orientations[deviceOrientation];
  if (deviceRotation == null) return null;
  final compensation = camera.lensDirection == CameraLensDirection.front
      ? (sensorOrientation + deviceRotation) % 360
      : (sensorOrientation - deviceRotation + 360) % 360;
  return InputImageRotation.values.cast<InputImageRotation?>().firstWhere(
    (rotation) => rotation?.rawValue == compensation,
    orElse: () => null,
  );
}
