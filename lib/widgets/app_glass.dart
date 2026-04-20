import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/ui_tokens.dart';

class AppGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  const AppGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = UiTokens.surfaceRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: UiTokens.blurSigma,
          sigmaY: UiTokens.blurSigma,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: UiTokens.glassOpacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.fromBorderSide(UiTokens.surfaceBorderSide),
          ),
          child: child,
        ),
      ),
    );
  }
}
