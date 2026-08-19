import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../employees/domain/entities/employee.dart';
import '../../domain/entities/face_enrollment_data.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../providers/face_enrollment_provider.dart';
import '../providers/face_enrollment_state.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/services/mlkit_camera_image.dart';

class FaceEnrollmentScreen extends ConsumerStatefulWidget {
  final Employee employee;

  const FaceEnrollmentScreen({super.key, required this.employee});

  @override
  ConsumerState<FaceEnrollmentScreen> createState() =>
      _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends ConsumerState<FaceEnrollmentScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isCameraInitialized = false;
  int _captureCount = 0;
  bool _isFaceDetected = false;
  bool _isStable = false;
  String _guidanceMessage = 'Placez votre visage dans le cadre';
  Timer? _stabilityTimer;
  Timer? _captureCooldown;
  bool _canCapture = true;
  bool _isDetectingFrame = false;
  bool _isDisposed = false;

  static const int _minImages = 3;
  static const int _maxImages = 5;
  static const Duration _stabilityDuration = Duration(milliseconds: 500);
  static const Duration _captureCooldownDuration = Duration(seconds: 1);
  static const double _centerThreshold = 0.2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _faceDetector = FaceDetector(options: FaceDetectorOptions());
    _initializeCamera();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stabilityTimer?.cancel();
    _captureCooldown?.cancel();
    _faceDetector?.close();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _resumeCamera();
    } else if (state == AppLifecycleState.paused) {
      _cameraController?.stopImageStream();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final appSettings = ref.read(appSettingsProvider);
      _cameraController = CameraController(
        frontCamera,
        appSettings.resolutionPreset,
        enableAudio: false,
        imageFormatGroup: mlKitCameraImageFormatGroup,
      );

      await _cameraController!.initialize();
      await _cameraController!.startImageStream(_processImage);

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _guidanceMessage = 'Erreur d\'accès à la caméra';
        });
      }
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isDisposed ||
        _isDetectingFrame ||
        !_canCapture ||
        _captureCount >= _maxImages) {
      return;
    }
    final controller = _cameraController;
    final detector = _faceDetector;
    if (controller == null || detector == null) return;

    _isDetectingFrame = true;
    try {
      final frame = createMlKitCameraFrame(image, controller);
      if (frame == null) return;
      final faces = await detector.processImage(frame.inputImage);
      if (_isDisposed || !mounted || !_canCapture) return;
      if (faces.isEmpty) {
        _onNoFace();
      } else if (faces.length > 1) {
        _onMultipleFaces();
      } else {
        _onSingleFace(faces.first, frame.rotatedSize);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _guidanceMessage = 'Erreur de détection: $error');
      }
    } finally {
      _isDetectingFrame = false;
    }
  }

  Future<void> _resumeCamera() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.resumePreview();
    if (!controller.value.isStreamingImages && _canCapture) {
      await controller.startImageStream(_processImage);
    }
  }

  void _onNoFace() {
    _isFaceDetected = false;
    _isStable = false;
    _stabilityTimer?.cancel();
    setState(() => _guidanceMessage = 'Aucun visage détecté');
  }

  void _onMultipleFaces() {
    _isFaceDetected = false;
    _isStable = false;
    _stabilityTimer?.cancel();
    setState(() => _guidanceMessage = 'Plus d\'un visage détecté');
  }

  void _onSingleFace(Face face, Size imageSize) {
    if (!_isFaceDetected) {
      _isFaceDetected = true;
      setState(
        () => _guidanceMessage = 'Visage détecté, maintenez la position',
      );
    }

    final box = face.boundingBox;
    final centerX = box.left + box.width / 2;
    final centerY = box.top + box.height / 2;
    final normX = centerX / imageSize.width;
    final normY = centerY / imageSize.height;

    final isCentered =
        (normX - 0.5).abs() < _centerThreshold &&
        (normY - 0.5).abs() < _centerThreshold;

    if (!isCentered) {
      _isStable = false;
      _stabilityTimer?.cancel();
      setState(() => _guidanceMessage = 'Centre votre visage');
      return;
    }

    setState(() => _guidanceMessage = 'Parfait, maintenez...');

    if (!_isStable) {
      _isStable = true;
      _stabilityTimer?.cancel();
      _stabilityTimer = Timer(_stabilityDuration, () {
        if (!mounted || !_canCapture) return;
        _captureImage();
      });
    }
  }

  Future<void> _captureImage() async {
    if (!_canCapture || _captureCount >= _maxImages) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _canCapture = false;
    _stabilityTimer?.cancel();

    try {
      HapticFeedback.heavyImpact();
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
      final file = await _cameraController!.takePicture();

      if (!mounted) return;

      ref.read(faceEnrollmentProvider.notifier).addImage(file.path);
      _captureCount++;

      setState(() {
        _guidanceMessage = 'Image $_captureCount / $_minImages capturée';
      });

      if (_captureCount >= _minImages) {
        _canCapture = false;
        ref.read(faceEnrollmentProvider.notifier).goToPreview();
        return;
      }

      _captureCooldown?.cancel();
      _captureCooldown = Timer(_captureCooldownDuration, () async {
        if (mounted && !_isDisposed) {
          if (!(_cameraController?.value.isStreamingImages ?? false)) {
            await _cameraController?.startImageStream(_processImage);
          }
          _canCapture = true;
          _isStable = false;
        }
      });
    } catch (e) {
      if (mounted) {
        _canCapture = true;
        setState(() => _guidanceMessage = 'Erreur de capture, réessayez');
        if (!(_cameraController?.value.isStreamingImages ?? false)) {
          await _cameraController?.startImageStream(_processImage);
        }
      }
    }
  }

  Future<void> _retakeAll() async {
    _captureCount = 0;
    _canCapture = true;
    _isStable = false;
    _isFaceDetected = false;
    _stabilityTimer?.cancel();
    _captureCooldown?.cancel();
    ref.read(faceEnrollmentProvider.notifier).reset();
    if (!(_cameraController?.value.isStreamingImages ?? false)) {
      await _cameraController?.startImageStream(_processImage);
    }
    setState(() {
      _isCameraInitialized = true;
      _guidanceMessage = 'Placez votre visage dans le cadre';
    });
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentState = ref.watch(faceEnrollmentProvider);
    final theme = Theme.of(context);

    if (enrollmentState.step == EnrollmentStep.preview ||
        enrollmentState.step == EnrollmentStep.uploading ||
        enrollmentState.step == EnrollmentStep.done ||
        enrollmentState.step == EnrollmentStep.error) {
      return _buildReviewScreen(context, theme, enrollmentState);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized && _cameraController != null
          ? Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CameraPreview(_cameraController!),
                ),
                _buildCameraOverlay(theme),
                Positioned(
                  top: MediaQuery.of(context).padding.top + Spacing.md,
                  left: Spacing.md,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + Spacing.md,
                  right: Spacing.md,
                  child: SafeArea(
                    child: Column(children: [_buildProgressIndicator(theme)]),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg,
                          vertical: Spacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(Spacing.radiusMd),
                        ),
                        child: Text(
                          _guidanceMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      Text(
                        '$_captureCount / $_minImages',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_captureCount >= _minImages)
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FilledButton.icon(
                        onPressed: () {
                          _cameraController?.stopImageStream();
                          ref
                              .read(faceEnrollmentProvider.notifier)
                              .goToPreview();
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Continuer'),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildCameraOverlay(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    final scanSize = size.width * 0.75;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2 - 30;

    return CustomPaint(
      size: size,
      painter: _FaceOverlayPainter(
        scanRect: Rect.fromLTWH(left, top, scanSize, scanSize),
        isDetected: _isFaceDetected,
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    final progress = _captureCount / _minImages;
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: 3,
                color: _captureCount >= _minImages
                    ? AppColors.success
                    : Colors.white,
                backgroundColor: Colors.white24,
              ),
              Text(
                '$_captureCount',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewScreen(
    BuildContext context,
    ThemeData theme,
    FaceEnrollmentState state,
  ) {
    final images = state.capturedImages;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.step == EnrollmentStep.uploading
              ? 'Envoi en cours...'
              : state.step == EnrollmentStep.done
              ? 'Enrôlement terminé'
              : 'Aperçu des images',
        ),
        automaticallyImplyLeading: state.step != EnrollmentStep.done,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          children: [
            if (state.step == EnrollmentStep.uploading) ...[
              LinearProgressIndicator(value: state.uploadProgress),
              const SizedBox(height: Spacing.md),
              Text(
                'Envoi de ${images.length} images...',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: Spacing.lg),
            ],
            if (state.step == EnrollmentStep.done) ...[
              const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: AppColors.success,
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'Enrôlement facial réussi',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                '${state.result?.imagesUploaded ?? images.length} image(s) envoyée(s)',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: Spacing.xxl),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Terminer'),
              ),
            ],
            if (state.step == EnrollmentStep.error) ...[
              Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'Erreur',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                state.errorMessage ?? 'Une erreur est survenue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(faceEnrollmentProvider.notifier).goToPreview();
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Retour'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _uploadImages(context),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Réessayer'),
                    ),
                  ),
                ],
              ),
            ],
            if (state.step == EnrollmentStep.preview) ...[
              Expanded(child: _buildImageGrid(images, theme)),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _retakeAll,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tout reprendre'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: images.length >= _minImages
                          ? () => _uploadImages(context)
                          : null,
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: Text('Envoyer (${images.length})'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<CapturedImage> images, ThemeData theme) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: Spacing.sm,
        mainAxisSpacing: Spacing.sm,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              child: Image.file(File(image.filePath), fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => ref
                    .read(faceEnrollmentProvider.notifier)
                    .removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(Spacing.radiusXs),
                ),
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImages(BuildContext context) async {
    await ref
        .read(faceEnrollmentProvider.notifier)
        .uploadImages(widget.employee.uuid);
  }
}

class _FaceOverlayPainter extends CustomPainter {
  final Rect scanRect;
  final bool isDetected;

  _FaceOverlayPainter({required this.scanRect, required this.isDetected});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(
            scanRect,
            const Radius.circular(Spacing.radiusMd),
          ),
        ),
      ),
      overlayPaint,
    );

    final borderColor = isDetected ? AppColors.success : Colors.white;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        scanRect,
        const Radius.circular(Spacing.radiusMd),
      ),
      borderPaint,
    );

    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const cornerLength = 24.0;

    canvas.drawLine(
      scanRect.topLeft,
      Offset(scanRect.left + cornerLength, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      scanRect.topLeft,
      Offset(scanRect.left, scanRect.top + cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      scanRect.topRight,
      Offset(scanRect.right - cornerLength, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      scanRect.topRight,
      Offset(scanRect.right, scanRect.top + cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      scanRect.bottomLeft,
      Offset(scanRect.left + cornerLength, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      scanRect.bottomLeft,
      Offset(scanRect.left, scanRect.bottom - cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      scanRect.bottomRight,
      Offset(scanRect.right - cornerLength, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      scanRect.bottomRight,
      Offset(scanRect.right, scanRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(_FaceOverlayPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect || oldDelegate.isDetected != isDetected;
}
