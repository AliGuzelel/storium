import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/monotonic_seconds_ticker.dart';

class BlueCloudEffect extends StatefulWidget {
  const BlueCloudEffect({super.key, this.subtle = false});

  final bool subtle;

  @override
  State<BlueCloudEffect> createState() => _BlueCloudEffectState();
}

class _BlueCloudEffectState extends State<BlueCloudEffect> {
  static const double _loopSec = 26;

  late List<_CloudBlob> _backgroundLayer;
  late List<_CloudBlob> _midLayer;
  late List<_CloudBlob> _frontLayer;

  void _rebuildLayers() {
    final rng = math.Random(88);
    final s = widget.subtle;
    final o = s ? 0.52 : 1.0;
    final sz = s ? 0.82 : 1.0;
    final sp = s ? 0.88 : 1.0;
    _backgroundLayer = List<_CloudBlob>.generate(
      s ? 4 : 9,
      (_) => _CloudBlob.random(
        rng: rng,
        minSize: 160 * sz,
        maxSize: 300 * sz,
        minOpacity: 0.05 * o,
        maxOpacity: 0.11 * o,
        minSpeed: 0.06 * sp,
        maxSpeed: 0.11 * sp,
      ),
    );
    _midLayer = List<_CloudBlob>.generate(
      s ? 5 : 11,
      (_) => _CloudBlob.random(
        rng: rng,
        minSize: 110 * sz,
        maxSize: 220 * sz,
        minOpacity: 0.07 * o,
        maxOpacity: 0.14 * o,
        minSpeed: 0.1 * sp,
        maxSpeed: 0.18 * sp,
      ),
    );
    _frontLayer = List<_CloudBlob>.generate(
      s ? 5 : 12,
      (_) => _CloudBlob.random(
        rng: rng,
        minSize: 70 * sz,
        maxSize: 150 * sz,
        minOpacity: 0.09 * o,
        maxOpacity: 0.18 * o,
        minSpeed: 0.14 * sp,
        maxSpeed: 0.24 * sp,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _rebuildLayers();
  }

  @override
  void didUpdateWidget(covariant BlueCloudEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subtle != widget.subtle) {
      _rebuildLayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: MonotonicSecondsTicker(
          builder: (_, seconds) => CustomPaint(
            size: Size.infinite,
            painter: _CloudPainter(
              phase: seconds / _loopSec,
              background: _backgroundLayer,
              mid: _midLayer,
              front: _frontLayer,
              subtle: widget.subtle,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter({
    required this.phase,
    required this.background,
    required this.mid,
    required this.front,
    required this.subtle,
  });

  /// Monotonic cycle count (seconds / loop duration); used with % for drift.
  final double phase;
  final List<_CloudBlob> background;
  final List<_CloudBlob> mid;
  final List<_CloudBlob> front;
  final bool subtle;

  @override
  void paint(Canvas canvas, Size size) {
    _paintAtmosphericHaze(canvas, size);
    _paintLayer(canvas, size, background, blur: subtle ? 22 : 30);
    _paintLayer(canvas, size, mid, blur: subtle ? 18 : 24);
    _paintLayer(canvas, size, front, blur: subtle ? 14 : 18);
    _paintDither(canvas, size);
  }

  void _paintAtmosphericHaze(Canvas canvas, Size size) {
    final hazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: subtle
            ? const [
                Color(0x136FD1FF),
                Color(0x11C7E9FF),
                Color(0x0E9BCDF0),
                Color(0x1366B5E8),
              ]
            : const [
                Color(0x226FD1FF),
                Color(0x1FC7E9FF),
                Color(0x1A9BCDF0),
                Color(0x2266B5E8),
              ],
        stops: const [0.0, 0.32, 0.66, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, hazePaint);
  }

  void _paintLayer(
    Canvas canvas,
    Size size,
    List<_CloudBlob> layer, {
    required double blur,
  }) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final blob in layer) {
      final t = (phase * blob.speed + blob.phase) % 1.0;
      final xNorm = t;
      final x = (-0.35 + xNorm * 1.7) * size.width;
      final y = blob.baseY * size.height;

      final color = blob.color.withValues(alpha: blob.opacity);
      paint
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

      final w = blob.size;
      final h = blob.size * blob.heightScale;
      _drawCloudBlob(canvas, Offset(x, y), w, h, paint);

      final outlinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = subtle ? 0.9 : 1.2
        ..color = const Color(
          0xFFFFFFFF,
        ).withValues(
          alpha: (blob.opacity * 0.38 * (subtle ? 0.65 : 1.0))
              .clamp(0.02, 0.08),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      _drawCloudBlob(canvas, Offset(x, y), w, h, outlinePaint);
    }
  }

  void _drawCloudBlob(
    Canvas canvas,
    Offset c,
    double w,
    double h,
    Paint paint,
  ) {
    canvas.drawOval(Rect.fromCenter(center: c, width: w, height: h), paint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx - w * 0.24, c.dy - h * 0.08),
        width: w * 0.7,
        height: h * 0.75,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx + w * 0.24, c.dy - h * 0.1),
        width: w * 0.66,
        height: h * 0.72,
      ),
      paint,
    );
  }

  void _paintDither(Canvas canvas, Size size) {
    final a = subtle ? 0.65 : 1.0;
    final light = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.018 * a);
    final dark = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF5D8DB0).withValues(alpha: 0.012 * a);
    var count = (size.width * size.height * 0.0009).round().clamp(250, 1100);
    if (subtle) {
      count = (count * 0.38).round().clamp(90, 420);
    }
    for (int i = 0; i < count; i++) {
      final x = _hash(i * 197 + 11) * size.width;
      final y = _hash(i * 283 + 23) * size.height;
      final d = 0.7 + _hash(i * 109 + 31) * 0.7;
      canvas.drawRect(Rect.fromLTWH(x, y, d, d), i.isEven ? light : dark);
    }
  }

  double _hash(int n) {
    final x = (n * 1103515245 + 12345) & 0x7fffffff;
    return x / 0x7fffffff;
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.subtle != subtle;
  }
}

class _CloudBlob {
  const _CloudBlob({
    required this.baseY,
    required this.size,
    required this.heightScale,
    required this.opacity,
    required this.speed,
    required this.phase,
    required this.color,
  });

  final double baseY;
  final double size;
  final double heightScale;
  final double opacity;
  final double speed;
  final double phase;
  final Color color;

  factory _CloudBlob.random({
    required math.Random rng,
    required double minSize,
    required double maxSize,
    required double minOpacity,
    required double maxOpacity,
    required double minSpeed,
    required double maxSpeed,
  }) {
    const palette = <Color>[
      Color(0x4DFFFFFF),
      Color(0x4DDCF1FF),
      Color(0x4DCFE7FF),
    ];
    return _CloudBlob(
      baseY: -0.15 + rng.nextDouble() * 1.3,
      size: minSize + rng.nextDouble() * (maxSize - minSize),
      heightScale: 0.5 + rng.nextDouble() * 0.35,
      opacity: minOpacity + rng.nextDouble() * (maxOpacity - minOpacity),
      speed: minSpeed + rng.nextDouble() * (maxSpeed - minSpeed),
      phase: rng.nextDouble(),
      color: palette[rng.nextInt(palette.length)],
    );
  }
}
