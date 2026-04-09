import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_manager.dart';
import '../theme/app_themes.dart';
import 'subtle_noise_overlay.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Duration duration;

  const AnimatedGradientBackground({
    super.key,
    this.duration = const Duration(seconds: 16),
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsManager>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark
        ? AppThemes.darkGradient(settings.themeColor)
        : AppThemes.lightGradient(settings.themeColor);
    const smoothedStops = [0.0, 0.14, 0.28, 0.46, 0.62, 0.8, 1.0];

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        final wave = (math.sin(t * 2 * math.pi) + 1) / 2;
        final shifted = [
          Color.lerp(palette[0], palette[1], wave)!,
          Color.lerp(palette[1], palette[2], 1 - wave)!,
          Color.lerp(palette[2], palette[3], wave)!,
          Color.lerp(palette[3], palette[0], 1 - wave)!,
        ];
        final smoothShifted = _smoothColors(shifted);

        final begin = Alignment(-0.9 + (wave * 0.35), -1.0 + (wave * 0.2));
        final end = Alignment(1.0 - (wave * 0.25), 0.9);

        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    stops: smoothedStops,
                    colors: smoothShifted,
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: SubtleNoiseOverlay(opacity: 0.03, density: 0.0013),
            ),
          ],
        );
      },
    );
  }

  List<Color> _smoothColors(List<Color> source) {
    if (source.length < 4) return source;
    return [
      source[0],
      Color.lerp(source[0], source[1], 0.5)!,
      source[1],
      Color.lerp(source[1], source[2], 0.5)!,
      source[2],
      Color.lerp(source[2], source[3], 0.5)!,
      source[3],
    ];
  }
}
