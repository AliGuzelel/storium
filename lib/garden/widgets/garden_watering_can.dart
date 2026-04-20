import 'package:flutter/material.dart';

import '../../widgets/safe_asset_image.dart';

/// Floating watering-can control: soft radial halo, tap scale, light droplet hint.
class GardenWateringCan extends StatefulWidget {
  const GardenWateringCan({
    super.key,
    required this.enabled,
    required this.onWater,
    required this.accentGlow,
  });

  final bool enabled;
  final VoidCallback onWater;
  final Color accentGlow;

  @override
  State<GardenWateringCan> createState() => _GardenWateringCanState();
}

class _GardenWateringCanState extends State<GardenWateringCan>
    with TickerProviderStateMixin {
  late final AnimationController _tapScale;
  late final CurvedAnimation _tapCurve;
  late final AnimationController _drops;

  @override
  void initState() {
    super.initState();
    _tapScale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _tapCurve = CurvedAnimation(
      parent: _tapScale,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
    _drops = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _tapCurve.dispose();
    _tapScale.dispose();
    _drops.dispose();
    super.dispose();
  }

  Future<void> _playTap() async {
    await _tapScale.forward();
    await _tapScale.reverse();
  }

  void _onTap() {
    if (!widget.enabled) return;
    widget.onWater();
    _playTap();
    _drops.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final opacity = widget.enabled ? 1.0 : 0.38;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.enabled ? _onTap : null,
        child: SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.accentGlow.withValues(
                          alpha: widget.enabled ? 0.12 : 0.05,
                        ),
                        Colors.white.withValues(
                          alpha: widget.enabled ? 0.06 : 0.03,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentGlow.withValues(
                          alpha: widget.enabled ? 0.10 : 0.04,
                        ),
                        blurRadius: 18,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _tapCurve,
                builder: (context, child) {
                  final t = _tapCurve.value;
                  final scale = 1.0 - 0.08 * t;
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: SafeAssetImage(
                  'assets/images/wateringcan.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              AnimatedBuilder(
                animation: _drops,
                builder: (context, _) {
                  final p = _drops.value;
                  if (p <= 0.001) return const SizedBox.shrink();
                  return CustomPaint(
                    size: const Size(100, 100),
                    painter: _DropletsPainter(progress: p),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropletsPainter extends CustomPainter {
  _DropletsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.52;
    final baseY = size.height * 0.38;

    for (var i = 0; i < 3; i++) {
      final delay = i * 0.14;
      final u = progress <= delay ? 0.0 : (progress - delay) / (1.0 - delay);
      if (u <= 0) continue;
      final ox = (i - 1) * 7.0;
      final y = baseY - u * 40;
      final fade = (1 - u) * 0.55;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + ox, y),
          width: 3.2 + i * 0.35,
          height: 4.8 + i * 0.45,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = const Color(0xFFB8E0FF).withValues(alpha: 0.4 * fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DropletsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
