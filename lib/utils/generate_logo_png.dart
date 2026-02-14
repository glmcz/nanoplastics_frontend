import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<void> generateLogoPNG({
  required String outputPath,
  double size = 512,
  bool darkMode = true,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Create a scene with white background for PNG
  final paint = Paint()
    ..color = darkMode ? const Color(0xFF0F172A) : Colors.white;
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size, size),
    paint,
  );

  // Create the logo painter
  final logoPainter = _NanosolveLogoPainter(darkMode: darkMode);

  // Calculate scale to fit logo in the size
  logoPainter.paint(
    canvas,
    Size(size * 0.8, size * 0.8),
  );

  // Convert to image
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());

  // Convert to PNG bytes
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  if (bytes != null) {
    final file = File(outputPath);
    await file.writeAsBytes(bytes.buffer.asUint8List());
    print('Logo PNG generated at: $outputPath');
  }
}

// Copy of the painter from nanosolve_logo.dart
class _NanosolveLogoPainter extends CustomPainter {
  final bool darkMode;

  _NanosolveLogoPainter({required this.darkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / 100;

    final nanoColor =
        darkMode ? const Color(0xFFD8DFFF) : const Color(0xFFC7CEFF);
    final solveColor =
        darkMode ? const Color(0xFFB5FFB5) : const Color(0xFF98FB98);

    canvas.save();
    canvas.translate(20 * scale, 10 * scale);

    final nanoPaint1 = Paint()..color = nanoColor.withValues(alpha: 0.7);
    final nanoPaint2 = Paint()..color = nanoColor.withValues(alpha: 0.8);
    final nanoPaint3 = Paint()..color = nanoColor.withValues(alpha: 0.6);
    final nanoPaint4 = Paint()..color = nanoColor.withValues(alpha: 0.9);
    final nanoPaint5 = Paint()..color = nanoColor;

    canvas.drawCircle(Offset(10 * scale, 30 * scale), 5 * scale, nanoPaint1);
    canvas.drawCircle(Offset(25 * scale, 15 * scale), 4 * scale, nanoPaint2);
    canvas.drawCircle(Offset(30 * scale, 50 * scale), 6 * scale, nanoPaint3);
    canvas.drawCircle(Offset(15 * scale, 65 * scale), 5 * scale, nanoPaint4);
    canvas.drawCircle(Offset(45 * scale, 40 * scale), 7 * scale, nanoPaint5);

    final solveLinePaint = Paint()
      ..color = solveColor
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(45 * scale, 40 * scale),
        Offset(70 * scale, 25 * scale), solveLinePaint);
    canvas.drawLine(Offset(45 * scale, 40 * scale),
        Offset(75 * scale, 55 * scale), solveLinePaint);
    canvas.drawLine(Offset(70 * scale, 25 * scale),
        Offset(90 * scale, 40 * scale), solveLinePaint);
    canvas.drawLine(Offset(75 * scale, 55 * scale),
        Offset(90 * scale, 40 * scale), solveLinePaint);

    final solvePaint = Paint()..color = solveColor;
    canvas.drawCircle(Offset(70 * scale, 25 * scale), 7 * scale, solvePaint);
    canvas.drawCircle(Offset(75 * scale, 55 * scale), 7 * scale, solvePaint);
    canvas.drawCircle(Offset(90 * scale, 40 * scale), 9 * scale, solvePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
