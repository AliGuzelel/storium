import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

/// One large cumulus-style cloud built from smooth [Path] geometry (no circles),
/// drifting horizontally with a seamless loop.
class CloudWidget extends StatefulWidget {
  const CloudWidget({
    super.key,
    required this.travelDuration,
    required this.verticalFraction,
    this.horizontalPhase = 0,
    this.opacity = 0.15,
    this.scale = 1.0,
    this.shape = 0,
  });

  final Duration travelDuration;

  /// Vertical anchor in the parent (0 = top, 1 = bottom).
  final double verticalFraction;

  final double horizontalPhase;
  final double opacity;
  final double scale;

  /// 0, 1, or 2 for alternate silhouettes.
  final int shape;

  @override
  State<CloudWidget> createState() => _CloudWidgetState();
}

class _CloudWidgetState extends State<CloudWidget>
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureTickerRunning());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureTickerRunning();
  }

  void _ensureTickerRunning() {
    if (!mounted) return;
    if (TickerMode.of(context) && !_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final w = c.maxWidth;
        final elapsedSec = _elapsed.inMicroseconds / 1e6;
        return RepaintBoundary(
          child: CustomPaint(
            painter: _PathCloudPainter(
              elapsedSec: elapsedSec,
              travelDuration: widget.travelDuration,
              horizontalPhase: widget.horizontalPhase.clamp(0.0, 0.999),
              verticalY: h * widget.verticalFraction,
              opacity: widget.opacity,
              scale: widget.scale,
              shapeIndex: widget.shape,
            ),
            size: Size(w, h),
          ),
        );
      },
    );
  }
}

/// Organic cumulus outline in unit space [0,1]×[0,1], then mapped to [rect].
Path _cumulusPath(Rect rect, int variant) {
  final w = rect.width;
  final h = rect.height;
  final l = rect.left;
  final t = rect.top;

  Path p;
  switch (variant % 3) {
    case 1:
      p = _pathVariantB(l, t, w, h);
      break;
    case 2:
      p = _pathVariantC(l, t, w, h);
      break;
    default:
      p = _pathVariantA(l, t, w, h);
  }
  return p;
}

Path _pathVariantA(double l, double t, double w, double h) {
  final p = Path();
  p.moveTo(l + w * 0.06, t + h * 0.68);
  p.quadraticBezierTo(
    l + w * 0.22,
    t + h * 0.76,
    l + w * 0.42,
    t + h * 0.70,
  );
  p.quadraticBezierTo(
    l + w * 0.58,
    t + h * 0.74,
    l + w * 0.78,
    t + h * 0.66,
  );
  p.quadraticBezierTo(
    l + w * 0.94,
    t + h * 0.62,
    l + w * 0.98,
    t + h * 0.48,
  );
  p.quadraticBezierTo(
    l + w * 1.02,
    t + h * 0.32,
    l + w * 0.92,
    t + h * 0.20,
  );
  p.quadraticBezierTo(
    l + w * 0.82,
    t + h * 0.08,
    l + w * 0.64,
    t + h * 0.10,
  );
  p.quadraticBezierTo(
    l + w * 0.52,
    t + h * 0.04,
    l + w * 0.38,
    t + h * 0.12,
  );
  p.quadraticBezierTo(
    l + w * 0.24,
    t + h * 0.08,
    l + w * 0.12,
    t + h * 0.22,
  );
  p.quadraticBezierTo(
    l - w * 0.02,
    t + h * 0.36,
    l + w * 0.02,
    t + h * 0.52,
  );
  p.quadraticBezierTo(
    l + w * 0.02,
    t + h * 0.62,
    l + w * 0.06,
    t + h * 0.68,
  );
  p.close();
  return p;
}

