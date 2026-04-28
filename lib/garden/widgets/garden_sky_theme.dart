import 'package:flutter/material.dart';

import '../../theme/app_themes.dart';


LinearGradient gardenSkyGradient(String themeColor, Brightness brightness) {
  final colors = gardenSkyThreeStops(themeColor, brightness);
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: colors,
    stops: const [0.0, 0.52, 1.0],
  );
}

List<Color> gardenSkyThreeStops(String themeColor, Brightness brightness) {
  final key = AppThemes.normalizeThemeColor(themeColor);
  if (brightness == Brightness.dark) {
    switch (key) {
      case 'blue':
        return const [
          Color(0xFF0D1F3D),
          Color(0xFF1E4A7A),
          Color(0xFF3D5F8A),
        ];
      case 'green':
        return const [
          Color(0xFF0D1F16),
          Color(0xFF1A4D3A),
          Color(0xFF2D5C45),
        ];
      case 'yellow':
        return const [
          Color(0xFF2A2210),
          Color(0xFF4A3D18),
          Color(0xFF5C4A28),
        ];
      case 'pink':
        return const [
          Color(0xFF2D1520),
          Color(0xFF5A2840),
          Color(0xFF6A3A50),
        ];
      case 'red':
        return const [
          Color(0xFF1A0A0C),
          Color(0xFF4A1018),
          Color(0xFF3D1818),
        ];
      case 'grayscale':
        return const [
          Color(0xFF121212),
          Color(0xFF2A2A2A),
          Color(0xFF404040),
        ];
      default:
        return const [
          Color(0xFF1A0F2E),
          Color(0xFF3D2A6B),
          Color(0xFF4A4060),
        ];
    }
  }

  switch (key) {
    case 'blue':
      return const [
        Color(0xFF1A4A8C),
        Color(0xFF5BA3E8),
        Color(0xFFD6ECFF),
      ];
    case 'green':
      return const [
        Color(0xFF1B3D2F),
        Color(0xFF3D8F6A),
        Color(0xFFC5D9C8),
      ];
    case 'yellow':
      return const [
        Color(0xFFC9983A),
        Color(0xFFE8C96B),
        Color(0xFFFFF4DC),
      ];
    case 'pink':
      return const [
        Color(0xFFE8A4BC),
        Color(0xFFF5B8CC),
        Color(0xFFFFF0F5),
      ];
    case 'red':
      return const [
        Color(0xFF6B1414),
        Color(0xFFB83232),
        Color(0xFF5C2828),
      ];
    case 'grayscale':
      return const [
        Color(0xFF4A4A4A),
        Color(0xFF7A7A7A),
        Color(0xFFC8C8C8),
      ];
    default:
      return const [
        Color(0xFF4A148C),
        Color(0xFF8E6BBE),
        Color(0xFFE6D5F5),
      ];
  }
}

Color gardenPlantGlowTint(String themeColor) {
  const calmGreen = Color(0xFF6BA37E);
  final accent = AppThemes.secondary(themeColor);
  return Color.lerp(calmGreen, accent, 0.38)!;
}
