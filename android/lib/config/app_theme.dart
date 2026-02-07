import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension for custom text styles beyond Material's TextTheme
extension CustomTextStyles on TextTheme {
  TextStyle get headlineXL => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    height: 1.25,
  );

  TextStyle get headlineXXL => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    height: 1.2,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.cardBackground,
      ),
      fontFamily: 'SF Pro',
      textTheme: const TextTheme(
        // Display – large screen titles
        displayLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: AppColors.textMain,
          letterSpacing: 0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: AppColors.textMain,
          letterSpacing: 0.5,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.textMain,
          letterSpacing: 0.4,
          height: 1.3,
        ),

        // Headline – section headers, card titles
        headlineLarge: TextStyle(
          fontSize: 19.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textMain,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textMain,
          letterSpacing: 0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textMain,
          letterSpacing: 0.5,
        ),

        // Title – card titles, button text, form labels
        titleLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
          height: 1.3,
        ),


        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textMuted,
          height: 1.3,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textMuted,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
          height: 1.5,
        ),

        // Label – navigation, badges, tags, micro text
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.panelBackground,
        elevation: 0,
      ),
    );
  }
}
