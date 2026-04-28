import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../widgets/monotonic_seconds_ticker.dart';


class CloudLayerWidget extends StatefulWidget {
  const CloudLayerWidget({super.key});

  @override
  State<CloudLayerWidget> createState() => _CloudLayerWidgetState();
}

class _CloudLayerWidgetState extends State<CloudLayerWidget> {
  static const double _loopSec = 18;

  late final List<_CloudSpec> _specs;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _specs = List<_CloudSpec>.generate(
      5,
      (_) => _CloudSpec(
        baseYFrac: 0.05 + rng.nextDouble() * 0.32,
        scale: 0.9 + rng.nextDouble() * 0.55,
        speed: 0.55 + rng.nextDouble() * 0.4,
        phase: rng.nextDouble(),
        opacity: 0.18 + rng.nextDouble() * 0.12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: MonotonicSecondsTicker(
          builder: (context, seconds) {
            return LayoutBuilder(
              builder: (context, c) {
                return CustomPaint(
                  painter: _CloudsPainter(
                    phase: seconds / _loopSec,
                    specs: _specs,
                  ),
                  size: Size(c.maxWidth, c.maxHeight),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CloudsPainter extends CustomPainter {
  _CloudsPainter({required this.phase, required this.specs});

  final double phase;
  final List<_CloudSpec> specs;

  double _cloudX(double t, _CloudSpec spec, double width) {
    final u = (t * spec.speed + spec.phase) % 1.0;
    return -width * 0.15 + u * (width * 1.35);
  }

  void _drawCloudBlob(Canvas canvas, Paint paint) {
    canvas.drawOval(
      const Rect.fromLTWH(8, 18, 56, 36),
      paint,
    );
    canvas.drawOval(
      const Rect.fromLTWH(38, 12, 64, 40),
      paint,
    );
    canvas.drawOval(
      const Rect.fromLTWH(70, 20, 44, 28),
      paint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final spec in specs) {
      final x = _cloudX(phase, spec, size.width);
      final y = spec.baseYFrac * size.height;
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(spec.scale);
      final paint = Paint()..color = Colors.white.withValues(alpha: spec.opacity);
      _drawCloudBlob(canvas, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CloudsPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _CloudSpec {
  const _CloudSpec({
    required this.baseYFrac,
    required this.scale,
    required this.speed,
    required this.phase,
    required this.opacity,
  });

  final double baseYFrac;
  final double scale;
  final double speed;
  final double phase;
  final double opacity;
}
