import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
    final colors = isDark ? AppColors.darkGradient : AppColors.lightGradient;

    Widget paint(Alignment begin, Alignment end, double radius, double alpha) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: const [0.0, 0.35, 0.75, 1.0],
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            if (widget.addVignette)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.0, -0.15),
                        radius: radius,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(alpha),
                        ],
                        stops: const [0.65, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            widget.child,
          ],
        ),
      );
    }

    if (!widget.breathe) {
      return paint(
        const Alignment(0, -1),
        const Alignment(1, 1),
        1.1,
        isDark ? 0.25 : 0.15,
      );
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = (math.sin(_ctrl.value * 2 * math.pi) + 1) / 2; // 0..1
        final a = widget.amplitude.clamp(0.0, 0.35);
        final begin = Alignment(0.0, -1.0 + a * 0.8 * t);
        final end = Alignment(1.0 - a * t, 1.0);
        final radius = 1.08 + 0.08 * t;
        final alpha = (isDark ? 0.25 : 0.15) + (isDark ? 0.05 : 0.03) * t;
        return paint(begin, end, radius, alpha);
      },
    );
  }
}
