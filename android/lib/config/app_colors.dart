import 'package:flutter/material.dart';

class AppColors {
  // Base colors
  static const Color background = Color(0xFF050505);
  static const Color cardBackground = Color(0xFF141414);
  static const Color panelBackground = Color(0xFF1A1A1A);

  // Text colors
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB0B0B0);
  static const Color textDark = Color(0xFF888888);
  static const Color textDarker = Color(0xFF666666);
  static const Color textRed = Color.fromARGB(255, 251, 37, 101);


  // Accent colors
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentGlow = Color(0x663B82F6);

  // HUMAN BODY PATH - Neon Colors
  static const Color neonCyan = Color(0xFF06B6D4);      // Lungs/Brain/Central Systems
  static const Color neonLime = Color(0xFFA3E635);      // Liver/Detox/Filtration
  static const Color neonCrimson = Color(0xFFF43F5E);   // Heart/Blood/Vitality
  static const Color neonViolet = Color(0xFFA855F7);    // Reproduction/Placenta
  static const Color neonOrange = Color(0xFFF97316);    // Entry Points
  static const Color neonWhite = Color(0xFFE2E8F0);     // Physical Attack

  // PLANET EARTH PATH - Planetary Colors
  static const Color neonOcean = Color(0xFF00B4D8);     // Ocean/Hydrosphere
  static const Color neonAtmos = Color(0xFF90E0EF);     // Atmosphere
  static const Color neonBio = Color(0xFF4ADE80);       // Biosphere/Flora/Fauna
  static const Color neonMagma = Color(0xFFD946EF);     // Core/Magma/Magnetic Field
  static const Color neonSource = Color(0xFFFBBF24);    // Sources/Entry Gates
  static const Color neonPhysics = Color(0xFFE5E7EB);   // Physics Properties

  // PASTEL ACCENTS - New Design System
  static const Color pastelAqua = Color(0xFFAEEEEE);    // Resources/Library
  static const Color pastelMint = Color(0xFF98FB98);    // Results/Actions
  static const Color pastelLavender = Color(0xFFC7CEFF); // Ideas/Brainstorm

  // Legacy colors (kept for backward compatibility)
  static const Color placenta = Color(0xFFA855F7);
  static const Color blood = Color(0xFFEF4444);
  static const Color water = Color(0xFF06B6D4);
  static const Color energy = Color(0xFFEAB308);
  static const Color materials = Color(0xFF22C55E);

  // Functional colors
  static const Color border = Color(0xFF333333);
  static const Color borderLight = Color(0x0DFFFFFF);

  // Tag colors
  static const Color tagPdf = Color(0xFFEF4444);
  static const Color tagWeb = Color(0xFF3B82F6);

  // AI Badge colors
  static const Color aiBadgeBackground = Color(0x268B5CF6);
  static const Color aiBadgeBorder = Color(0x4D8B5CF6);
  static const Color aiBadgeText = Color(0xFFA78BFA);


  // Glow colors for neon effects
  static Color neonCyanGlow = neonCyan.withValues(alpha: 0.4);
  static Color neonLimeGlow = neonLime.withValues(alpha: 0.4);
  static Color neonCrimsonGlow = neonCrimson.withValues(alpha: 0.4);
  static Color neonVioletGlow = neonViolet.withValues(alpha: 0.4);
  static Color neonOrangeGlow = neonOrange.withValues(alpha: 0.4);
  static Color neonWhiteGlow = neonWhite.withValues(alpha: 0.3);

  static Color neonOceanGlow = neonOcean.withValues(alpha: 0.4);
  static Color neonAtmosGlow = neonAtmos.withValues(alpha: 0.4);
  static Color neonBioGlow = neonBio.withValues(alpha: 0.4);
  static Color neonMagmaGlow = neonMagma.withValues(alpha: 0.4);
  static Color neonSourceGlow = neonSource.withValues(alpha: 0.4);
  static Color neonPhysicsGlow = neonPhysics.withValues(alpha: 0.3);

  // Control Hub
  static const Color hubBackground = Color(0xFF020205);
  static const Color hubButtonBg = Color(0xFF14141E);
  static const Color hubKnobBg = Color(0xFF1A1A2E);
  static const Color hubTextInactive = Color(0xFF8899A6);
  static const Color cardBgGlass = Color(0xFF0A0F1E);
}
