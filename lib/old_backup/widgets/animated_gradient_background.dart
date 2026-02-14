import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.colors,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                math.sin(_controller.value * 2 * math.pi) * 0.5,
                math.cos(_controller.value * 2 * math.pi) * 0.5,
              ),
              end: Alignment(
                -math.sin(_controller.value * 2 * math.pi) * 0.5,
                -math.cos(_controller.value * 2 * math.pi) * 0.5,
              ),
              colors: widget.colors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
