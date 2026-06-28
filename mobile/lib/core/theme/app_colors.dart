import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF4F46E5);        // Indigo
  static const Color primaryLight = Color(0xFF818CF8);   // Light Indigo
  static const Color primaryDark = Color(0xFF3730A3);    // Dark Indigo

  // Secondary
  static const Color secondary = Color(0xFF7C3AED);      // Violet
  static const Color secondaryLight = Color(0xFFA78BFA); // Light Violet
  static const Color secondaryDark = Color(0xFF5B21B6);  // Dark Violet

  // Accent
  static const Color accent = Color(0xFF06B6D4);         // Cyan
  static const Color accentLight = Color(0xFF67E8F9);    // Light Cyan
  static const Color accentGreen = Color(0xFF10B981);    // Emerald
  static const Color accentOrange = Color(0xFFF59E0B);   // Amber
  static const Color accentRed = Color(0xFFEF4444);      // Red

  // Gradients
  static const List<Color> primaryGradient = [Color(0xFF4F46E5), Color(0xFF7C3AED)];
  static const List<Color> secondaryGradient = [Color(0xFF7C3AED), Color(0xFF06B6D4)];
  static const List<Color> successGradient = [Color(0xFF10B981), Color(0xFF06B6D4)];
  static const List<Color> warmGradient = [Color(0xFFF59E0B), Color(0xFFEF4444)];
  static const List<Color> coolGradient = [Color(0xFF4F46E5), Color(0xFF06B6D4)];

  // Light Theme
  static const Color lightBackground = Color(0xFFF8F9FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFF3F4F6);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF1E1E35);
  static const Color darkBorder = Color(0xFF2D2D4A);
  static const Color darkDivider = Color(0xFF252540);

  // Text Colors - Light
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextHint = Color(0xFF9CA3AF);

  // Text Colors - Dark
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextHint = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // CEFR Level Colors
  static const Color levelA1 = Color(0xFF10B981); // Green - Beginner
  static const Color levelA2 = Color(0xFF34D399); // Light Green
  static const Color levelB1 = Color(0xFF3B82F6); // Blue - Intermediate
  static const Color levelB2 = Color(0xFF6366F1); // Indigo
  static const Color levelC1 = Color(0xFF8B5CF6); // Violet - Advanced
  static const Color levelC2 = Color(0xFFEC4899); // Pink - Mastery

  // Skill Colors
  static const Color readingColor = Color(0xFF3B82F6);
  static const Color writingColor = Color(0xFF10B981);
  static const Color speakingColor = Color(0xFFF59E0B);
  static const Color listeningColor = Color(0xFF8B5CF6);
  static const Color grammarColor = Color(0xFFEC4899);
  static const Color vocabularyColor = Color(0xFF06B6D4);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF4F46E5),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
}
