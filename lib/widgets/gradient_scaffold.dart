import 'package:flutter/material.dart';
import 'app_gradient_background.dart';

class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final bool resizeToAvoidBottomInset;
  final bool addVignette;
  final bool breathe;
  final Duration speed;
  final double amplitude;

  const GradientScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.resizeToAvoidBottomInset = true,
    this.addVignette = true,
    this.breathe = true,
    this.speed = const Duration(seconds: 18),
    this.amplitude = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      drawer: drawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: AppGradientBackground(
        addVignette: addVignette,
        breathe: breathe,
        speed: speed,
        amplitude: amplitude,
        child: SafeArea(child: body),
      ),
    );
  }
}
