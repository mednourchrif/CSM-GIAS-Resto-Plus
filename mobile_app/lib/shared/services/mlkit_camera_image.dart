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

  Uint8List bytes;
  InputImageFormat format;
  int bytesPerRow;

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;
    bytes = plane.bytes;
    bytesPerRow = plane.bytesPerRow;
    format = InputImageFormat.bgra8888;
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    if (image.planes.length == 1) {
      final plane = image.planes.first;
      bytes = plane.bytes;
      bytesPerRow = plane.bytesPerRow;
    } else if (image.planes.length >= 3) {
      bytes = _yuv420ToNv21(image);
      bytesPerRow = image.width;
    } else {
      return null;
    }
    format = InputImageFormat.nv21;
  } else {
    return null;
  }

  final swapsDimensions =
      rotation == InputImageRotation.rotation90deg ||
      rotation == InputImageRotation.rotation270deg;
  final rotatedSize = swapsDimensions
      ? Size(image.height.toDouble(), image.width.toDouble())
      : Size(image.width.toDouble(), image.height.toDouble());

  return MlKitCameraFrame(
    inputImage: InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: bytesPerRow,
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

Uint8List _yuv420ToNv21(CameraImage image) {
  final width = image.width;
  final height = image.height;
  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];
  final output = Uint8List(width * height + (width * height ~/ 2));

  final yPixelStride = yPlane.bytesPerPixel ?? 1;
  var outputIndex = 0;
  for (var row = 0; row < height; row++) {
    final rowStart = row * yPlane.bytesPerRow;
    for (var column = 0; column < width; column++) {
      output[outputIndex++] = yPlane.bytes[rowStart + column * yPixelStride];
    }
  }

  final uPixelStride = uPlane.bytesPerPixel ?? 1;
  final vPixelStride = vPlane.bytesPerPixel ?? 1;
  for (var row = 0; row < height ~/ 2; row++) {
    final uRowStart = row * uPlane.bytesPerRow;
    final vRowStart = row * vPlane.bytesPerRow;
    for (var column = 0; column < width ~/ 2; column++) {
      output[outputIndex++] = vPlane.bytes[vRowStart + column * vPixelStride];
      output[outputIndex++] = uPlane.bytes[uRowStart + column * uPixelStride];
    }
  }
  return output;
}
