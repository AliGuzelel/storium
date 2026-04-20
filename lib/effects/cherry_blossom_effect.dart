import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/monotonic_seconds_ticker.dart';

class CherryBlossomEffect extends StatefulWidget {
  const CherryBlossomEffect({super.key, this.subtle = false});

  final bool subtle;

  static const String assetPath = 'assets/images/cherry_blossom_theme.png';

  @override
  State<CherryBlossomEffect> createState() => _CherryBlossomEffectState();
}

class _CherryBlossomEffectState extends State<CherryBlossomEffect> {
  static const int _particleCountFull = 56;
  static const int _particleCountSubtle = 18;
  static const double _loopSec = 22;

  late List<_PetalParticle> _petals;
  ui.Image? _blossomImage;
  int _loadGeneration = 0;

  void _rebuildPetals() {
    final rng = math.Random(27);
    final n = widget.subtle ? _particleCountSubtle : _particleCountFull;
    _petals = List<_PetalParticle>.generate(
      n,
      (_) => _PetalParticle.random(rng, subtle: widget.subtle),
    );
  }

  @override
  void initState() {
    super.initState();
    _rebuildPetals();
    _loadBlossomImage();
  }

  @override
  void didUpdateWidget(covariant CherryBlossomEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subtle != widget.subtle) {
      _rebuildPetals();
      _loadBlossomImage();
    }
  }

  Future<void> _loadBlossomImage() async {
    final gen = ++_loadGeneration;
    try {
      final data = await rootBundle.load(CherryBlossomEffect.assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (!mounted || gen != _loadGeneration) {
        frame.image.dispose();
        return;
      }
      setState(() {
        _blossomImage?.dispose();
        _blossomImage = frame.image;
      });
    } catch (e, st) {
      debugPrint('CherryBlossomEffect asset load failed: $e\n$st');
      if (mounted && gen == _loadGeneration) {
        setState(() {
          _blossomImage?.dispose();
          _blossomImage = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _blossomImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: MonotonicSecondsTicker(
          builder: (_, seconds) {
            return CustomPaint(
              size: Size.infinite,
              painter: _CherryBlossomPainter(
                seconds: seconds,
                loopSec: _loopSec,
                petals: _petals,
                blossomImage: _blossomImage,
                subtle: widget.subtle,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CherryBlossomPainter extends CustomPainter {
  const _CherryBlossomPainter({
    required this.seconds,
    required this.loopSec,
    required this.petals,
    required this.blossomImage,
    required this.subtle,
  });

  final double seconds;
  final double loopSec;
  final List<_PetalParticle> petals;
  final ui.Image? blossomImage;
  final bool subtle;

  /// Horizontal drift per full animation loop (0→1), as fraction of width (leftward).
  static const double _windDriftPerLoop = 0.09;

  static double _wrapUnit(double v) => v - v.floorToDouble();

  @override
  void paint(Canvas canvas, Size size) {
    final image = blossomImage;
    if (image == null) return;

    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final cycles = seconds / loopSec;
    final time = seconds * (2 * math.pi / loopSec);
    final m = subtle ? 0.62 : 1.0;
    final opacityScale = subtle ? 0.45 : 1.0;

    for (final p in petals) {
      final t = (cycles * p.speed + p.phase) % 1.0;
      final windShift = math.sin((time * 0.09) + p.windOffset * 0.7);
      final horizontalWind = 0.48 *
          math.sin((time * 0.26) + p.windOffset) *
          (p.windStrength + windShift * 0.002) *
          m;
      final sway = 0.48 *
          math.sin((time * 0.16) + p.windOffset) *
          (p.windStrength * 0.72) *
          m;
      final wobble =
          math.sin((time * p.wobbleSpeed * 0.85) + p.phase * 2.1) *
          (p.wobbleAmp * 0.9) *
          m;
      final driftWave = math.sin((t * math.pi * 2) + p.phase) * p.driftX;

      // Smooth right → left carry + slow gusts (normalized 0–1 space).
      final steadyWind =
          cycles * _windDriftPerLoop * (0.92 + p.windStrength * 4.5);
      final slowGust = math.sin(time * 0.10 + p.windOffset * 1.2) * 0.014;
      final longGust = math.sin(time * 0.055 + p.phase * 2.4) * 0.007;

      final xNorm = _wrapUnit(
        p.baseX +
            driftWave +
            horizontalWind +
            sway +
            wobble -
            steadyWind -
            slowGust -
            longGust,
      );
      final x = xNorm * size.width;

      final yBase = (t * 1.15) * size.height + p.offsetY * size.height;
      final fallVariation = math.sin(time + p.windOffset) *
          (0.3 * size.height * 0.0065) *
          m;
      final y = yBase + fallVariation;
      final pulse = p.canPulse
          ? (0.94 + 0.08 * math.sin((t * math.pi * 2) + p.phase * 2.3))
          : 1.0;
      final radius = p.size * pulse;
      final alpha = (p.opacity *
              (0.88 + 0.12 * math.sin((t * math.pi * 2) + p.phase * 1.7)) *
              opacityScale)
          .clamp(subtle ? 0.12 : 0.2, subtle ? 0.38 : 0.6);

      final rotation =
          p.rotationSeed + (t * 2 * math.pi * p.rotationSpeed * p.rotationDir);
      final petalSize =
          (radius * 2).clamp(subtle ? 6.0 : 8.0, subtle ? 30.0 : 48.0);
      final dst = Rect.fromCenter(
        center: Offset.zero,
        width: petalSize,
        height: petalSize,
      );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final layerRect = dst.inflate(2);
      canvas.saveLayer(
        layerRect,
        Paint()..color = Color.fromRGBO(255, 255, 255, alpha.toDouble()),
      );
      canvas.drawImageRect(image, src, dst, Paint());
      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CherryBlossomPainter oldDelegate) {
    return oldDelegate.seconds != seconds ||
        oldDelegate.loopSec != loopSec ||
        oldDelegate.petals != petals ||
        oldDelegate.blossomImage != blossomImage ||
        oldDelegate.subtle != subtle;
  }
}

class _PetalParticle {
  const _PetalParticle({
    required this.baseX,
    required this.offsetY,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.phase,
    required this.driftX,
    required this.blurSigma,
    required this.isSoft,
    required this.canPulse,
    required this.rotationSeed,
    required this.rotationSpeed,
    required this.rotationDir,
    required this.wobbleAmp,
    required this.wobbleSpeed,
    required this.windStrength,
    required this.windOffset,
    required this.shapeBias,
    required this.color,
    required this.centerColor,
    required this.edgeColor,
  });

  final double baseX;
  final double offsetY;
  final double size;
  final double opacity;
  final double speed;
  final double phase;
  final double driftX;
  final double blurSigma;
  final bool isSoft;
  final bool canPulse;
  final double rotationSeed;
  final double rotationSpeed;
  final double rotationDir;
  final double wobbleAmp;
  final double wobbleSpeed;
  final double windStrength;
  final double windOffset;
  final double shapeBias;
  final Color color;
  final Color centerColor;
  final Color edgeColor;

  factory _PetalParticle.random(math.Random rng, {bool subtle = false}) {
    const palette = <Color>[
      Color(0x66FFF7FA),
      Color(0x66F5D6E4),
      Color(0x66F8DCE7),
    ];
    const centerPalette = <Color>[
      Color(0x80FFF9FC),
      Color(0x80FFEFF6),
      Color(0x80FBEAF4),
    ];
    const edgePalette = <Color>[
      Color(0x66E7C6D8),
      Color(0x66DDB7CD),
      Color(0x66D9B7D6),
    ];
    final depthRoll = rng.nextDouble();
    final isLarge = depthRoll > 0.82;
    final isSmall = depthRoll < 0.28;
    final isMedium = !isLarge && !isSmall;
    final isSoft = rng.nextDouble() > 0.42;

    final sScale = subtle ? 0.78 : 1.0;
    final size = (isLarge
            ? 13 + rng.nextDouble() * 6
            : isMedium
            ? 9 + rng.nextDouble() * 5
            : 7 + rng.nextDouble() * 3) *
        sScale;
    final opacity = (isLarge
            ? 0.38 + rng.nextDouble() * 0.22
            : isMedium
            ? 0.28 + rng.nextDouble() * 0.22
            : 0.2 + rng.nextDouble() * 0.18) *
        (subtle ? 0.85 : 1.0);
    final speed = (isLarge
            ? 0.3 + rng.nextDouble() * 0.22
            : isMedium
            ? 0.2 + rng.nextDouble() * 0.22
            : 0.14 + rng.nextDouble() * 0.18) *
        (subtle ? 0.92 : 1.0);

    return _PetalParticle(
      baseX: rng.nextDouble(),
      offsetY: (rng.nextDouble() * 0.55) - 0.32,
      size: size,
      opacity: opacity,
      speed: speed,
      phase: rng.nextDouble(),
      driftX: 0.012 + rng.nextDouble() * 0.038,
      blurSigma: isSoft ? 7 + rng.nextDouble() * 8 : 2 + rng.nextDouble() * 3,
      isSoft: isSoft,
      canPulse: rng.nextDouble() > 0.58,
      rotationSeed: rng.nextDouble() * math.pi * 2,
      rotationSpeed: 0.08 + rng.nextDouble() * 0.22,
      rotationDir: rng.nextBool() ? 1.0 : -1.0,
      wobbleAmp: 0.008 + rng.nextDouble() * 0.02,
      wobbleSpeed: 0.45 + rng.nextDouble() * 0.55,
      windStrength: 0.004 + rng.nextDouble() * 0.012,
      windOffset: rng.nextDouble() * math.pi * 2,
      shapeBias: (rng.nextDouble() * 2) - 1,
      color: palette[rng.nextInt(palette.length)],
      centerColor: centerPalette[rng.nextInt(centerPalette.length)],
      edgeColor: edgePalette[rng.nextInt(edgePalette.length)],
    );
  }
}
