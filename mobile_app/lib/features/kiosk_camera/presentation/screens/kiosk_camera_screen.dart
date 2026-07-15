import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../../../core/theme/spacing.dart';
import '../../../admin/settings/presentation/providers/app_settings_provider.dart';
import '../../../face_recognition/presentation/providers/face_recognition_provider.dart';
import '../../../face_recognition/presentation/widgets/face_scan_overlay.dart';
import '../../../home/presentation/providers/selection_providers.dart';
import '../../../meal_registration/presentation/providers/meal_registration_provider.dart';

class KioskCameraScreen extends ConsumerStatefulWidget {
  const KioskCameraScreen({super.key});

  @override
  ConsumerState<KioskCameraScreen> createState() => _KioskCameraScreenState();
}

class _KioskCameraScreenState extends ConsumerState<KioskCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  BarcodeScanner? _barcodeScanner;

  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isDisposed = false;

  bool _faceEnabled = true;
  bool _qrEnabled = true;

  // ─── Face tracking ───────────────────────────────────────────────────────
  bool _isFaceDetected = false;
  bool _isStable = false;
  String _guidanceMessage = 'Placez votre visage dans le cadre';
  Timer? _stabilityTimer;
  bool _canCapture = true;
  bool _faceCooldown = false;
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

    final categorieUuid = ref.read(selectedCategoryUuidProvider);
    if (categorieUuid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
      return;
    }

    _initializeCamera();
    _faceDetector = FaceDetector(options: FaceDetectorOptions());
    if (_qrEnabled) {
      _barcodeScanner = BarcodeScanner(
        formats: [BarcodeFormat.qrCode],
      );
    }
    _startTimeout();
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
      _cameraController?.resumePreview();
    } else if (state == AppLifecycleState.paused) {
      _cameraController?.stopImageStream();
    }
  }

  // ─── Camera init ─────────────────────────────────────────────────────────

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
        imageFormatGroup: ImageFormatGroup.nv21,
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
          _guidanceMessage = "Erreur d'accès à la caméra";
        });
      }
    }
  }

  void _stopCameraStream() {
    try {
      _cameraController?.stopImageStream();
    } catch (e) {
      debugPrint('KioskCamera: error stopping camera stream: $e');
    }
  }

  // ─── Image processing ────────────────────────────────────────────────────

  void _processImage(CameraImage image) {
    if (_isProcessing || !_canCapture || _isDisposed) return;

    try {
      final inputImage = _inputImageFromCamera(image);
      if (inputImage == null) return;

      if (_faceEnabled && !_faceCooldown) {
        _faceDetector?.processImage(inputImage).then((faces) {
          if (_isDisposed || _isProcessing || !_canCapture) return;

          if (faces.isEmpty) {
            _onNoFace(inputImage);
          } else if (faces.length > 1) {
            _onMultipleFaces(inputImage);
          } else {
            _onSingleFace(faces.first, image.width, image.height, inputImage);
          }
        });
      } else if (_qrEnabled) {
        _detectBarcode(inputImage);
      }
    } catch (e) {
      debugPrint('KioskCamera: error processing image: $e');
    }
  }

  InputImage? _inputImageFromCamera(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (camera.lensDirection == CameraLensDirection.front) {
      rotation = InputImageRotation.values.firstWhere(
        (r) => r.rawValue == (sensorOrientation + 90) % 360,
        orElse: () => InputImageRotation.rotation0deg,
      );
    } else {
      rotation = InputImageRotation.values.firstWhere(
        (r) => r.rawValue == (sensorOrientation + 270) % 360,
        orElse: () => InputImageRotation.rotation0deg,
      );
    }

    final format = InputImageFormat.values.firstWhere(
      (f) => f.rawValue == image.format.raw,
      orElse: () => InputImageFormat.nv21,
    );

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // ─── Face detection handlers ─────────────────────────────────────────────

  void _onNoFace(InputImage inputImage) {
    if (_isFaceDetected) {
      _isFaceDetected = false;
      _isStable = false;
      _stabilityTimer?.cancel();
    }
    setState(() => _guidanceMessage = 'Aucun visage détecté');

    if (_qrEnabled) {
      _detectBarcode(inputImage);
    }
  }

  void _onMultipleFaces(InputImage inputImage) {
    _isFaceDetected = false;
    _isStable = false;
    _stabilityTimer?.cancel();
    setState(() => _guidanceMessage = 'Plus d\'un visage détecté');

    if (_qrEnabled) {
      _detectBarcode(inputImage);
    }
  }

  void _onSingleFace(Face face, int imageWidth, int imageHeight,
      InputImage inputImage) {
    _timeoutTimer?.cancel();

    if (!_isFaceDetected) {
      _isFaceDetected = true;
      setState(() => _guidanceMessage = 'Parfait, maintenez...');
    }

    final box = face.boundingBox;
    final centerX = box.left + box.width / 2;
    final centerY = box.top + box.height / 2;
    final normX = centerX / imageWidth;
    final normY = centerY / imageHeight;

    final isCentered = (normX - 0.5).abs() < _centerThreshold &&
        (normY - 0.5).abs() < _centerThreshold;

    if (!isCentered) {
      _isStable = false;
      _stabilityTimer?.cancel();
      setState(() => _guidanceMessage = 'Centre votre visage');
      return;
    }

    setState(() => _guidanceMessage = 'Ne bougez plus...');

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
      final file = await _cameraController!.takePicture();
      if (_isDisposed || !mounted) return;

      _stopCameraStream();
      setState(() => _guidanceMessage = 'Identification en cours...');

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUri = 'data:image/jpeg;base64,$base64Image';

      final result =
          await ref.read(faceRecognitionProvider.notifier).identify(
                imageBase64: dataUri,
              );

      if (_isDisposed || !mounted) return;

      if (result != null && result.isMatch) {
        final userUuid = result.utilisateurUuid;
        if (userUuid == null || userUuid.isEmpty) {
          _showError("Impossible d'identifier l'utilisateur.");
          return;
        }
        await _registerMeal(userUuid: userUuid);
      } else {
        _onFaceNotRecognized();
      }
    } catch (e) {
      if (_isDisposed || !mounted) return;
      _showError("Erreur lors de l'identification. Veuillez réessayer.");
    }
  }

  void _onFaceNotRecognized() {
    _faceCooldown = true;
    _faceCooldownTimer?.cancel();
    _faceCooldownTimer = Timer(_faceCooldownDuration, () {
      if (_isDisposed) return;
      _faceCooldown = false;
    });

    _restartScanning();
  }

  // ─── QR / Barcode detection ──────────────────────────────────────────────

  Future<void> _detectBarcode(InputImage inputImage) async {
    if (_isProcessing || !_canCapture || !_qrEnabled) return;
    if (_barcodeScanner == null) return;

    try {
      final barcodes = await _barcodeScanner!.processImage(inputImage);
      if (_isDisposed || !mounted || _isProcessing || !_canCapture) return;

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        final qrToken = barcode.rawValue;
        if (qrToken != null && qrToken.isNotEmpty) {
          _timeoutTimer?.cancel();
          _isProcessing = true;
          _canCapture = false;
          _stopCameraStream();
          setState(() => _guidanceMessage = 'QR Code détecté !');
          await _registerMeal(qrToken: qrToken);
        }
      }
    } catch (e) {
      debugPrint('KioskCamera: error detecting barcode: $e');
    }
  }

  // ─── Meal registration ───────────────────────────────────────────────────

  Future<void> _registerMeal({
    String? userUuid,
    String? qrToken,
  }) async {
    final categorieUuid = ref.read(selectedCategoryUuidProvider);
    if (categorieUuid == null) {
      _showError('Aucune catégorie de repas sélectionnée.');
      return;
    }

    setState(() => _guidanceMessage = 'Enregistrement du repas...');

    await ref.read(mealRegistrationProvider.notifier).registerMeal(
          userUuid: userUuid,
          qrToken: qrToken,
          categorieUuid: categorieUuid,
        );

    if (_isDisposed || !mounted) return;

    final mealState = ref.read(mealRegistrationProvider);

    if (mealState.result != null) {
      context.pushReplacement('/success');
    } else if (mealState.error != null) {
      _showRegistrationError(mealState.error!);
    } else {
      _restartScanning();
    }
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
    _isProcessing = true;
    _stopCameraStream();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.hourglass_empty_rounded,
            color: Colors.orange, size: 64),
        title: const Text('Délai écoulé'),
        content: const Text(
          'Aucune personne ou QR Code détecté.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/home');
            },
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  // ─── Error dialogs ───────────────────────────────────────────────────────

  void _showRegistrationError(String error) {
    final isDuplicate = error.contains('déjà') || error.contains('deja');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Enregistrement du repas'),
        content: Text(
          isDuplicate
              ? 'Vous avez déjà enregistré un repas aujourd\'hui.'
              : error,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/home');
            },
            child: const Text("Retour à l'accueil"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _restartScanning();
            },
            child: const Text('Réessayer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/home');
            },
            child: const Text("Retour à l'accueil"),
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
    ref.read(mealRegistrationProvider.notifier).reset();

    _startTimeout();

    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_cameraController!.value.isStreamingImages) {
      _cameraController!.startImageStream(_processImage);
    }
    if (mounted) {
      setState(() => _guidanceMessage = 'Placez votre visage dans le cadre');
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_faceEnabled && !_qrEnabled) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_rounded,
                  size: 64, color: Colors.white38),
              const SizedBox(height: 16),
              Text(
                'Aucune méthode d\'identification activée.',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text("Retour à l'accueil"),
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
                  child: CameraPreview(_cameraController!),
                ),
                FaceScanOverlay(
                  isDetected: _isFaceDetected,
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + Spacing.md,
                  left: Spacing.md,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white),
                      onPressed: () {
                        _stopCameraStream();
                        context.go('/home');
                      },
                      tooltip: 'Annuler',
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
                            ? 'Gardez votre visage bien éclairé'
                            : 'Présentez votre QR Code',
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
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }

  Widget _buildGuidanceBadge(ThemeData theme) {
    return Container(
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
    );
  }
}
