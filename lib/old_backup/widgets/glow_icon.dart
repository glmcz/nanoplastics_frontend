import 'package:flutter/material.dart';

class GlowIcon extends StatelessWidget {
  final String emoji;
  final double size;
  final Color glowColor;
  final double glowRadius;

  const GlowIcon({
    super.key,
    required this.emoji,
    this.size = 48,
    required this.glowColor,
    this.glowRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.5),
            blurRadius: glowRadius,
            spreadRadius: glowRadius / 2,
          ),
        ],
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: size),
      ),
    );
  }
}
