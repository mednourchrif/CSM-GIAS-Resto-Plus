import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../admin/settings/presentation/providers/app_settings_provider.dart';
import '../../../face_recognition/presentation/providers/face_recognition_provider.dart';
import '../../../face_recognition/presentation/widgets/face_scan_overlay.dart';
import '../../../identification/domain/entities/identification_grant.dart';
import '../../../identification/presentation/providers/identification_provider.dart';
import '../../../identification/presentation/providers/kiosk_flow_provider.dart';
import '../../../../shared/services/mlkit_camera_image.dart';

class KioskCameraScreen extends ConsumerStatefulWidget {
  const KioskCameraScreen({super.key});

  @override
  ConsumerState<KioskCameraScreen> createState() => _KioskCameraScreenState();
}

class _KioskCameraScreenState extends ConsumerState<KioskCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = const [];
  CameraDescription? _selectedCamera;
  FaceDetector? _faceDetector;
  BarcodeScanner? _barcodeScanner;

  bool _isCameraInitialized = false;
  String? _cameraError;
  bool _isProcessing = false;
  bool _isDetectingFrame = false;
  bool _isSwitchingCamera = false;
  bool _isDisposed = false;

  bool _faceEnabled = true;
  bool _qrEnabled = true;

  // ─── Face tracking ───────────────────────────────────────────────────────
  bool _isFaceDetected = false;
  bool _isStable = false;
  String _guidanceMessage = '';
  Timer? _stabilityTimer;
  bool _canCapture = true;
  bool _faceCooldown = false;
  int _recognitionAttempts = 0;
  Timer? _faceCooldownTimer;

  static const Duration _stabilityDuration = Duration(milliseconds: 1000);
  static const double _centerThreshold = 0.2;
  static const Duration _faceCooldownDuration = Duration(seconds: 5);

  // ─── Timeout ─────────────────────────────────────────────────────────────
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final appSettings = ref.read(appSettingsProvider);
    _faceEnabled = appSettings.faceRecognitionEnabled;
    _qrEnabled = appSettings.qrValidationEnabled;

    _faceDetector = FaceDetector(options: FaceDetectorOptions());
    if (_qrEnabled) {
      _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
    }
    _initializeCamera();
    _startTimeout();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_guidanceMessage.isEmpty) {
      _guidanceMessage = AppStrings.of(context).placeFace;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stabilityTimer?.cancel();
    _timeoutTimer?.cancel();
    _faceCooldownTimer?.cancel();

    _faceDetector?.close();
    _barcodeScanner?.close();
    _stopCameraStream();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _resumeScanning();
    } else if (state == AppLifecycleState.paused) {
      // A successful face/QR request sets `_isProcessing` and immediately
      // navigates to the meal-selection screen. Android can emit a transient
      // paused event while the camera surface is being released; clearing
      // the grant here would make the home screen fall back to kiosk mode.
      // Keep the grant during that handoff and let the destination/expiry
      // logic own its lifecycle cleanup.
      if (!_isProcessing) {
        ref.read(resetKioskFlowProvider)();
      }
      _cameraController?.stopImageStream();
    }
  }

  Future<void> _resumeScanning() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.resumePreview();
      if (!controller.value.isStreamingImages && !_isProcessing) {
        await controller.startImageStream(_processImage);
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('KioskCamera: error resuming camera: $error');
      }
    }
  }

  // ─── Camera init ─────────────────────────────────────────────────────────

  Future<void> _initializeCamera() async {
    try {
      _availableCameras = await availableCameras();
      final preferredCamera = _availableCameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _availableCameras.first,
      );
      await _openCamera(preferredCamera);
    } catch (error) {
      _handleCameraError(error);
    }
  }

  Future<void> _openCamera(CameraDescription camera) async {
    final appSettings = ref.read(appSettingsProvider);
    final controller = CameraController(
      camera,
      appSettings.resolutionPreset,
      enableAudio: false,
      imageFormatGroup: mlKitCameraImageFormatGroup,
    );
    _cameraController = controller;
    _selectedCamera = camera;

    await controller.initialize();
    if (_isDisposed || !mounted) {
      await controller.dispose();
      return;
    }
    await controller.startImageStream(_processImage);

    setState(() {
      _isCameraInitialized = true;
      _cameraError = null;
      _guidanceMessage = AppStrings.of(context).placeFace;
    });
  }

  void _handleCameraError(Object error) {
    if (kDebugMode) {
      debugPrint('KioskCamera: camera initialization failed: $error');
    }
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
        _cameraError = AppStrings.of(context).cameraAccessError;
        _guidanceMessage = AppStrings.of(context).cameraAccessErrorShort;
      });
    }
  }

  bool get _canSwitchCamera {
    final current = _selectedCamera;
    if (current == null) return false;
    return _availableCameras.any(
      (camera) => camera.lensDirection != current.lensDirection,
    );
  }

  Future<void> _switchCamera() async {
    if (_isSwitchingCamera || _isProcessing || !_canSwitchCamera) return;
    final current = _selectedCamera;
    if (current == null) return;
    final target = _availableCameras.firstWhere(
      (camera) => camera.lensDirection != current.lensDirection,
    );

    _isSwitchingCamera = true;
    _isProcessing = true;
    _canCapture = false;
    _stabilityTimer?.cancel();
    _timeoutTimer?.cancel();
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
        _guidanceMessage = AppStrings.of(context).switchingCamera;
      });
    }

    final previousController = _cameraController;
    try {
      if (previousController?.value.isStreamingImages ?? false) {
        await previousController!.stopImageStream();
      }
      await previousController?.dispose();
      _cameraController = null;
      await _openCamera(target);
      _isProcessing = false;
      _canCapture = true;
      _isStable = false;
      _isFaceDetected = false;
      _startTimeout();
    } catch (error) {
      _handleCameraError(error);
    } finally {
      _isSwitchingCamera = false;
      if (!_isCameraInitialized) {
        _isProcessing = false;
      }
    }
  }

  Future<void> _stopCameraStream() async {
    try {
      final controller = _cameraController;
      if (controller != null && controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('KioskCamera: error stopping camera stream: $error');
      }
    }
  }

  // ─── Image processing ────────────────────────────────────────────────────

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing || _isDetectingFrame || !_canCapture || _isDisposed) {
      return;
    }
    final controller = _cameraController;
    if (controller == null) return;

    _isDetectingFrame = true;
    try {
      final frame = createMlKitCameraFrame(image, controller);
      if (frame == null) return;

      // QR has priority so a face in the background cannot starve scanning.
      if (_qrEnabled && await _detectBarcode(frame.inputImage)) return;
      if (!_faceEnabled || _faceCooldown || _faceDetector == null) return;

      final faces = await _faceDetector!.processImage(frame.inputImage);
      if (_isDisposed || _isProcessing || !_canCapture) return;
      if (faces.isEmpty) {
        _onNoFace();
      } else if (faces.length > 1) {
        _onMultipleFaces();
      } else {
        _onSingleFace(faces.first, frame.rotatedSize);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('KioskCamera: error processing image: $e');
      }
    } finally {
      _isDetectingFrame = false;
    }
  }

  // ─── Face detection handlers ─────────────────────────────────────────────

  void _onNoFace() {
    if (_isFaceDetected) {
      _isFaceDetected = false;
      _isStable = false;
      _stabilityTimer?.cancel();
    }
    setState(() => _guidanceMessage = AppStrings.of(context).noFaceDetected);
  }

  void _onMultipleFaces() {
    _isFaceDetected = false;
    _isStable = false;
    _stabilityTimer?.cancel();
    setState(
      () => _guidanceMessage = AppStrings.of(context).multipleFacesDetected,
    );
  }

  void _onSingleFace(Face face, Size imageSize) {
    _timeoutTimer?.cancel();

    if (!_isFaceDetected) {
      _isFaceDetected = true;
      setState(() => _guidanceMessage = AppStrings.of(context).holdPosition);
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
      setState(() => _guidanceMessage = AppStrings.of(context).centerFace);
      return;
    }

    setState(() => _guidanceMessage = AppStrings.of(context).doNotMove);

    if (!_isStable) {
      _isStable = true;
      _stabilityTimer?.cancel();
      _stabilityTimer = Timer(_stabilityDuration, () {
        if (_isDisposed || _isProcessing || !_canCapture) return;
        _captureAndIdentify();
      });
    }
  }

  // ─── Face capture & identify ─────────────────────────────────────────────

  Future<void> _captureAndIdentify() async {
    if (_isProcessing || !_canCapture) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _isProcessing = true;
    _canCapture = false;
    _stabilityTimer?.cancel();
    _timeoutTimer?.cancel();

    try {
      HapticFeedback.heavyImpact();
      await _stopCameraStream();
      final file = await _cameraController!.takePicture();
      if (_isDisposed || !mounted) return;

      setState(() => _guidanceMessage = AppStrings.of(context).identifying);

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUri = 'data:image/jpeg;base64,$base64Image';

      final result = await ref
          .read(faceRecognitionProvider.notifier)
          .identify(imageBase64: dataUri);

      if (_isDisposed || !mounted) return;

      if (result != null && result.isMatch) {
        final token = result.identificationToken;
        final expiresAt = result.identificationExpiresAt;
        if (token == null || token.isEmpty || expiresAt == null) {
          _showError(AppStrings.of(context).invalidIdentificationProof);
          return;
        }
        _completeIdentification(
          IdentificationGrant(
            token: token,
            type: result.type ?? 'FACE',
            expiresAt: expiresAt,
          ),
        );
      } else if (result == null) {
        final error = ref.read(faceRecognitionProvider).error;
        _showError(error ?? AppStrings.of(context).identificationFailure);
      } else {
        _onFaceNotRecognized();
      }
    } catch (e) {
      if (_isDisposed || !mounted) return;
      _showError(AppStrings.of(context).identificationFailure);
    }
  }

  void _onFaceNotRecognized() {
    _recognitionAttempts++;
    final maxAttempts = ref.read(appSettingsProvider).maxRecognitionAttempts;
    if (_recognitionAttempts >= maxAttempts) {
      _showError(
        AppStrings.of(context).faceNotRecognized(maxAttempts),
        allowRetry: false,
      );
      return;
    }
    _faceCooldown = true;
    _faceCooldownTimer?.cancel();
    _faceCooldownTimer = Timer(_faceCooldownDuration, () {
      if (_isDisposed) return;
      _faceCooldown = false;
    });

    _restartScanning();
  }

  // ─── QR / Barcode detection ──────────────────────────────────────────────

  Future<bool> _detectBarcode(InputImage inputImage) async {
    if (_isProcessing || !_canCapture || !_qrEnabled) return false;
    if (_barcodeScanner == null) return false;

    try {
      final barcodes = await _barcodeScanner!.processImage(inputImage);
      if (_isDisposed || !mounted || _isProcessing || !_canCapture) {
        return false;
      }

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        final qrToken = barcode.rawValue;
        if (qrToken != null && qrToken.isNotEmpty) {
          _timeoutTimer?.cancel();
          _isProcessing = true;
          _canCapture = false;
          _stopCameraStream();
          setState(() => _guidanceMessage = AppStrings.of(context).qrDetected);
          await _identifyByQr(qrToken);
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('KioskCamera: error detecting barcode: $e');
      }
    }
    return false;
  }

  // ─── Meal registration ───────────────────────────────────────────────────

  Future<void> _identifyByQr(String qrToken) async {
    setState(() => _guidanceMessage = AppStrings.of(context).validatingQr);
    final result = await ref
        .read(identificationRepositoryProvider)
        .identifyByQr(qrToken);
    if (_isDisposed || !mounted) return;

    result.when(
      success: _completeIdentification,
      failure: (failure) => _showError(failure.message),
    );
  }

  void _completeIdentification(IdentificationGrant grant) {
    if (_isDisposed || !mounted) return;
    ref.read(resetKioskMealSelectionProvider)();
    ref.read(pendingIdentificationProvider.notifier).state = grant;
    context.go('/home', extra: grant);
  }

  // ─── Timeout ─────────────────────────────────────────────────────────────

  void _startTimeout() {
    _timeoutTimer?.cancel();
    final appSettings = ref.read(appSettingsProvider);
    final timeout = appSettings.faceDetectionTimeout;
    _timeoutTimer = Timer(Duration(seconds: timeout), () {
      if (_isDisposed || !mounted) return;
      _showTimeout();
    });
  }

  void _showTimeout() {
    final strings = AppStrings.of(context);
    _isProcessing = true;
    ref.read(resetKioskFlowProvider)();
    _stopCameraStream();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.hourglass_empty_rounded,
          color: Colors.orange,
          size: 64,
        ),
        title: Text(strings.timeoutTitle),
        content: Text(strings.timeoutMessage, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/home');
            },
            child: Text(strings.back),
          ),
        ],
      ),
    );
  }

  // ─── Error dialogs ───────────────────────────────────────────────────────

  void _showError(String message, {bool allowRetry = true}) {
    final strings = AppStrings.of(context);
    final normalizedMessage = message.toLowerCase();
    final mealAlreadyRegistered =
        normalizedMessage.contains('repas') &&
        normalizedMessage.contains('enregistr');
    final canRetry = allowRetry && !mealAlreadyRegistered;
    ref.read(resetKioskFlowProvider)();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: mealAlreadyRegistered
            ? const Icon(Icons.block_rounded, color: Colors.red, size: 56)
            : null,
        title: Text(
          mealAlreadyRegistered
              ? strings.mealAlreadyRegisteredTitle
              : strings.errorTitle,
        ),
        content: Text(
          mealAlreadyRegistered
              ? strings.mealAlreadyRegisteredMessage
              : message,
        ),
        actions: [
          if (canRetry)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _restartScanning();
              },
              child: Text(strings.retryIdentification),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/home');
            },
            child: Text(strings.backHome),
          ),
        ],
      ),
    );
  }

  // ─── Restart ─────────────────────────────────────────────────────────────

  void _restartScanning() {
    _isProcessing = false;
    _canCapture = true;
    _isStable = false;
    _isFaceDetected = false;
    _stabilityTimer?.cancel();
    _timeoutTimer?.cancel();
    ref.read(faceRecognitionProvider.notifier).reset();

    _startTimeout();

    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_cameraController!.value.isStreamingImages) {
      _cameraController!.startImageStream(_processImage);
    }
    if (mounted) {
      setState(() => _guidanceMessage = AppStrings.of(context).placeFace);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    if (_cameraError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.no_photography_outlined,
                    size: 64,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    _cameraError!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.lg),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() => _cameraError = null);
                      _initializeCamera();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(strings.retry),
                  ),
                  const SizedBox(height: Spacing.sm),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(strings.backHome),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_faceEnabled && !_qrEnabled) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_rounded,
                size: 64,
                color: Colors.white38,
              ),
              const SizedBox(height: 16),
              Text(
                strings.noIdentificationMethod,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: Text(strings.backHome),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized && _cameraController != null
          ? Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Semantics(
                    label: strings.cameraPreviewSemantics,
                    image: true,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
                FaceScanOverlay(isDetected: _isFaceDetected),
                Positioned(
                  top: MediaQuery.of(context).padding.top + Spacing.md,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        width: 128,
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(Spacing.radiusMd),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/branding/app_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + Spacing.md,
                  left: Spacing.md,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ref.read(resetKioskFlowProvider)();
                        _stopCameraStream();
                        context.go('/home');
                      },
                      tooltip: strings.cancelAction,
                    ),
                  ),
                ),
                if (_canSwitchCamera)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + Spacing.md,
                    right: Spacing.md,
                    child: SafeArea(
                      child: IconButton.filledTonal(
                        onPressed: _isSwitchingCamera || _isProcessing
                            ? null
                            : _switchCamera,
                        icon: const Icon(Icons.cameraswitch_rounded),
                        tooltip: strings.switchCamera,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + Spacing.xxl,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      _buildGuidanceBadge(theme),
                      const SizedBox(height: Spacing.md),
                      Text(
                        _faceEnabled
                            ? strings.keepFaceWellLit
                            : strings.presentQrCode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildGuidanceBadge(ThemeData theme) {
    return Semantics(
      liveRegion: true,
      label: _guidanceMessage,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(Spacing.radiusFull),
          border: Border.all(color: Colors.white24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          _guidanceMessage,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
