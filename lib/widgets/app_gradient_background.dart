import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../providers/settings_manager.dart';
import '../theme/app_themes.dart';

class AppGradientBackground extends StatefulWidget {
  final Widget child;
  final bool addVignette;
  final bool breathe;
  final Duration speed;
  final double amplitude;

  const AppGradientBackground({
    super.key,
    required this.child,
    this.addVignette = true,
    this.breathe = true,
    this.speed = const Duration(seconds: 18),
    this.amplitude = 0.12,
  });

  @override
  State<AppGradientBackground> createState() => _AppGradientBackgroundState();
}

class _AppGradientBackgroundState extends State<AppGradientBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  SettingsManager? _settings;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      if (!widget.breathe) return;
      setState(() => _elapsed = elapsed);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureTickerRunning());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = context.read<SettingsManager>();
    if (!identical(s, _settings)) {
      _settings?.removeListener(_syncTickerToTheme);
      _settings = s;
      _settings!.addListener(_syncTickerToTheme);
    }
    _syncTickerToTheme();
    _ensureTickerRunning();
  }

  void _ensureTickerRunning() {
    if (!mounted) return;
    if (TickerMode.of(context) && !_ticker.isActive) {
      final run = _gradientBreatheActive;
      if (run) {
        _ticker.start();
      }
    }
  }

  
  
  bool get _gradientBreatheActive {
    if (!widget.breathe) return false;
    final c = _settings?.themeColor;
    if (c == null) return true;
    if (c == 'yellow' || c == 'blue') return false;
    return true;
  }

  bool _breatheForTheme(String themeColor) {
    if (!widget.breathe) return false;
    final key = AppThemes.normalizeThemeColor(themeColor);
    if (key == 'yellow' || key == 'blue') return false;
    return true;
  }

  void _syncTickerToTheme() {
    if (!mounted) return;
    final run = _gradientBreatheActive;
    if (run) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      if (_ticker.isActive) _ticker.stop();
    }
  }

  @override
  void didUpdateWidget(covariant AppGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breathe != widget.breathe) {
      _syncTickerToTheme();
    }
  }

  @override
  void dispose() {
    _settings?.removeListener(_syncTickerToTheme);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsManager>();
    final colors = isDark
        ? AppThemes.darkGradient(settings.themeColor)
        : AppThemes.lightGradient(settings.themeColor);
    final smoothedColors = _smoothColors(colors);
    const smoothedStops = [0.0, 0.14, 0.28, 0.46, 0.62, 0.8, 1.0];

    Widget paint(Alignment begin, Alignment end) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: smoothedStops,
            colors: smoothedColors,
          ),
        ),
        child: widget.child,
      );
    }

    if (!_breatheForTheme(settings.themeColor)) {
      return RepaintBoundary(
        child: paint(const Alignment(0, -1), const Alignment(1, 1)),
      );
    }

    final seconds = _elapsed.inMicroseconds / 1e6;
    final periodSec = widget.speed.inMilliseconds / 1000.0;
    final safePeriod = periodSec < 0.5 ? 0.5 : periodSec;
    final phase = seconds * (2 * math.pi / safePeriod);
    final t = (math.sin(phase) + 1) / 2;
    final a = widget.amplitude.clamp(0.0, 0.35);
    final begin = Alignment(0.0, -1.0 + a * 0.8 * t);
    final end = Alignment(1.0 - a * t, 1.0);
    return RepaintBoundary(child: paint(begin, end));
  }

  List<Color> _smoothColors(List<Color> source) {
    if (source.length < 4) return source;
    return [
      source[0],
      Color.lerp(source[0], source[1], 0.5)!,
      source[1],
      Color.lerp(source[1], source[2], 0.5)!,
      source[2],
      Color.lerp(source[2], source[3], 0.5)!,
      source[3],
    ];
  }
}
