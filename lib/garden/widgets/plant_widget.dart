import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../widgets/safe_asset_image.dart';
import '../garden_plant_phase_visuals.dart';
import 'garden_mature_particles.dart';

/// Plant display: phase-based scale/opacity on one image, idle sway, water pulse.
class PlantWidget extends StatefulWidget {
  const PlantWidget({
    super.key,
    required this.imagePath,
    required this.currentPhase,
    this.glowEpoch = 0,
    required this.glowTint,
    this.ambientMotion = true,
    this.maxWidth = 100,
    this.maxHeight = 125,
    this.bottomOffset = 0,
  });

  final String imagePath;
  final int currentPhase;
  /// Idle sway, mature particles, and soft mature halo (Honey theme: false).
  final bool ambientMotion;
  /// Increment to replay the water/plant glow for this instance.
  final int glowEpoch;
  final Color glowTint;
  /// Max layout size for the plant art ([BoxFit.contain] preserves aspect ratio).
  final double maxWidth;
  final double maxHeight;
  /// Compensates transparent padding below the stem in the PNG (+ = move art down).
  final double bottomOffset;

  @override
  State<PlantWidget> createState() => _PlantWidgetState();
}

class _PlantWidgetState extends State<PlantWidget>
    with TickerProviderStateMixin {
  Ticker? _ambientTicker;
  Duration _ambientElapsed = Duration.zero;

  late final AnimationController _glow;
  late final CurvedAnimation _glowCurve;

  bool get _isMature => widget.currentPhase >= 3;

  static final Curve _phaseCurve = Curves.easeOutCubic;

  /// Full sway cycle length (seconds), constant angular speed.
  static const double _idlePeriodSec = 6.0;

  /// Horizontal sway amplitude (px).
  static const double _idleSwayPx = 3.0;

  /// Idle rotation amplitude (degrees each side).
  static const double _idleRotDeg = 1.5;

  @override
  void initState() {
    super.initState();
    if (widget.ambientMotion) {
      _ambientTicker = createTicker((Duration elapsed) {
        setState(() => _ambientElapsed = elapsed);
      })..start();
    }

    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _glowCurve = CurvedAnimation(parent: _glow, curve: Curves.easeOutCubic);

    if (widget.glowEpoch > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _glow.forward(from: 0);
      });
    }
  }

  @override
  void didUpdateWidget(covariant PlantWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.glowEpoch != oldWidget.glowEpoch) {
      _glow.forward(from: 0);
    }
    if (widget.ambientMotion != oldWidget.ambientMotion) {
      if (widget.ambientMotion) {
        _ambientTicker?.dispose();
        _ambientTicker = createTicker((Duration elapsed) {
          setState(() => _ambientElapsed = elapsed);
        })..start();
      } else {
        _ambientTicker?.dispose();
        _ambientTicker = null;
        _ambientElapsed = Duration.zero;
      }
    }
  }

  @override
  void dispose() {
    _ambientTicker?.dispose();
    _glowCurve.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          final motion = widget.ambientMotion;
          final sec = motion ? _ambientElapsed.inMicroseconds / 1e6 : 0.0;
          final idlePhase = sec * (2 * math.pi / _idlePeriodSec);
          final sway = motion ? math.sin(idlePhase) * _idleSwayPx : 0.0;
          final rot = motion
              ? math.sin(idlePhase + 0.5) * (_idleRotDeg * math.pi / 180)
              : 0.0;
          final t = _glowCurve.value;
          final a = ((1.0 - t) * (1.0 - t)).clamp(0.0, 1.0);

          final w = widget.maxWidth;
          final h = widget.maxHeight;
          final glowBottom = h * 0.35;
          final matureGlowSize = (w * 1.05).clamp(96.0, 220.0);
          final particleSize = (w * 1.2).clamp(100.0, 260.0);
          final pulseSize = (w * 0.88).clamp(72.0, 160.0);

          final phase = widget.currentPhase;
          final targetScale = getScale(phase);
          final targetOpacity = getOpacity(phase);

          return Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              if (_isMature && motion)
                Positioned(
                  bottom: glowBottom - 6,
                  child: IgnorePointer(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: matureGlowSize,
                        height: matureGlowSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.glowTint.withValues(alpha: 0.11),
                              widget.glowTint.withValues(alpha: 0.04),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isMature && motion)
                Positioned(
                  bottom: glowBottom - 4,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: particleSize,
                      height: particleSize,
                      child: CustomPaint(
                        painter: GardenMatureParticlesPainter(
                          seconds: sec,
                          accent: widget.glowTint,
                        ),
                      ),
                    ),
                  ),
                ),
              if (a > 0.001)
                Positioned(
                  bottom: glowBottom + 4,
                  child: IgnorePointer(
                    child: Container(
                      width: pulseSize,
                      height: pulseSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.glowTint.withValues(alpha: 0.40 * a),
                            widget.glowTint.withValues(alpha: 0.14 * a),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(sway, 0),
                child: Transform.rotate(
                  angle: rot,
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: w,
                    height: h,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedScale(
                        scale: targetScale,
                        duration: gardenPlantPhaseTransitionDuration,
                        curve: _phaseCurve,
                        alignment: Alignment.bottomCenter,
                        child: AnimatedOpacity(
                          opacity: targetOpacity,
                          duration: gardenPlantPhaseTransitionDuration,
                          curve: _phaseCurve,
                          child: Transform.translate(
                            offset: Offset(0, widget.bottomOffset),
                            child: SafeAssetImage(
                              widget.imagePath,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                              filterQuality: FilterQuality.high,
                              isAntiAlias: true,
                              width: w,
                              height: h,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
