import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../../theme/app_themes.dart';

/// Subtle theme-specific atmosphere (petals, leaves, dust, etc.). Lightweight.
class GardenThemeParticlesLayer extends StatefulWidget {
  const GardenThemeParticlesLayer({super.key, required this.themeColor});

  final String themeColor;

  @override
  State<GardenThemeParticlesLayer> createState() =>
      _GardenThemeParticlesLayerState();
}

class _GardenThemeParticlesLayerState extends State<GardenThemeParticlesLayer>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() => _elapsed = elapsed);
    });
    _ticker.start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureTicker());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureTicker();
  }

  void _ensureTicker() {
    if (!mounted) return;
    if (TickerMode.of(context) && !_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = AppThemes.normalizeThemeColor(widget.themeColor);
    if (key == 'blue') return const SizedBox.shrink();

    final sec = _elapsed.inMicroseconds / 1e6;
    return LayoutBuilder(
      builder: (context, c) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: _ThemeParticlesPainter(themeKey: key, seconds: sec),
            size: Size(c.maxWidth, c.maxHeight),
          ),
        );
      },
    );
  }
}

class _ThemeParticlesPainter extends CustomPainter {
  _ThemeParticlesPainter({
    required this.themeKey,
    required this.seconds,
  });

  final String themeKey;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    switch (themeKey) {
      case 'purple':
        _paintDreamyLights(canvas, size);
        break;
      case 'green':
        _paintLeaves(canvas, size);
        break;
      case 'yellow':
        _paintHoneyDust(canvas, size);
        break;
      case 'pink':
        _paintPetals(canvas, size);
        break;
      case 'red':
        _paintCherryMotes(canvas, size);
        break;
      case 'grayscale':
        _paintAshMotes(canvas, size);
        break;
      default:
        break;
    }
  }

  void _paintDreamyLights(Canvas canvas, Size size) {
    const n = 12;
    final loop = 28.0;
    for (var i = 0; i < n; i++) {
      final u = (seconds / loop + i * 0.07) % 1.0;
      final x = size.width * (0.08 + (i * 0.79 / n) + math.sin(seconds * 0.15 + i) * 0.04);
      final y = size.height * (0.12 + u * 0.38);
      final a = 0.05 + 0.06 * (1 - u);
      final r = 2.2 + (i % 3) * 0.9;
      final p = Paint()
        ..color = Color.lerp(
          const Color(0xFFE8D5FF),
          const Color(0xFFB794F4),
          (i % 4) / 4,
        )!.withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  void _paintLeaves(Canvas canvas, Size size) {
    const n = 11;
    final loop = 32.0;
    for (var i = 0; i < n; i++) {
      final u = (seconds / loop + i * 0.09) % 1.0;
      final x = size.width * (0.05 + u * 0.88 + math.sin(seconds * 0.12 + i * 0.8) * 0.03);
      final y = size.height * (0.1 + (i % 5) * 0.06 + math.sin(seconds * 0.2 + i) * 0.02);
      final a = 0.07 + 0.05 * math.sin(seconds * 0.5 + i);
      final paint = Paint()
        ..color = const Color(0xFF4A7C59).withValues(alpha: a.clamp(0.04, 0.12));
      final ox = Offset(x, y);
      canvas.save();
      canvas.translate(ox.dx, ox.dy);
      canvas.rotate(-0.35 + (i % 3) * 0.12);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 5.5, height: 3.2),
        paint,
      );
      canvas.restore();
    }
  }

  void _paintHoneyDust(Canvas canvas, Size size) {
    const n = 11;
    final loop = 28.0;
    for (var i = 0; i < n; i++) {
      final u = (seconds / loop + i * 0.06) % 1.0;
      final x = size.width * (0.1 + (i * 0.75 / n) + math.sin(seconds * 0.14 + i) * 0.04);
      final y = size.height * (0.52 - u * 0.38);
      final a = (0.035 + 0.032 * (1 - u)) * 0.85;
      final p = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFF3C4),
          const Color(0xFFE8B84A),
          (i % 5) / 5,
        )!.withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), 1.2 + (i % 3) * 0.4, p);
    }
  }

  void _paintPetals(Canvas canvas, Size size) {
    const n = 13;
    final loop = 36.0;
    for (var i = 0; i < n; i++) {
      final u = (seconds / loop + i * 0.08) % 1.0;
      final drift = seconds * (12 + (i % 4) * 2);
      final x = size.width * (0.92 - u * 0.95) + math.sin(drift * 0.02 + i) * 12;
      final y = size.height * (0.08 + u * 0.45) + (i % 3) * 6.0;
      final a = 0.08 + 0.04 * math.sin(seconds * 0.4 + i);
      final paint = Paint()
        ..color = const Color(0xFFF8BBD0).withValues(alpha: a.clamp(0.05, 0.13));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(0.5 + math.sin(seconds * 0.15 + i) * 0.2);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 5, height: 3.4),
        paint,
      );
      canvas.restore();
    }
  }

  void _paintCherryMotes(Canvas canvas, Size size) {
    const n = 12;
    final loop = 26.0;
    for (var i = 0; i < n; i++) {
      final u = (seconds / loop + i * 0.07) % 1.0;
      final x = size.width * (0.06 + u * 0.86 + math.sin(seconds * 0.14 + i) * 0.025);
      final y = size.height * (0.14 + u * 0.36 + (i % 4) * 0.02);
      final a = 0.09 + 0.05 * (1 - u);
      final p = Paint()
        ..color = const Color(0xFF6B1A1A).withValues(alpha: a.clamp(0.06, 0.14));
      canvas.drawCircle(Offset(x, y), 2.0 + (i % 3) * 0.45, p);
    }
  }

  void _paintAshMotes(Canvas canvas, Size size) {
    const n = 4;
    final loop = 48.0;
    for (var i = 0; i < n; i++) {
      final u = (seconds / loop + i * 0.17) % 1.0;
      final baseX = 0.18 + i * 0.22;
      final x = size.width * (baseX + math.sin(seconds * 0.06 + i * 1.1) * 0.04);
      final y = size.height * (0.22 + u * 0.2 + i * 0.03);
      final p = Paint()
        ..color = Colors.white.withValues(alpha: 0.035);
      canvas.drawCircle(Offset(x, y), 1.8, p);
    }
  }

  @override
  bool shouldRepaint(covariant _ThemeParticlesPainter oldDelegate) =>
      oldDelegate.themeKey != themeKey || oldDelegate.seconds != seconds;
}
