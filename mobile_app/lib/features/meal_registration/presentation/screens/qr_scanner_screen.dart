import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/spacing.dart';
import '../../../home/presentation/providers/selection_providers.dart';
import '../providers/meal_registration_provider.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController =
      MobileScannerController();
  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) {
      debugPrint('[Scanner] ⏭ Already processing — ignoring');
      return;
    }

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      debugPrint('[Scanner] ⏭ No barcodes');
      return;
    }

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null) {
      debugPrint('[Scanner] ⏭ null rawValue');
      return;
    }

    final qrToken = rawValue.trim();
    if (qrToken.isEmpty) {
      debugPrint('[Scanner] ⏭ empty token');
      return;
    }

    debugPrint('[Scanner] ✅ QR detected: $qrToken');
    _isProcessing = true;
    unawaited(HapticFeedback.heavyImpact());

    _scannerController.stop();
    debugPrint('[Scanner] 🛑 Scanner stopped');

    final categorieUuid = ref.read(selectedCategoryUuidProvider);
    if (categorieUuid == null) {
      debugPrint('[Scanner] ❌ No category UUID — navigating home');
      if (mounted) context.go('/home');
      return;
    }

    if (!mounted) {
      debugPrint('[Scanner] ⚠️ Not mounted before request');
      return;
    }

    try {
      debugPrint('[Scanner] 📤 Sending POST /meals/register...');
      await ref.read(mealRegistrationProvider.notifier).registerMeal(
        qrToken: qrToken,
        categorieUuid: categorieUuid,
      );
      debugPrint('[Scanner] 📥 Response received');

      if (!mounted) {
        debugPrint('[Scanner] ⚠️ Not mounted after response');
        return;
      }

      final state = ref.read(mealRegistrationProvider);

      if (state.result != null) {
        debugPrint('[Scanner] ✅ Success — navigating to /success');
        context.pushReplacement('/success');
        debugPrint('[Scanner] ✅ Navigation done');
      } else if (state.error != null) {
        debugPrint('[Scanner] ❌ Error: ${state.error}');
        _showErrorDialog(state.error!);
      } else {
        debugPrint('[Scanner] ⚠️ No result and no error');
        _isProcessing = false;
        _scannerController.start();
      }
    } catch (e, stackTrace) {
      debugPrint('[Scanner] 💥 Exception: $e');
      debugPrint('[Scanner] Stack trace: $stackTrace');
      if (mounted) {
        _showErrorDialog('Erreur inattendue : ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
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
              _isProcessing = false;
              _scannerController.start();
            },
            child: const Text('Réessayer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/home');
            },
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          _ScannerOverlay(
            scanLinePosition: _scanLineAnimation.value,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + Spacing.md,
            left: Spacing.md,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => context.go('/home'),
                tooltip: 'Annuler',
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + Spacing.md,
            right: Spacing.md,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.flashlight_on_rounded,
                    color: Colors.white),
                onPressed: () => _scannerController.toggleTorch(),
                tooltip: 'Lampe torche',
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + Spacing.xxl,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Placez le QR code dans le cadre',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Le scan est automatique',
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
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  final double scanLinePosition;

  const _ScannerOverlay({required this.scanLinePosition});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanSize = size.width * 0.7;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2;

    return CustomPaint(
      size: size,
      painter: _OverlayPainter(
        scanRect: Rect.fromLTWH(left, top, scanSize, scanSize),
        scanLineY: top + scanLinePosition * scanSize,
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect scanRect;
  final double scanLineY;

  _OverlayPainter({required this.scanRect, required this.scanLineY});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(
          scanRect,
          const Radius.circular(Spacing.radiusMd),
        )),
      ),
      overlayPaint,
    );

    final borderPaint = Paint()
      ..color = Colors.white
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
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerLength = 24.0;

    // Top-left
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

    // Top-right
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

    // Bottom-left
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

    // Bottom-right
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

    final scanLinePaint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(scanRect.left + 4, scanLineY),
      Offset(scanRect.right - 4, scanLineY),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) =>
      oldDelegate.scanLineY != scanLineY;
}
