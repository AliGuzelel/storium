import 'dart:math' as math;
import 'package:flutter/material.dart';

class SubtleNoiseOverlay extends StatefulWidget {
  final double opacity;
  final double density;
  final bool animated;
  final Duration duration;

  const SubtleNoiseOverlay({
    super.key,
    this.opacity = 0.03,
    this.density = 0.0012,
    this.animated = true,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<SubtleNoiseOverlay> createState() => _SubtleNoiseOverlayState();
}

class _SubtleNoiseOverlayState extends State<SubtleNoiseOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SubtleNoiseOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animated != widget.animated ||
        oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      if (widget.animated) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            size: Size.infinite,
            painter: _SubtleNoisePainter(
              opacity: widget.opacity,
              density: widget.density,
              phase: _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubtleNoisePainter extends CustomPainter {
  final double opacity;
  final double density;
  final double phase;

  const _SubtleNoisePainter({
    required this.opacity,
    required this.density,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = (size.width * size.height * density).round().clamp(300, 1400);
    final rng = math.Random(1337 + (phase * 1000).round());
    final lightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: opacity * 0.6);
    final darkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withValues(alpha: opacity * 0.45);

    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final d = 0.7 + rng.nextDouble() * 0.9;
      canvas.drawRect(
        Rect.fromLTWH(x, y, d, d),
        i.isEven ? lightPaint : darkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SubtleNoisePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.opacity != opacity ||
      oldDelegate.density != density;
}
