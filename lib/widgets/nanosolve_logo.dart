import 'package:flutter/material.dart';

class NanosolveLogo extends StatelessWidget {
  final double height;
  final bool darkMode;

  const NanosolveLogo({
    super.key,
    this.height = 80,
    this.darkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(height * 4, height),
        painter: _NanosolveLogoPainter(darkMode: darkMode),
      ),
    );
  }
}

class _NanosolveLogoPainter extends CustomPainter {
  final bool darkMode;

  _NanosolveLogoPainter({required this.darkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / 100;

    // Define solid colors for particles
    final nanoColor =
        darkMode ? const Color(0xFFD8DFFF) : const Color(0xFFC7CEFF);
    final solveColor =
        darkMode ? const Color(0xFFB5FFB5) : const Color(0xFF98FB98);

    // Draw text first to measure its width for centering
    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: 'NANO',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 48 * scale,
            fontWeight: FontWeight.w400,
            color: darkMode ? const Color(0xFFE2E8F0) : const Color(0xFF5E6E82),
          ),
        ),
        TextSpan(
          text: 'SOLVE',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 48 * scale,
            fontWeight: FontWeight.w800,
            color: darkMode ? const Color(0xFFFFFFFF) : const Color(0xFF2C3E50),
          ),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate total width and center offset
    final totalWidth = 130 * scale + textPainter.width;
    final horizontalCenterOffset = (size.width - totalWidth) / 2;

    canvas.save();
    canvas.translate(horizontalCenterOffset, 10 * scale);

    // Draw nano particles (left side) with varying opacity
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

    // Draw connections (lines)
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

    // Draw solve circles (right side)
    final solvePaint = Paint()..color = solveColor;
    canvas.drawCircle(Offset(70 * scale, 25 * scale), 7 * scale, solvePaint);
    canvas.drawCircle(Offset(75 * scale, 55 * scale), 7 * scale, solvePaint);
    canvas.drawCircle(Offset(90 * scale, 40 * scale), 9 * scale, solvePaint);

    canvas.restore();

    // Draw text centered
    textPainter.paint(
        canvas, Offset(horizontalCenterOffset + 130 * scale, 30 * scale));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
