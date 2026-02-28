import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  // Create images at different sizes
  final sizes = {
    'icon_192.png': 192,
    'icon_512.png': 512,
    'app_icon_1024.png': 1024,
  };

  for (final entry in sizes.entries) {
    await generateLogoPNG(
      filename: entry.key,
      size: entry.value,
      darkMode: true,
    );
  }

  // ignore: avoid_print
  print('\n✓ All logo PNGs generated successfully!');
}

Future<void> generateLogoPNG({
  required String filename,
  required int size,
  required bool darkMode,
}) async {
  // Create image with dark background
  final image = img.Image(
    width: size,
    height: size,
  );

  // Fill with dark background
  final bgColor = darkMode
      ? img.ColorUint8.rgba(15, 23, 42, 255)
      : img.ColorUint8.rgba(255, 255, 255, 255);
  img.fill(image, color: bgColor);

  // Define colors
  final nanoColor = darkMode
      ? img.ColorUint8.rgba(216, 223, 255, 255)
      : img.ColorUint8.rgba(199, 206, 255, 255);
  final solveColor = darkMode
      ? img.ColorUint8.rgba(181, 255, 181, 255)
      : img.ColorUint8.rgba(152, 251, 152, 255);

  // Scale factor for sizing elements
  final scale = size / 100;

  // Draw nano particles (left side circles)
  _drawCircle(image, (20 * scale).toInt(), (30 * scale).toInt(),
      (5 * scale).toInt(), nanoColor, 0.7);
  _drawCircle(image, (25 * scale).toInt(), (15 * scale).toInt(),
      (4 * scale).toInt(), nanoColor, 0.8);
  _drawCircle(image, (30 * scale).toInt(), (50 * scale).toInt(),
      (6 * scale).toInt(), nanoColor, 0.6);
  _drawCircle(image, (15 * scale).toInt(), (65 * scale).toInt(),
      (5 * scale).toInt(), nanoColor, 0.9);
  _drawCircle(image, (45 * scale).toInt(), (40 * scale).toInt(),
      (7 * scale).toInt(), nanoColor, 1.0);

  // Draw solve circles (right side circles)
  _drawCircle(image, (70 * scale).toInt(), (25 * scale).toInt(),
      (7 * scale).toInt(), solveColor, 1.0);
  _drawCircle(image, (75 * scale).toInt(), (55 * scale).toInt(),
      (7 * scale).toInt(), solveColor, 1.0);
  _drawCircle(image, (90 * scale).toInt(), (40 * scale).toInt(),
      (9 * scale).toInt(), solveColor, 1.0);

  // Draw connections (lines)
  _drawLine(image, (45 * scale).toInt(), (40 * scale).toInt(),
      (70 * scale).toInt(), (25 * scale).toInt(), solveColor);
  _drawLine(image, (45 * scale).toInt(), (40 * scale).toInt(),
      (75 * scale).toInt(), (55 * scale).toInt(), solveColor);
  _drawLine(image, (70 * scale).toInt(), (25 * scale).toInt(),
      (90 * scale).toInt(), (40 * scale).toInt(), solveColor);
  _drawLine(image, (75 * scale).toInt(), (55 * scale).toInt(),
      (90 * scale).toInt(), (40 * scale).toInt(), solveColor);

  // Draw text "NANO" and "SOLVE" using simple pixel patterns
  _drawTextNano(image, (32 * scale).toInt(), (35 * scale).toInt(),
      scale.toInt(), nanoColor);
  _drawTextSolve(image, (50 * scale).toInt(), (35 * scale).toInt(),
      scale.toInt(), solveColor);

  // Save as PNG
  final outputPath = 'assets/icons/$filename';
  await Directory('assets/icons').create(recursive: true);

  final pngData = img.encodePng(image);
  await File(outputPath).writeAsBytes(pngData);

  // ignore: avoid_print
  print('✓ Generated: $outputPath (${size}x$size)');
}

