import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../localization/app_strings.dart';
import '../models/user_session.dart';
import '../providers/settings_manager.dart';
import '../utils/app_asset_precache.dart';
import '../services/achievement_service.dart';
import '../widgets/immersive_back_button.dart';
import '../widgets/localized_text.dart';
import 'garden_models.dart';
import 'garden_storage.dart';
import 'widgets/garden_plant_page.dart' show PlantPage;
import 'widgets/garden_sky_layer.dart';
import 'widgets/garden_sky_theme.dart';
import 'widgets/garden_watering_can.dart';


int _nextGardenPhaseAfterWater(String plantId, int currentPhase) {
  if (plantId == 'forget_me_not') {
    if (currentPhase <= 0) return 1;
    if (currentPhase < 3) return 3;
    return 3;
  }
  return (currentPhase + 1).clamp(0, 3);
}

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> with TickerProviderStateMixin {
  final _rng = math.Random();
  final _pageController = PageController();
  GardenPersistedState _state = const GardenPersistedState();
  bool _loading = true;
  bool _showReplacePicker = false;
  int _pageIndex = 0;
  final Map<String, int> _glowEpochByPlant = {};
  Timer? _cooldownTicker;
  static const Duration _fertilizerReduction = Duration(hours: 3);
  final AchievementService _achievementService = AchievementService();
  late final String _uidScope;

  static const _wateredToastMessage =
      'Watered. Your plant feels a little stronger.';

  late final AnimationController _waterToastOpacity;
  bool _waterToastShowing = false;
  int _waterToastSeq = 0;

  String get _currentPlantId =>
      GardenPlantOption
          .choices[_pageIndex.clamp(0, GardenPlantOption.choices.length - 1)].id;
  GardenPlantOption get _currentPlant => GardenPlantOption.choices.firstWhere(
        (e) => e.id == _currentPlantId,
      );

  GardenPlantSlot get _currentSlot => _state.slotFor(_currentPlantId);

  @override
  void initState() {
    super.initState();
    _uidScope = UserSession.currentUser?.uid ?? 'guest';
    _waterToastOpacity = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _load();
  }

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    _waterToastOpacity.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _presentWaterToast() async {
    final seq = ++_waterToastSeq;
    if (!mounted) return;
    setState(() => _waterToastShowing = true);
    _waterToastOpacity.duration = const Duration(milliseconds: 240);
    await _waterToastOpacity.forward(from: 0);
    if (!mounted || seq != _waterToastSeq) return;
    await Future<void>.delayed(const Duration(seconds: 4));
    if (!mounted || seq != _waterToastSeq) return;
    _waterToastOpacity.duration = const Duration(milliseconds: 420);
    await _waterToastOpacity.reverse(from: 1);
    if (!mounted || seq != _waterToastSeq) return;
    setState(() => _waterToastShowing = false);
  }

  bool get _canWaterNow {
    final next = _currentSlot.nextWaterAllowedAt;
    if (next == null) return true;
    return !DateTime.now().isBefore(next);
  }

  void _syncCooldownTicker() {
    _cooldownTicker?.cancel();
    _cooldownTicker = null;
    final next = _currentSlot.nextWaterAllowedAt;
    if (next == null || !DateTime.now().isBefore(next)) return;
    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final n = _currentSlot.nextWaterAllowedAt;
      if (n == null || !DateTime.now().isBefore(n)) {
        _cooldownTicker?.cancel();
        _cooldownTicker = null;
      }
      setState(() {});
    });
  }

  void _bumpGlow(String plantId) {
    _glowEpochByPlant[plantId] = (_glowEpochByPlant[plantId] ?? 0) + 1;
  }

  Future<void> _load() async {
    final s = await GardenStorage.load(uidScope: _uidScope);
    if (!mounted) return;
    final synced = s.copyWith(selectedPlantPageIndex: 0);
    setState(() {
      _state = synced;
      _pageIndex = 0;
      _loading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(precacheStoriumRasterAssets(context));
      if (_pageController.hasClients) {
        final cur = _pageController.page?.round() ?? 0;
        if (cur != 0) {
          _pageController.jumpToPage(0);
        }
      }
    });
    _syncCooldownTicker();
  }

  Future<void> _persistPageIndex(int i) async {
    final clamped = i.clamp(0, GardenPlantOption.choices.length - 1);
    if (clamped == _state.selectedPlantPageIndex) return;
    final next = _state.copyWith(selectedPlantPageIndex: clamped);
    try {
      await GardenStorage.save(next, uidScope: _uidScope);
      if (mounted) setState(() => _state = next);
    } catch (e, st) {
      debugPrint('GardenStorage.save (page): $e\n$st');
    }
  }

  Future<void> _resetPlantSlot(String plantId) async {
    final next = _state.copyWithSlot(plantId, const GardenPlantSlot());
    try {
      await GardenStorage.save(next, uidScope: _uidScope);
    } catch (e, st) {
      debugPrint('GardenStorage.save (reset): $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Could not save your garden. Please try again.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _state = next;
      _bumpGlow(plantId);
    });
    _syncCooldownTicker();
  }

  Future<void> _onReplacePick(String plantId) async {
    final currentId = _currentPlantId;

    if (plantId != currentId) {
      final idx = GardenPlantOption.choices.indexWhere((e) => e.id == plantId);
      if (idx >= 0) {
        await _pageController.animateToPage(
          idx,
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeOutCubic,
        );
      }
      if (mounted) setState(() => _showReplacePicker = false);
      return;
    }

    final slot = _state.slotFor(currentId);
    if (slot.isMature) {
      final reset = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF3D2B4F),
          title: Text(
            t(ctx, 'garden_reset_same_title'),
            style: const TextStyle(
              fontFamily: 'Cinzel',
              color: Colors.white,
            ),
          ),
          content: Text(
            t(ctx, 'garden_reset_same_body'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                t(ctx, 'garden_keep_as_is'),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                t(ctx, 'garden_reset_plant'),
                style: const TextStyle(color: Color(0xFFB8E0FF)),
              ),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (reset == true) {
        await _resetPlantSlot(currentId);
      }
    }

    if (mounted) setState(() => _showReplacePicker = false);
  }

  Future<void> _water() async {
    final id = _currentPlantId;
    final slot = _state.slotFor(id);
    if (!_canWaterNow) return;

    final now = DateTime.now();

    if (slot.currentPhase >= 3) {
      final cooldown = GardenStorage.randomWaterCooldown(_rng);
      final mature = _state.copyWithSlot(
        id,
        GardenPlantSlot(
          currentPhase: slot.currentPhase,
          lastWateredAt: now,
          nextWaterAllowedAt: now.add(cooldown),
        ),
      );
      try {
        await GardenStorage.save(mature, uidScope: _uidScope);
      } catch (e, st) {
        debugPrint('GardenStorage.save (water): $e\n$st');
        if (!mounted) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('Could not save your garden. Please try again.'),
          ),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _state = mature;
        _bumpGlow(id);
      });
      _syncCooldownTicker();
      if (!mounted) return;
      unawaited(_presentWaterToast());
      return;
    }

    final nextPhase = _nextGardenPhaseAfterWater(id, slot.currentPhase);
    final completed = Set<String>.from(_state.completedPlantTypes);
    if (nextPhase >= 3) {
      completed.add(id);
    }
    final unlockedMatureNow = slot.currentPhase < 3 && nextPhase >= 3;
    final cooldown = GardenStorage.randomWaterCooldown(_rng);
    final updated = _state
        .copyWithSlot(
          id,
          GardenPlantSlot(
            currentPhase: nextPhase,
            lastWateredAt: now,
            nextWaterAllowedAt: now.add(cooldown),
          ),
        )
        .copyWith(completedPlantTypes: completed);

    try {
      await GardenStorage.save(updated, uidScope: _uidScope);
    } catch (e, st) {
      debugPrint('GardenStorage.save (water): $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Could not save your garden. Please try again.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _state = updated;
      _bumpGlow(id);
    });
    if (unlockedMatureNow) {
      unawaited(_achievementService.incrementPlantCount());
    }
    _syncCooldownTicker();
    if (!mounted) return;
    unawaited(_presentWaterToast());
  }

  Future<void> _useFertilizer() async {
    final slot = _currentSlot;
    if (_state.fertilizerCount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(t(context, 'no_fertilizer_left'))),
      );
      return;
    }
    final next = slot.nextWaterAllowedAt;
    final now = DateTime.now();
    if (slot.isMature || next == null || !now.isBefore(next)) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(t(context, 'no_growth_time_to_reduce'))),
      );
      return;
    }

    final reducedNext = next.subtract(_fertilizerReduction);
    final clampedNext = reducedNext.isBefore(now) ? now : reducedNext;
    final updated = _state
        .copyWithSlot(
          _currentPlantId,
          slot.copyWith(nextWaterAllowedAt: clampedNext),
        )
        .copyWith(fertilizerCount: (_state.fertilizerCount - 1).clamp(0, 999999));
    try {
      await GardenStorage.save(updated, uidScope: _uidScope);
    } catch (e, st) {
      debugPrint('GardenStorage.save (fertilizer): $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Could not save your garden. Please try again.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _state = updated;
      _bumpGlow(_currentPlantId);
    });
    _syncCooldownTicker();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(t(context, 'growth_time_reduced'))),
    );
  }

  String _formatHms(Duration d) {
    if (d.isNegative) return '0:00:00';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget? _buildCooldownLine(BuildContext context) {
    final slot = _currentSlot;
    if (slot.isMature || _canWaterNow) return null;
    final next = slot.nextWaterAllowedAt;
    final left = next == null
        ? Duration.zero
        : next.difference(DateTime.now());
    final timeStr = _formatHms(left.isNegative ? Duration.zero : left);
    return Text(
      t(context, 'garden_come_back_in').replaceAll('{time}', timeStr),
      textAlign: TextAlign.center,
      style: GoogleFonts.dancingScript(
        fontSize: 22,
        color: Colors.white.withValues(alpha: 0.96),
        height: 1.35,
      ),
    );
  }

  Widget _buildSoilAction(BuildContext context, Color accentGlow) {
    final slot = _currentSlot;

    if (slot.isMature) {
      return _GardenSoilButton(
        label: t(context, 'garden_fully_grown_cta'),
        onPressed: () => setState(() => _showReplacePicker = true),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GardenWateringCan(
              enabled: _canWaterNow,
              onWater: _water,
              accentGlow: accentGlow,
            ),
            const SizedBox(width: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                elevation: 0,
              ),
              onPressed: _useFertilizer,
              child: const Text('🌱', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(GardenPlantOption.choices.length, (i) {
        final active = i == _pageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 9 : 6,
          height: active ? 9 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: active ? 0.88 : 0.34),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.25),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsManager>();
    final brightness = Theme.of(context).brightness;
    final glowTint = gardenPlantGlowTint(settings.themeColor);

    return Scaffold(
      backgroundColor: const Color(0xFF5A9CE0),
      
      body: Stack(
        fit: StackFit.expand,
        children: [
          GardenSkyLayer(
            themeColor: settings.themeColor,
            brightness: brightness,
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else
            Column(
              children: [
                Expanded(
                  flex: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) {
                          setState(() => _pageIndex = i);
                          _syncCooldownTicker();
                          unawaited(_persistPageIndex(i));
                        },
                        itemCount: GardenPlantOption.choices.length,
                        itemBuilder: (context, index) {
                          final option = GardenPlantOption.choices[index];
                          final slot = _state.slotFor(option.id);
                          return PlantPage(
                            imagePath: option.resolvedImagePath(
                              slot.currentPhase,
                            ),
                            plantImageHeight: option.plantImageHeight,
                            plantImageWidthFactor: option.plantImageWidthFactor,
                            bottomOffset: option.bottomOffset,
                            plantPhaseScaleFactor: option.plantPhaseScaleFactor,
                            currentPhase: slot.currentPhase,
                            glowEpoch: _glowEpochByPlant[option.id] ?? 0,
                            glowTint: glowTint,
                            plantAmbientMotion: settings.themeColor != 'yellow',
                          );
                        },
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 10,
                        child: _buildPageDots(),
                      ),
                      Positioned(
                        top: 12,
                        left: 62,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Text(
                            '${t(context, 'fertilizer')}: ${_state.fertilizerCount}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 28,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4E8F58),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x28000000),
                              blurRadius: 3,
                              offset: Offset(0, -1),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: const Color(0xFF5A3E2B),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                            child: Builder(
                              builder: (ctx) {
                                final countdown = _buildCooldownLine(ctx);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (countdown != null) ...[
                                      countdown,
                                      const SizedBox(height: 16),
                                    ],
                                    LocalizedText(
                                      _currentPlant.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Cinzel',
                                        fontSize: 22,
                                        color: Color(0xE6FFFFFF),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LocalizedText(
                                      _currentPlant.description,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        height: 1.4,
                                        color: Colors.white
                                            .withValues(alpha: 0.64),
                                      ),
                                    ),
                                    const Spacer(),
                                    _buildSoilAction(ctx, glowTint),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (!_loading && _waterToastShowing)
            _GardenWaterToastBanner(
              message: _wateredToastMessage,
              opacity: _waterToastOpacity,
            ),
          if (!_loading && _showReplacePicker)
            _PlantPickerOverlay(
              replaceMode: true,
              completedIds: _state.completedPlantTypes,
              onPick: _onReplacePick,
              onDismiss: () => setState(() => _showReplacePicker = false),
            ),
          if (Navigator.canPop(context)) const ImmersiveBackButton(),
        ],
      ),
    );
  }
}

class _GardenWaterToastBanner extends StatelessWidget {
  const _GardenWaterToastBanner({
    required this.message,
    required this.opacity,
  });

  final String message;
  final Animation<double> opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 18,
      right: 18,
      top: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 44),
          child: IgnorePointer(
            child: FadeTransition(
              opacity: opacity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.36),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.94),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GardenSoilButton extends StatelessWidget {
  const _GardenSoilButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.22),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: const StadiumBorder(),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.dancingScript(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.15,
        ),
      ),
    );
  }
}

class _PlantPickerOverlay extends StatelessWidget {
  const _PlantPickerOverlay({
    required this.replaceMode,
    required this.completedIds,
    required this.onPick,
    this.onDismiss,
  });

  final bool replaceMode;
  final Set<String> completedIds;
  final Future<void> Function(String plantId) onPick;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: replaceMode ? onDismiss : null,
        child: SafeArea(
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            replaceMode
                                ? t(context, 'garden_pick_again_title')
                                : t(context, 'garden_pick_title'),
                            style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            replaceMode
                                ? t(context, 'garden_pick_again_subtitle')
                                : t(context, 'garden_pick_subtitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 18),
                          for (final option in GardenPlantOption.choices) ...[
                            _PlantOptionCard(
                              option: option,
                              showCompleted: completedIds.contains(option.id),
                              onTap: () => onPick(option.id),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantOptionCard extends StatelessWidget {
  const _PlantOptionCard({
    required this.option,
    required this.onTap,
    required this.showCompleted,
  });

  final GardenPlantOption option;
  final VoidCallback onTap;
  final bool showCompleted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocalizedText(
                    option.name,
                    style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LocalizedText(
                    option.description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
            if (showCompleted)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.lightGreenAccent.withValues(alpha: 0.9),
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
