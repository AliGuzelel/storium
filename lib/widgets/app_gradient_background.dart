import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_manager.dart';
import '../theme/app_themes.dart';

class AppGradientBackground extends StatefulWidget {
  final Widget child;
  final bool addVignette;
  final bool breathe;
  final Duration speed;
  final double amplitude;

  const AppGradientBackground({
    super.key,
    required this.child,
    this.addVignette = true,
    this.breathe = true,
    this.speed = const Duration(seconds: 18),
    this.amplitude = 0.12,
  });

  @override
  State<AppGradientBackground> createState() => _AppGradientBackgroundState();
}

class _AppGradientBackgroundState extends State<AppGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.speed);
    if (widget.breathe) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AppGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breathe != widget.breathe ||
        oldWidget.speed != widget.speed) {
      if (widget.breathe) {
        _ctrl
          ..duration = widget.speed
          ..repeat(reverse: true);
      } else {
        _ctrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsManager>();
    final colors = isDark
        ? AppThemes.darkGradient(settings.themeColor)
        : AppThemes.lightGradient(settings.themeColor);
    final smoothedColors = _smoothColors(colors);
    const smoothedStops = [0.0, 0.14, 0.28, 0.46, 0.62, 0.8, 1.0];

    Widget paint(Alignment begin, Alignment end) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: smoothedStops,
            colors: smoothedColors,
          ),
        ),
        child: widget.child,
      );
    }

    if (!widget.breathe) {
      return paint(const Alignment(0, -1), const Alignment(1, 1));
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = (math.sin(_ctrl.value * 2 * math.pi) + 1) / 2; // 0..1
        final a = widget.amplitude.clamp(0.0, 0.35);
        final begin = Alignment(0.0, -1.0 + a * 0.8 * t);
        final end = Alignment(1.0 - a * t, 1.0);
        return paint(begin, end);
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
