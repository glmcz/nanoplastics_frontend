import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Design token: theme-aware color mappings for light / dark mode.
///
/// Usage:
/// ```dart
/// final tc = AppThemeColors.of(context);
/// Container(color: tc.cardBackground, child: Text('...', style: style.copyWith(color: tc.textMain)));
/// ```
class AppThemeColors {
  final bool isDark;

  const AppThemeColors._(this.isDark);

  static AppThemeColors of(BuildContext context) =>
      AppThemeColors._(Theme.of(context).brightness == Brightness.dark);

  /// Page / scaffold background
  /// Dark: near-black  |  Light: near-white mint (#F5F9F8)
  Color get pageBackground =>
      isDark ? const Color(0xFF0A0A12) : const Color(0xFFF5F9F8);

  /// Card / container fill
  /// Dark: dark navy  |  Light: pure white
  Color get cardBackground => isDark ? const Color(0xFF141928) : Colors.white;

  /// Alert dialog / bottom-sheet background
  /// Dark: dark indigo  |  Light: subtle mint (#F0F7F5)
  Color get dialogBackground =>
      isDark ? const Color(0xFF1A1A24) : const Color(0xFFF0F7F5);

  /// Mid-surface (form fields, refresh indicators, secondary containers)
  /// Dark: deep navy  |  Light: mint tint (#E3EEE9)
  Color get surfaceMid =>
      isDark ? const Color(0xFF0F141E) : const Color(0xFFE3EEE9);

  /// Primary text — headings, card titles
  /// Dark: white  |  Light: deep forest (#1A2E28)
  Color get textMain => isDark ? Colors.white : const Color(0xFF1A2E28);

  /// Secondary text — subtitles, descriptions
  /// Dark: light gray  |  Light: muted forest green (#4A7165)
  Color get textMuted => isDark ? AppColors.textMuted : const Color(0xFF4A7165);

  /// Tertiary text — hints, disabled labels
  /// Dark: medium gray  |  Light: sage green (#7AA096)
  Color get textDark => isDark ? AppColors.textDark : const Color(0xFF7AA096);

  /// Switch inactive track (visible on both card backgrounds)
  Color get switchInactiveTrack =>
      isDark ? const Color(0xFF0A0A12) : const Color(0xFFC8DDD8);

  /// Outer/terminal color of RadialGradient page backgrounds
  Color get gradientEnd => pageBackground;

  /// Pastel overlay alpha — richer on white so neon accents still pop
  /// Dark: 0.05 (subtle glow)  |  Light: 0.30 (vivid pastel tints on white)
  double get pastelAlpha => isDark ? 0.05 : 0.30;

  /// Card border color — dark on light bg, near-invisible on dark bg
  /// Dark: white at 8% alpha  |  Light: deep forest at 10% alpha
  Color get cardBorderColor => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFF1A2E28).withValues(alpha: 0.10);

  /// Background image overlay alpha — keeps photos vivid in light mode,
  /// immersive and deep in dark mode.
  /// Dark: 0.50  |  Light: 0.08
  double get backgroundOverlayAlpha => isDark ? 0.50 : 0.08;
}
