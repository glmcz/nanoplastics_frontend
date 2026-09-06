import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/footprint/footprint_model.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';

/// Habits are told apart by shape as well as colour, so the picture still
/// works for a student with colour-vision deficiency.
enum DotShape { circle, square, triangle, diamond, cross, hexagon }

/// A drifting field of dots standing in for a year of particles.
///
/// Three constraints shape this widget and none of them is decoration:
/// identity is never colour alone, the canvas is a single semantic node with
/// a live label, and motion stops for the OS reduce-motion setting or the
/// pause control.
class ParticleCloud extends StatefulWidget {
  final List<HabitEstimate> habits;

  /// Spoken by a screen reader in place of the canvas. Carries the number,
  /// because the number is the content.
  final String semanticLabel;

  final bool paused;
  final VoidCallback onTogglePause;

  const ParticleCloud({
    super.key,
    required this.habits,
    required this.semanticLabel,
    required this.paused,
    required this.onTogglePause,
  });

  @override
  State<ParticleCloud> createState() => ParticleCloudState();
}

class ParticleCloudState extends State<ParticleCloud>
    with SingleTickerProviderStateMixin {
  static const int maxDots = 400;
  static const int reducedDots = 200;

  late final AnimationController _controller;

  /// Fixed seed: the same day draws the same cloud, so a student who goes
  /// back a chapter does not see the picture reshuffle for no reason.
  final math.Random _rng = math.Random(7);

  List<_Dot> _dots = const [];
  double _perDot = 0;

  bool get isAnimating => _controller.isAnimating;
  int get debugDotCount => _dots.length;
  List<DotShape> get debugDotShapes =>
      _dots.map((d) => d.shape).toSet().toList();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildDots();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant ParticleCloud oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.habits, widget.habits)) _rebuildDots();
    if (oldWidget.paused != widget.paused) _syncTicker();
  }

  /// Motion is off when the OS asks for it or the student pressed pause. The
  /// cloud still renders; only the ticker stops.
  void _syncTicker() {
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced || widget.paused) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _rebuildDots() {
    final reduced = MediaQuery.of(context).disableAnimations;
    final budget = reduced ? reducedDots : maxDots;

    final present = widget.habits.where((h) => h.particlesPerYear > 0).toList();
    final total = present.fold<double>(0, (a, h) => a + h.particlesPerYear);

    // Reserve one dot per habit before sharing out the rest. These values
    // span nine orders of magnitude, so proportional allocation alone lets
    // the largest habit take the whole budget and the smallest ones vanish
    // from a picture that claims to show the student's whole day.
    final reserved = math.min(present.length, budget);
    final remaining = budget - reserved;

    final dots = <_Dot>[];
    for (var i = 0; i < present.length; i++) {
      final h = present[i];
      final indexInAll = widget.habits.indexOf(h);
      final share = total == 0 ? 0.0 : h.particlesPerYear / total;
      final want = (i < reserved ? 1 : 0) + (share * remaining).round();
      for (var d = 0; d < want && dots.length < budget; d++) {
        dots.add(_Dot(
          shape: DotShape.values[indexInAll % DotShape.values.length],
          habitIndex: indexInAll,
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          phase: _rng.nextDouble(),
        ));
      }
    }

    setState(() {
      _dots = dots;
      _perDot = dots.isEmpty ? 0 : total / dots.length;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: widget.semanticLabel,
          liveRegion: true,
          image: true,
          child: RepaintBoundary(
            child: AspectRatio(
              aspectRatio: 2,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _CloudPainter(
                    dots: _dots,
                    t: _controller.value,
                    palette: _palette,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: spacing.xs),
        Row(
          children: [
            Expanded(
              child: Text(
                // The scale moves with the dot budget, so it is computed
                // rather than written into a string.
                _scaleCaption(),
                key: const Key('cloud-scale-caption'),
                style: typography.labelSm,
              ),
            ),
            IconButton(
              key: const Key('cloud-pause'),
              onPressed: widget.onTogglePause,
              icon: Icon(widget.paused ? Icons.play_arrow : Icons.pause),
              tooltip: widget.paused ? 'Play' : 'Pause',
            ),
          ],
        ),
      ],
    );
  }

  String _scaleCaption() {
    if (_perDot <= 0) return '';
    return 'Each dot is about ${_perDot.toStringAsPrecision(2)} particles';
  }

  static const List<Color> _palette = [
    Color(0xFF4FC3F7),
    Color(0xFFFFB74D),
    Color(0xFFAED581),
    Color(0xFFBA68C8),
    Color(0xFFE57373),
    Color(0xFF4DB6AC),
  ];
}

class _Dot {
  final DotShape shape;
  final int habitIndex;
  final double x;
  final double y;
  final double phase;

  const _Dot({
    required this.shape,
    required this.habitIndex,
    required this.x,
    required this.y,
    required this.phase,
  });
}

class _CloudPainter extends CustomPainter {
  final List<_Dot> dots;
  final double t;
  final List<Color> palette;

  _CloudPainter({required this.dots, required this.t, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    // Shapes are drawn as paths, never as text glyphs. A glyph per dot is the
    // expensive path on the low-end Android phones this audience carries.
    for (final d in dots) {
      final drift = math.sin((t + d.phase) * 2 * math.pi) * 4;
      final centre = Offset(d.x * size.width, d.y * size.height + drift);
      final paint = Paint()..color = palette[d.habitIndex % palette.length];
      switch (d.shape) {
        case DotShape.circle:
          canvas.drawCircle(centre, 3, paint);
        case DotShape.square:
          canvas.drawRect(
              Rect.fromCenter(center: centre, width: 5, height: 5), paint);
        case DotShape.triangle:
          canvas.drawPath(_polygon(centre, 3, 4), paint);
        case DotShape.diamond:
          canvas.drawPath(_polygon(centre, 4, 4), paint);
        case DotShape.cross:
          canvas.drawRect(
              Rect.fromCenter(center: centre, width: 7, height: 2), paint);
          canvas.drawRect(
              Rect.fromCenter(center: centre, width: 2, height: 7), paint);
        case DotShape.hexagon:
          canvas.drawPath(_polygon(centre, 6, 4), paint);
      }
    }
  }

  Path _polygon(Offset centre, int sides, double radius) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / sides;
      final point = Offset(
        centre.dx + radius * math.cos(angle),
        centre.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _CloudPainter old) =>
      old.t != t || !identical(old.dots, dots);
}
