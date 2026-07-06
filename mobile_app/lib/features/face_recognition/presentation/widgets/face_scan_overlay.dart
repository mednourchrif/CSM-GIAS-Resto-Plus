import 'package:flutter/material.dart';

import '../../../../core/theme/spacing.dart';

class FaceScanOverlay extends StatelessWidget {
  final bool isDetected;

  const FaceScanOverlay({super.key, required this.isDetected});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanSize = size.width * 0.75;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2 - 30;

    return CustomPaint(
      size: size,
      painter: _OverlayPainter(
        scanRect: Rect.fromLTWH(left, top, scanSize, scanSize),
        isDetected: isDetected,
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect scanRect;
  final bool isDetected;

  _OverlayPainter({required this.scanRect, required this.isDetected});

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
          const Radius.circular(Spacing.radiusLg),
        )),
      ),
      overlayPaint,
    );

    final borderColor =
        isDetected ? const Color(0xFF4CAF50) : Colors.white;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        scanRect,
        const Radius.circular(Spacing.radiusLg),
      ),
      borderPaint,
    );

    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const cl = 24.0;

    canvas.drawLine(scanRect.topLeft,
        Offset(scanRect.left + cl, scanRect.top), cornerPaint);
    canvas.drawLine(scanRect.topLeft,
        Offset(scanRect.left, scanRect.top + cl), cornerPaint);
    canvas.drawLine(scanRect.topRight,
        Offset(scanRect.right - cl, scanRect.top), cornerPaint);
    canvas.drawLine(scanRect.topRight,
        Offset(scanRect.right, scanRect.top + cl), cornerPaint);
    canvas.drawLine(scanRect.bottomLeft,
        Offset(scanRect.left + cl, scanRect.bottom), cornerPaint);
    canvas.drawLine(scanRect.bottomLeft,
        Offset(scanRect.left, scanRect.bottom - cl), cornerPaint);
    canvas.drawLine(scanRect.bottomRight,
        Offset(scanRect.right - cl, scanRect.bottom), cornerPaint);
    canvas.drawLine(scanRect.bottomRight,
        Offset(scanRect.right, scanRect.bottom - cl), cornerPaint);
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect ||
      oldDelegate.isDetected != isDetected;
}
