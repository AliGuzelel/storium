import 'package:flutter/material.dart';

import 'app_gradient_background.dart';
import 'immersive_back_button.dart';
import 'themed_subtle_effect.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final Widget? drawer;
  final bool resizeToAvoidBottomInset;
  final bool addVignette;
  final bool breathe;
  final Duration speed;
  final double amplitude;
  /// Softer theme particles behind content (main/start uses full effect elsewhere).
  final bool subtleThemeOverlay;
  final bool showBackButton;

  const GradientScaffold({
    super.key,
    required this.body,
    this.drawer,
    this.resizeToAvoidBottomInset = true,
    this.addVignette = true,
    this.breathe = true,
    this.speed = const Duration(seconds: 18),
    this.amplitude = 0.12,
    this.subtleThemeOverlay = true,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final showInlineBack = showBackButton && canPop;
    const topBackButtonReserve = 56.0;
    final content = SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsets.only(top: showInlineBack ? topBackButtonReserve : 0),
            child: body,
          ),
          if (showInlineBack) const ImmersiveBackButton(),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: drawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: AppGradientBackground(
        addVignette: addVignette,
        breathe: breathe,
        speed: speed,
        amplitude: amplitude,
        child: subtleThemeOverlay ? ThemedSubtleEffect(child: content) : content,
      ),
    );
  }
}
