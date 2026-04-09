import 'dart:math' as math;

import 'package:flutter/material.dart';

class BlueCloudEffect extends StatefulWidget {
  const BlueCloudEffect({super.key});

  @override
  State<BlueCloudEffect> createState() => _BlueCloudEffectState();
}

class _BlueCloudEffectState extends State<BlueCloudEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_CloudBlob> _backgroundLayer;
  late final List<_CloudBlob> _midLayer;
  late final List<_CloudBlob> _frontLayer;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(88);
    _backgroundLayer = List<_CloudBlob>.generate(
      9,
      (_) => _CloudBlob.random(
        rng: rng,
        minSize: 160,
        maxSize: 300,
        minOpacity: 0.05,
        maxOpacity: 0.11,
        minSpeed: 0.06,
        maxSpeed: 0.11,
      ),
    );
    _midLayer = List<_CloudBlob>.generate(
      11,
      (_) => _CloudBlob.random(
        rng: rng,
        minSize: 110,
        maxSize: 220,
        minOpacity: 0.07,
        maxOpacity: 0.14,
        minSpeed: 0.1,
        maxSpeed: 0.18,
      ),
    );
    _frontLayer = List<_CloudBlob>.generate(
      12,
      (_) => _CloudBlob.random(
        rng: rng,
        minSize: 70,
        maxSize: 150,
        minOpacity: 0.09,
        maxOpacity: 0.18,
        minSpeed: 0.14,
        maxSpeed: 0.24,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
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
            painter: _CloudPainter(
              progress: _controller.value,
              background: _backgroundLayer,
              mid: _midLayer,
              front: _frontLayer,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter({
    required this.progress,
    required this.background,
    required this.mid,
    required this.front,
  });

  final double progress;
  final List<_CloudBlob> background;
  final List<_CloudBlob> mid;
  final List<_CloudBlob> front;

  @override
  void paint(Canvas canvas, Size size) {
    _paintAtmosphericHaze(canvas, size);
    _paintLayer(canvas, size, background, blur: 30);
    _paintLayer(canvas, size, mid, blur: 24);
    _paintLayer(canvas, size, front, blur: 18);
    _paintDither(canvas, size);
  }

  void _paintAtmosphericHaze(Canvas canvas, Size size) {
    final hazePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x226FD1FF),
          Color(0x1FC7E9FF),
          Color(0x1A9BCDF0),
          Color(0x2266B5E8),
        ],
        stops: [0.0, 0.32, 0.66, 1.0],
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
      final t = (progress * blob.speed + blob.phase) % 1.0;
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
        ..strokeWidth = 1.2
        ..color = const Color(
          0xFFFFFFFF,
        ).withValues(alpha: (blob.opacity * 0.38).clamp(0.02, 0.08))
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
    final light = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.018);
    final dark = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF5D8DB0).withValues(alpha: 0.012);
    final count = (size.width * size.height * 0.0009).round().clamp(250, 1100);
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
    return oldDelegate.progress != progress;
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