void _drawCircle(
  img.Image image,
  int centerX,
  int centerY,
  int radius,
  img.ColorUint8 color,
  double opacity,
) {
  final alpha = (opacity * 255).toInt();
  final adjustedColor = img.ColorUint8.rgba(
    color.r.toInt(),
    color.g.toInt(),
    color.b.toInt(),
    alpha,
  );

  for (int y = centerY - radius; y <= centerY + radius; y++) {
    for (int x = centerX - radius; x <= centerX + radius; x++) {
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        final dx = x - centerX;
        final dy = y - centerY;
        if (dx * dx + dy * dy <= radius * radius) {
          image.setPixelRgba(
            x,
            y,
            adjustedColor.r.toInt(),
            adjustedColor.g.toInt(),
            adjustedColor.b.toInt(),
            adjustedColor.a.toInt(),
          );
        }
      }
    }
  }
}

void _drawLine(
  img.Image image,
  int x1,
  int y1,
  int x2,
  int y2,
  img.ColorUint8 color,
) {
  // Bresenham's line algorithm
  int dx = (x2 - x1).abs();
  int dy = (y2 - y1).abs();
  int sx = x1 < x2 ? 1 : -1;
  int sy = y1 < y2 ? 1 : -1;
  int err = dx - dy;

  int x = x1;
  int y = y1;

  const lineWidth = 3;

  while (true) {
    // Draw thick line by drawing multiple pixels
    for (int lx = x - lineWidth ~/ 2; lx <= x + lineWidth ~/ 2; lx++) {
      for (int ly = y - lineWidth ~/ 2; ly <= y + lineWidth ~/ 2; ly++) {
        if (lx >= 0 && lx < image.width && ly >= 0 && ly < image.height) {
          image.setPixelRgba(
            lx,
            ly,
            color.r.toInt(),
            color.g.toInt(),
            color.b.toInt(),
            color.a.toInt(),
          );
        }
      }
    }

    if (x == x2 && y == y2) break;

    int e2 = 2 * err;
    if (e2 > -dy) {
      err -= dy;
      x += sx;
    }
    if (e2 < dx) {
      err += dx;
      y += sy;
    }
  }
}

void _drawTextNano(
  img.Image image,
  int startX,
  int startY,
  int scale,
  img.ColorUint8 color,
) {
  // Simple "NANO" text representation
  _drawRectangle(image, startX, startY, 3 * scale, 8 * scale, color);
  _drawRectangle(
      image, startX + 4 * scale, startY, 3 * scale, 8 * scale, color);
  _drawRectangle(
      image, startX + 8 * scale, startY, 3 * scale, 8 * scale, color);
  _drawRectangle(
      image, startX + 12 * scale, startY, 3 * scale, 8 * scale, color);
}

void _drawTextSolve(
  img.Image image,
  int startX,
  int startY,
  int scale,
  img.ColorUint8 color,
) {
  // Simple "SOLVE" text representation
  _drawRectangle(image, startX, startY, 3 * scale, 8 * scale, color);
  _drawRectangle(
      image, startX + 4 * scale, startY, 3 * scale, 8 * scale, color);
  _drawRectangle(
      image, startX + 8 * scale, startY, 3 * scale, 8 * scale, color);
  _drawRectangle(
      image, startX + 12 * scale, startY, 3 * scale, 8 * scale, color);
  _drawRectangle(
      image, startX + 16 * scale, startY, 3 * scale, 8 * scale, color);
}

void _drawRectangle(
  img.Image image,
  int x,
  int y,
  int width,
  int height,
  img.ColorUint8 color,
) {
  for (int py = y; py < y + height; py++) {
    for (int px = x; px < x + width; px++) {
      if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
        image.setPixelRgba(
          px,
          py,
          color.r.toInt(),
          color.g.toInt(),
          color.b.toInt(),
          color.a.toInt(),
        );
      }
    }
  }
}
