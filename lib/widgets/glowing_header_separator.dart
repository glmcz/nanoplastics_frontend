import 'package:flutter/material.dart';
import '../config/app_constants.dart';

/// A utility class that returns positioned widgets for a glowing header separator.
/// These widgets should be added to a Stack that has bounded constraints.
///
/// Usage:
/// ```dart
/// Expanded(
///   child: Stack(
///     children: [
///       Positioned.fill(child: _buildContent()),
///       ...GlowingHeaderSeparator.build(glowColor: AppColors.energy),
///     ],
///   ),
/// ),
/// ```
class GlowingHeaderSeparator {
  /// Generates positioned widgets for the glowing header separator effect.
  /// Returns a list of Positioned widgets to be spread into a Stack.
  static List<Widget> build({
    required Color glowColor,
    double topGradientAlpha = 0.12,
    double horizontalMargin = AppConstants.space40,
    double lineHeight = 1,
    double blurRadius = 8,
    double spreadRadius = 1,
  }) {
    return [
      // Top gradient fade - creates smooth transition from header to content
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 24,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                glowColor.withValues(alpha: topGradientAlpha),
                glowColor.withValues(alpha: topGradientAlpha * 0.25),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
      // Glowing line separator with enhanced visual effects
      Positioned(
        top: 0,
        left: horizontalMargin,
        right: horizontalMargin,
        child: Container(
          height: lineHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                glowColor.withValues(alpha: 0.75),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.3),
                blurRadius: blurRadius,
                spreadRadius: spreadRadius,
              ),
              // Additional subtle outer glow for depth
              BoxShadow(
                color: glowColor.withValues(alpha: 0.15),
                blurRadius: blurRadius * 1.5,
                spreadRadius: spreadRadius * 0.5,
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
