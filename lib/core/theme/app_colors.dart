import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1B8B3C);
  static const Color primaryDark = Color(0xFF156E30);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primarySurface = Color(0xFFE8F5E9);

  static const Color secondary = Color(0xFF66BB6A);
  static const Color secondaryLight = Color(0xFFA5D6A7);

  static const Color accent = Color(0xFF00C853);
  static const Color accentLight = Color(0xFF69F0AE);

  static const Color surfaceLight = Color(0xFFFAFFFB);
  static const Color backgroundLight = Color(0xFFF1F8E9);

  static const Color surfaceDark = Color(0xFF1A1E1A);
  static const Color backgroundDark = Color(0xFF0D1110);

  static const Color cardDark = Color(0xFF242824);

  static const Color textPrimary = Color(0xFF1B5E20);
  static const Color textSecondary = Color(0xFF388E3C);
  static const Color textHint = Color(0xFF81C784);

  static const Color textPrimaryDark = Color(0xFFE8F5E9);
  static const Color textSecondaryDark = Color(0xFFA5D6A7);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  static const Color gold = Color(0xFFFFD700);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);

  static const Color shimmerBase = Color(0x1A000000);
  static const Color shimmerHighlight = Color(0x0A000000);

  static const Color glassLight = Color(0x1Affffff);
  static const Color glassDark = Color(0x1A000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFF7C948)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> chartColors = [
    Color(0xFF1B8B3C),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFFEF5350),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
  ];
}
