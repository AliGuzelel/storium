import 'package:flutter/material.dart';

class UiTokens {
  static const double pagePadding = 18;
  static const double sectionGap = 18;
  static const double itemGap = 12;

  /// Global default: rounded rectangles use this radius (Space grid, cards, glass).
  static const double surfaceRadius = 10;

  /// Same as [surfaceRadius] — use for medium/large chrome so the app stays consistent.
  static const double radiusMd = surfaceRadius;
  static const double radiusLg = surfaceRadius;

  static const double glassOpacity = 0.1;
  static const double borderOpacity = 0.16;
  static const double blurSigma = 16;

  /// Thin black outline for panels, collection image tiles, and glass cards (not buttons).
  static const BorderSide surfaceBorderSide =
      BorderSide(color: Color(0xFF000000), width: 1);

  static BorderRadius get surfaceBorderRadius =>
      BorderRadius.circular(surfaceRadius);

  /// Rounded corners only (buttons, dialogs, theme shapes without a stroke).
  static RoundedRectangleBorder roundedShapeNoBorder([double? radius]) {
    final r = radius ?? surfaceRadius;
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
  }

  /// Rounded rectangle + thin black border (collection grids, bordered panels).
  static RoundedRectangleBorder surfaceShape([double? radius]) {
    final r = radius ?? surfaceRadius;
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(r),
      side: surfaceBorderSide,
    );
  }

  /// [BoxDecoration] with fill, rounded corners, and the standard black border.
  static BoxDecoration surfaceBoxDecoration({
    required Color color,
    double? radius,
    List<BoxShadow>? boxShadow,
  }) {
    final br = radius ?? surfaceRadius;
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(br),
      border: Border.fromBorderSide(surfaceBorderSide),
      boxShadow: boxShadow,
    );
  }

  static const Duration fastAnim = Duration(milliseconds: 180);
  static const Duration pageAnim = Duration(milliseconds: 240);
}
