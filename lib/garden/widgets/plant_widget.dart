import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

import '../../widgets/safe_asset_image.dart';
import '../garden_plant_phase_visuals.dart';
import 'garden_mature_particles.dart';

/// Plant display: phase-based scale/opacity on one image, idle sway, mature particles.
class PlantWidget extends StatefulWidget {
  const PlantWidget({
    super.key,
    required this.imagePath,
    required this.currentPhase,
    this.phaseScaleFactor = 1.0,
    this.glowEpoch = 0,
    required this.glowTint,
    this.ambientMotion = true,
    this.maxWidth = 100,
    this.maxHeight = 125,
    this.bottomOffset = 0,
  });

  final String imagePath;
  final int currentPhase;
  /// Applied to [getScale] so some plants (e.g. Forget-Me-Not) read larger at every phase.
  final double phaseScaleFactor;
  /// Retained for parent API compatibility (watering feedback no longer draws a halo).
  final bool ambientMotion;
  final int glowEpoch;
  final Color glowTint;
  final double maxWidth;
  final double maxHeight;
  final double bottomOffset;

  @override
  State<PlantWidget> createState() => _PlantWidgetState();
}

class _PlantWidgetState extends State<PlantWidget> with TickerProviderStateMixin {
  Ticker? _ambientTicker;
  Duration _ambientElapsed = Duration.zero;
  late final AnimationController _imagePathPulse;
  late String _resolvedImagePath;

  bool get _isMature => widget.currentPhase >= 3;

  static final Curve _phaseCurve = Curves.easeOutCubic;
  static const double _idlePeriodSec = 6.0;
  static const double _idleSwayPx = 3.0;
  static const double _idleRotDeg = 1.5;

  @override
  void initState() {
    super.initState();
    _resolvedImagePath = widget.imagePath;
    _imagePathPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() => setState(() {}));
    if (widget.ambientMotion) {
      _ambientTicker = createTicker((Duration elapsed) {
        setState(() => _ambientElapsed = elapsed);
      })..start();
    }
  }

  @override
  void didUpdateWidget(covariant PlantWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _resolveImagePath(widget.imagePath);
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

  Future<void> _resolveImagePath(String candidatePath) async {
    final target = candidatePath.trim();
    if (target.isEmpty) return;
    try {
      await rootBundle.load(target);
      if (!mounted || _resolvedImagePath == target) return;
      setState(() => _resolvedImagePath = target);
      _imagePathPulse.forward(from: 0);
    } catch (_) {
      // Keep rendering the last successful image if a new stage asset is unavailable.
    }
  }

  @override
  void dispose() {
    _imagePathPulse.dispose();
    _ambientTicker?.dispose();
    super.dispose();
  }

  /// Subtle bump when the raster path swaps (e.g. Forget-Me-Not stage art).
  double get _imagePathChangeScale {
    if (!_imagePathPulse.isAnimating) {
      return 1.0;
    }
    final t = _imagePathPulse.value;
    if (t <= 0.5) {
      return lerpDouble(0.95, 1.05, t / 0.5)!;
    }
    return lerpDouble(1.05, 1.0, (t - 0.5) / 0.5)!;
  }

  /// Slight stage-swap fade to smooth image transitions.
  double get _imagePathChangeOpacity {
    if (!_imagePathPulse.isAnimating) {
      return 1.0;
    }
    return lerpDouble(0.8, 1.0, _imagePathPulse.value)!;
  }

  @override
  Widget build(BuildContext context) {
    final motion = widget.ambientMotion;
    final sec = motion ? _ambientElapsed.inMicroseconds / 1e6 : 0.0;
    final idlePhase = sec * (2 * math.pi / _idlePeriodSec);
    final sway = motion ? math.sin(idlePhase) * _idleSwayPx : 0.0;
    final rot = motion
        ? math.sin(idlePhase + 0.5) * (_idleRotDeg * math.pi / 180)
        : 0.0;

    final w = widget.maxWidth;
    final h = widget.maxHeight;
    final glowBottom = h * 0.35;
    final particleSize = (w * 1.2).clamp(100.0, 260.0);

    final phase = widget.currentPhase;
    final targetScale = getScale(phase) * widget.phaseScaleFactor;
    final targetOpacity = getOpacity(phase) * _imagePathChangeOpacity;

    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
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
                        child: Transform.scale(
                          scale: _imagePathChangeScale,
                          alignment: Alignment.bottomCenter,
                          child: SafeAssetImage(
                            _resolvedImagePath,
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
          ),
        ],
      ),
    );
  }
}
