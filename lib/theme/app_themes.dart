import 'package:flutter/material.dart';

class AppThemes {
  static const List<String> supportedThemeColors = <String>[
    'purple',
    'blue',
    'green',
    'pink',
    'red',
    'grayscale',
  ];

  static String normalizeThemeColor(String? themeColor) {
    if (themeColor == null) return 'purple';
    return supportedThemeColors.contains(themeColor) ? themeColor : 'purple';
  }

  static ThemeData light(String themeColor) {
    final palette = _palette(themeColor);
    return _buildTheme(
      brightness: Brightness.light,
      primary: palette.primary,
      secondary: palette.secondary,
      isGrayscale: palette.isGrayscale,
    );
  }

  static ThemeData dark(String themeColor) {
    final palette = _palette(themeColor);
    return _buildTheme(
      brightness: Brightness.dark,
      primary: palette.primary,
      secondary: palette.secondary,
      isGrayscale: palette.isGrayscale,
    );
  }

  static Color primary(String themeColor) => _palette(themeColor).primary;
  static Color secondary(String themeColor) => _palette(themeColor).secondary;

  static List<Color> lightGradient(String themeColor) {
    switch (themeColor) {
      case 'blue':
        return const [
          Color(0xFF2948A6),
          Color(0xFF5B7BE0),
          Color(0xFFAFC7FF),
          Color(0xFF5A78D9),
        ];
      case 'green':
        return const [
          Color(0xFF2A6E52),
          Color(0xFF4F9C7F),
          Color(0xFFB8E3CC),
          Color(0xFF4D8C72),
        ];
      case 'pink':
        return const [
          Color(0xFFFAD0DA),
          Color(0xFFF4A7B9),
          Color(0xFFF6BFD0),
          Color(0xFFEFAFC3),
        ];
      case 'red':
        return const [
          Color(0xFF5A1C2A),
          Color(0xFF6D1A1A),
          Color(0xFF7A3A56),
          Color(0xFF4A1A2C),
        ];
      case 'grayscale':
        return const [
          Color(0xFF202020),
          Color(0xFF3B3B3B),
          Color(0xFF7B7B7B),
          Color(0xFF5A5A5A),
        ];
      default:
        return const [
          Color(0xFF3E2A7A),
          Color(0xFF7E5BBE),
          Color(0xFFC8B7F2),
          Color(0xFF6A41A1),
        ];
    }
  }

  static List<Color> darkGradient(String themeColor) {
    switch (themeColor) {
      case 'blue':
        return const [
          Color(0xFF142347),
          Color(0xFF1F376E),
          Color(0xFF355CA8),
          Color(0xFF1A2D59),
        ];
      case 'green':
        return const [
          Color(0xFF122D23),
          Color(0xFF1C4A39),
          Color(0xFF2E6D55),
          Color(0xFF173A2E),
        ];
      case 'pink':
        return const [
          Color(0xFF2B0F1D),
          Color(0xFF4A1630),
          Color(0xFF6A2442),
          Color(0xFF3A1428),
        ];
      case 'red':
        return const [
          Color(0xFF1D0A10),
          Color(0xFF35111D),
          Color(0xFF4A1730),
          Color(0xFF29101A),
        ];
      case 'grayscale':
        return const [
          Color(0xFF080808),
          Color(0xFF161616),
          Color(0xFF2B2B2B),
          Color(0xFF1F1F1F),
        ];
      default:
        return const [
          Color(0xFF1C1530),
          Color(0xFF3B2B65),
          Color(0xFF6A41A1),
          Color(0xFF291C4A),
        ];
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required bool isGrayscale,
  }) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark()
        : ThemeData.light();
    final glassBorderColor = isGrayscale
        ? Colors.white.withOpacity(brightness == Brightness.dark ? 0.32 : 0.28)
        : Colors.white.withOpacity(0.18);
    final glassFillColor = isGrayscale
        ? Colors.white.withOpacity(brightness == Brightness.dark ? 0.16 : 0.14)
        : Colors.white.withOpacity(0.12);
    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Poppins',
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      colorScheme: brightness == Brightness.dark
          ? ColorScheme.dark(
              primary: primary,
              secondary: secondary,
              surface: const Color(0xFF1E1E1E),
            )
          : ColorScheme.light(
              primary: primary,
              secondary: secondary,
              surface: const Color(0xFFF5F5F5),
            ),
      iconTheme: IconThemeData(color: secondary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: glassFillColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: glassBorderColor),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: glassBorderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: primary),
        actionsIconTheme: IconThemeData(color: primary),
        backgroundColor: Colors.transparent,
      ),
      scaffoldBackgroundColor: Colors.transparent,
    );
  }

  static _ThemePalette _palette(String themeColor) {
    switch (normalizeThemeColor(themeColor)) {
      case 'blue':
        return const _ThemePalette(
          primary: Color(0xFF2C5CCF),
          secondary: Color(0xFF6D9CFF),
        );
      case 'green':
        return const _ThemePalette(
          primary: Color(0xFF2E8B57),
          secondary: Color(0xFF76C893),
        );
      case 'pink':
        return const _ThemePalette(
          primary: Color(0xFFF4A7B9),
          secondary: Color(0xFFE78AA4),
        );
      case 'red':
        return const _ThemePalette(
          primary: Color(0xFF6D1A1A),
          secondary: Color(0xFF8B2F45),
        );
      case 'grayscale':
        return const _ThemePalette(
          primary: Color(0xFFF0F0F0),
          secondary: Color(0xFFCFCFCF),
          isGrayscale: true,
        );
      default:
        return const _ThemePalette(
          primary: Color(0xFF451B80),
          secondary: Color(0xFF6A41A1),
        );
    }
  }
}

class _ThemePalette {
  final Color primary;
  final Color secondary;
  final bool isGrayscale;
  const _ThemePalette({
    required this.primary,
    required this.secondary,
    this.isGrayscale = false,
  });
}
