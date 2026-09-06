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
  static ThemeData get lightTheme {
    // Daylight Biosphere — genuinely light theme with near-white mint background
    // and deep forest text. Brightness.light kept so AppThemeColors.isDark = false.
    // All surface colors are driven by AppThemeColors tokens; these Material
    // defaults handle system widgets (TextField, Dialog, AppBar, etc.).
    const Color scaffoldBg = Color(0xFFF5F9F8); // near-white mint
    const Color cardBg = Colors.white;
    const Color textMain = Color(0xFF1A2E28); // deep forest
    const Color textMuted = Color(0xFF4A7165); // muted green

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: AppColors.neonCyan,
      colorScheme: const ColorScheme.light(
        primary: AppColors.neonCyan,
        surface: cardBg,
        onSurface: textMain,
        onPrimary: Colors.white,
      ),
      fontFamily: 'SF Pro',
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shadowColor: const Color(0xFF1A2E28).withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE3EEE9),
        hintStyle: const TextStyle(color: Color(0xFF7AA096)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A2E28), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: const Color(0xFF1A2E28).withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: textMain,
          letterSpacing: 0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: textMain,
          letterSpacing: 0.5,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: textMain,
          letterSpacing: 0.4,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 19.5,
          fontWeight: FontWeight.w800,
          color: textMain,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: textMain,
          letterSpacing: 0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: textMain,
          letterSpacing: 0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: textMain,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textMain,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textMuted,
          height: 1.3,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textMuted,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textMuted,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textMuted,
          letterSpacing: 0.8,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textMuted,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textMuted,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textMain,
        elevation: 0,
      ),
    );
  }

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
