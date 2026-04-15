import 'package:flutter/material.dart';

import '../../theme/app_themes.dart';

/// Calm garden sky with a very subtle tint from the app theme.
List<Color> gardenSkyGradientColors(
  String themeColor,
  Brightness brightness,
) {
  const base = [
    Color(0xFF356CB0),
    Color(0xFF4E8FD4),
    Color(0xFF7EB8EC),
    Color(0xFFB9DCF7),
    Color(0xFFDCEEFB),
  ];
  final themed = brightness == Brightness.dark
      ? AppThemes.darkGradient(themeColor)
      : AppThemes.lightGradient(themeColor);
  return List<Color>.generate(base.length, (i) {
    return Color.lerp(base[i], themed[i % themed.length], 0.12)!;
  });
}

Color gardenPlantGlowTint(String themeColor) {
  const calmGreen = Color(0xFF6BA37E);
  final accent = AppThemes.secondary(themeColor);
  return Color.lerp(calmGreen, accent, 0.38)!;
}
