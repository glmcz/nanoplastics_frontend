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
  Color get pageBackground =>
      isDark ? const Color(0xFF0A0A12) : const Color(0xFF002535);

  /// Card / container fill
  Color get cardBackground =>
      isDark ? const Color(0xFF141928) : const Color(0xFF003347);

  /// Alert dialog / bottom-sheet background
  Color get dialogBackground =>
      isDark ? const Color(0xFF1A1A24) : const Color(0xFF003D55);

  /// Mid-surface (form fields, refresh indicators, secondary containers)
  Color get surfaceMid =>
      isDark ? const Color(0xFF0F141E) : const Color(0xFF001B28);

  /// Primary text — headings, card titles
  Color get textMain => Colors.white;

  /// Secondary text — subtitles, descriptions
  Color get textMuted =>
      isDark ? AppColors.textMuted : const Color(0xFFAAD4D8);

  /// Tertiary text — hints, disabled labels
  Color get textDark =>
      isDark ? AppColors.textDark : const Color(0xFF70AAAA);

  /// Switch inactive track (visible on both card backgrounds)
  Color get switchInactiveTrack =>
      isDark ? const Color(0xFF0A0A12) : const Color(0xFF001B28);

  /// Outer/terminal color of RadialGradient page backgrounds
  Color get gradientEnd => pageBackground;

  /// Pastel overlay alpha — richer in ocean mode so neons glow on teal
  double get pastelAlpha => isDark ? 0.05 : 0.12;
}
