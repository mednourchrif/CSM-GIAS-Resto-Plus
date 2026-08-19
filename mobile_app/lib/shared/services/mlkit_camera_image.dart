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

  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    if (format != InputImageFormat.bgra8888 || image.planes.length != 1) {
      return null;
    }
  } else if (defaultTargetPlatform != TargetPlatform.android) {
    return null;
  }

  final bytes = defaultTargetPlatform == TargetPlatform.android
      ? _androidNv21Bytes(image)
      : image.planes.first.bytes;
  if (bytes == null) return null;

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
        format: defaultTargetPlatform == TargetPlatform.android
            ? InputImageFormat.nv21
            : format!,
        bytesPerRow: defaultTargetPlatform == TargetPlatform.android
            ? image.width
            : image.planes.first.bytesPerRow,
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

  final deviceRotation = _orientations[deviceOrientation] ?? 0;
  final compensation = camera.lensDirection == CameraLensDirection.front
      ? (sensorOrientation + deviceRotation) % 360
      : (sensorOrientation - deviceRotation + 360) % 360;
  return InputImageRotation.values.cast<InputImageRotation?>().firstWhere(
    (rotation) => rotation?.rawValue == compensation,
    orElse: () => null,
  );
}

Uint8List? _androidNv21Bytes(CameraImage image) {
  if (image.planes.isEmpty) return null;
  if (image.planes.length == 1) {
    final plane = image.planes.first;
    if (plane.bytes.isEmpty) return null;
    return plane.bytes;
  }
  if (image.planes.length < 3) return null;

  final width = image.width;
  final height = image.height;
  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];
  final output = Uint8List(width * height + (width * height ~/ 2));
  var offset = 0;

  for (var row = 0; row < height; row++) {
    final rowStart = row * yPlane.bytesPerRow;
    for (var col = 0; col < width; col++) {
      final index = rowStart + col * (yPlane.bytesPerPixel ?? 1);
      if (index >= yPlane.bytes.length) return null;
      output[offset++] = yPlane.bytes[index];
    }
  }

  for (var row = 0; row < height ~/ 2; row++) {
    final uRowStart = row * uPlane.bytesPerRow;
    final vRowStart = row * vPlane.bytesPerRow;
    for (var col = 0; col < width; col += 2) {
      final uIndex = uRowStart + (col ~/ 2) * (uPlane.bytesPerPixel ?? 1);
      final vIndex = vRowStart + (col ~/ 2) * (vPlane.bytesPerPixel ?? 1);
      if (uIndex >= uPlane.bytes.length || vIndex >= vPlane.bytes.length) {
        return null;
      }
      output[offset++] = vPlane.bytes[vIndex];
      output[offset++] = uPlane.bytes[uIndex];
    }
  }
  return output;
}
