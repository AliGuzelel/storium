import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;


class GardenCloudLayerSpec {
  const GardenCloudLayerSpec({
    required this.travelDuration,
    required this.verticalFraction,
    this.horizontalPhase = 0,
    this.opacity = 0.15,
    this.scale = 1.0,
    this.shape = 0,
  });

  final Duration travelDuration;
  final double verticalFraction;
  final double horizontalPhase;
  final double opacity;
  final double scale;
  final int shape;
}


const List<GardenCloudLayerSpec> kGardenCloudLayerSpecs = [
  GardenCloudLayerSpec(
    travelDuration: Duration(seconds: 54),
    verticalFraction: 0.07,
    horizontalPhase: 0.05,
    opacity: 0.068,
    scale: 0.54,
    shape: 2,
  ),
  GardenCloudLayerSpec(
    travelDuration: Duration(seconds: 46),
    verticalFraction: 0.20,
    horizontalPhase: 0.32,
    opacity: 0.076,
    scale: 0.70,
    shape: 1,
  ),
  GardenCloudLayerSpec(
    travelDuration: Duration(seconds: 60),
    verticalFraction: 0.36,
    horizontalPhase: 0.69,
    opacity: 0.072,
    scale: 1.06,
    shape: 0,
  ),
  GardenCloudLayerSpec(
    travelDuration: Duration(seconds: 42),
    verticalFraction: 0.53,
    horizontalPhase: 0.46,
    opacity: 0.062,
    scale: 0.84,
    shape: 1,
  ),
  GardenCloudLayerSpec(
    travelDuration: Duration(seconds: 50),
    verticalFraction: 0.70,
    horizontalPhase: 0.10,
    opacity: 0.058,
    scale: 0.60,
    shape: 2,
  ),
  GardenCloudLayerSpec(
    travelDuration: Duration(seconds: 38),
    verticalFraction: 0.12,
    horizontalPhase: 0.86,
    opacity: 0.066,
    scale: 0.94,
    shape: 0,
  ),
  GardenCloudLayerSpec(
    travelDuration: Duration(seconds: 48),
    verticalFraction: 0.46,
    horizontalPhase: 0.60,
    opacity: 0.064,
    scale: 0.78,
    shape: 1,
  ),
];



class GardenCloudsBand extends StatefulWidget {
  const GardenCloudsBand({
    super.key,
    this.specs = kGardenCloudLayerSpecs,
  });

  final List<GardenCloudLayerSpec> specs;

  @override
  State<GardenCloudsBand> createState() => _GardenCloudsBandState();
}

class _GardenCloudsBandState extends State<GardenCloudsBand>
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
    final elapsedSec = _elapsed.inMicroseconds / 1e6;
    return LayoutBuilder(
      builder: (context, c) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: _BatchCloudPainter(
              elapsedSec: elapsedSec,
              specs: widget.specs,
            ),
            size: Size(c.maxWidth, c.maxHeight),
          ),
        );
      },
    );
  }
}

void _paintDriftingCloud(
  Canvas canvas,
  Size size,
  double elapsedSec,
  GardenCloudLayerSpec spec,
) {
  final verticalY = size.height * spec.verticalFraction;
  final horizontalPhase = spec.horizontalPhase.clamp(0.0, 0.999);
  final shapeIndex = spec.shape;

  final cloudW = size.width * 0.42 * spec.scale;
  final cloudH = cloudW * 0.48;
  final travel = size.width + cloudW * 1.35;
  final durationSec = spec.travelDuration.inMicroseconds / 1e6;
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
        Colors.white.withValues(alpha: spec.opacity * 0.98),
        Colors.white.withValues(alpha: spec.opacity * 0.76),
        Colors.white.withValues(alpha: spec.opacity * 0.30),
      ],
      stops: const [0.0, 0.48, 1.0],
    ).createShader(rect)
    ..style = PaintingStyle.fill;

  canvas.drawPath(path, fill);

  final rim = Paint()
    ..color = Colors.white.withValues(alpha: spec.opacity * 0.20)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7;
  canvas.drawPath(path, rim);
}

class _BatchCloudPainter extends CustomPainter {
  _BatchCloudPainter({
    required this.elapsedSec,
    required this.specs,
  });

  final double elapsedSec;
  final List<GardenCloudLayerSpec> specs;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    for (final spec in specs) {
      _paintDriftingCloud(canvas, size, elapsedSec, spec);
    }
  }

  @override
  bool shouldRepaint(covariant _BatchCloudPainter oldDelegate) =>
      oldDelegate.elapsedSec != elapsedSec || oldDelegate.specs != specs;
}

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