Path _pathVariantB(double l, double t, double w, double h) {
  final p = Path();
  p.moveTo(l + w * 0.04, t + h * 0.62);
  p.cubicTo(
    l + w * 0.18,
    t + h * 0.72,
    l + w * 0.36,
    t + h * 0.68,
    l + w * 0.52,
    t + h * 0.72,
  );
  p.cubicTo(
    l + w * 0.68,
    t + h * 0.76,
    l + w * 0.88,
    t + h * 0.66,
    l + w * 0.96,
    t + h * 0.50,
  );
  p.cubicTo(
    l + w * 1.04,
    t + h * 0.34,
    l + w * 0.94,
    t + h * 0.16,
    l + w * 0.76,
    t + h * 0.12,
  );
  p.cubicTo(
    l + w * 0.62,
    t + h * 0.06,
    l + w * 0.48,
    t + h * 0.10,
    l + w * 0.34,
    t + h * 0.08,
  );
  p.cubicTo(
    l + w * 0.18,
    t + h * 0.12,
    l + w * 0.02,
    t + h * 0.28,
    l + w * 0.02,
    t + h * 0.44,
  );
  p.cubicTo(
    l + w * 0.02,
    t + h * 0.52,
    l - w * 0.02,
    t + h * 0.58,
    l + w * 0.04,
    t + h * 0.62,
  );
  p.close();
  return p;
}

Path _pathVariantC(double l, double t, double w, double h) {
  final p = Path();
  p.moveTo(l + w * 0.10, t + h * 0.70);
  p.cubicTo(
    l + w * 0.28,
    t + h * 0.78,
    l + w * 0.48,
    t + h * 0.72,
    l + w * 0.66,
    t + h * 0.76,
  );
  p.cubicTo(
    l + w * 0.86,
    t + h * 0.72,
    l + w * 1.00,
    t + h * 0.56,
    l + w * 0.98,
    t + h * 0.38,
  );
  p.cubicTo(
    l + w * 0.96,
    t + h * 0.22,
    l + w * 0.80,
    t + h * 0.10,
    l + w * 0.60,
    t + h * 0.14,
  );
  p.cubicTo(
    l + w * 0.46,
    t + h * 0.06,
    l + w * 0.30,
    t + h * 0.10,
    l + w * 0.16,
    t + h * 0.22,
  );
  p.cubicTo(
    l + w * 0.02,
    t + h * 0.34,
    l - w * 0.04,
    t + h * 0.52,
    l + w * 0.04,
    t + h * 0.64,
  );
  p.cubicTo(
    l + w * 0.06,
    t + h * 0.68,
    l + w * 0.08,
    t + h * 0.70,
    l + w * 0.10,
    t + h * 0.70,
  );
  p.close();
  return p;
}

class _PathCloudPainter extends CustomPainter {
  _PathCloudPainter({
    required this.elapsedSec,
    required this.travelDuration,
    required this.horizontalPhase,
    required this.verticalY,
    required this.opacity,
    required this.scale,
    required this.shapeIndex,
  });

  /// Monotonic clock time for smooth wrap (no snap at loop).
  final double elapsedSec;
  final Duration travelDuration;
  final double horizontalPhase;
  final double verticalY;
  final double opacity;
  final double scale;
  final int shapeIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final cloudW = size.width * 0.42 * scale;
    final cloudH = cloudW * 0.48;
    final travel = size.width + cloudW * 1.35;
    final durationSec = travelDuration.inMicroseconds / 1e6;
    final speed = durationSec > 0 ? travel / durationSec : 0.0;
    final phasePx = horizontalPhase * travel;
    final drift = (elapsedSec * speed + phasePx) % travel;
    final x = -cloudW * 0.35 + drift;
    final cy = verticalY - cloudH * 0.35;
    final rect = Rect.fromLTWH(x, cy, cloudW, cloudH);

    final path = _cumulusPath(rect, shapeIndex);

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: opacity * 0.98),
          Colors.white.withValues(alpha: opacity * 0.76),
          Colors.white.withValues(alpha: opacity * 0.30),
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fill);

    final rim = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    canvas.drawPath(path, rim);
  }

  @override
  bool shouldRepaint(covariant _PathCloudPainter oldDelegate) =>
      oldDelegate.elapsedSec != elapsedSec ||
      oldDelegate.travelDuration != travelDuration ||
      oldDelegate.horizontalPhase != horizontalPhase ||
      oldDelegate.verticalY != verticalY ||
      oldDelegate.opacity != opacity ||
      oldDelegate.scale != scale ||
      oldDelegate.shapeIndex != shapeIndex;
}
