import 'dart:ui';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../effects/theme_effect_manager.dart';
import '../garden/garden_storage.dart';
import '../localization/app_strings.dart';
import '../models/user_session.dart';
import '../providers/settings_manager.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/immersive_back_button.dart';
import '../services/cloud_blob_state_service.dart';
import '../widgets/localized_text.dart';

class DailyQuestionsPage extends StatefulWidget {
  const DailyQuestionsPage({super.key});

  @override
  State<DailyQuestionsPage> createState() => _DailyQuestionsPageState();
}

class _DailyQuestionsPageState extends State<DailyQuestionsPage>
    with SingleTickerProviderStateMixin {
  static const String _lastCompletedKey = 'daily_questions_last_completed_date';
  static const String _dailyQuestionsDateKey = 'daily_questions_selected_date';
  static const String _dailyQuestionsListKey = 'daily_questions_selected_list';
  static const String _dailyQuestionsPreviousListKey =
      'daily_questions_previous_selected_list';
  static const String _questionsAssetPath = 'assets/data/daily_questions.json';
  static const String _cloudField = 'dailyCheckinJson';
  static const List<String> _requiredCategories = <String>[
    'state',
    'need',
    'reflection',
    'action',
  ];

  final Map<int, String> _selectedAnswers = <int, String>{};
  List<_DailyQuestion> _questions = const <_DailyQuestion>[];
  bool _loading = true;
  bool _completedToday = false;
  bool _saving = false;
  late final AnimationController _questionFlowController;
  bool _questionFlowPlayed = false;

  @override
  void initState() {
    super.initState();
    _questionFlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _loadDailyStatus();
  }

  @override
  void dispose() {
    _questionFlowController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyStatus() async {
    final today = _todayStamp();
    final prefs = await SharedPreferences.getInstance();
    await _hydrateDailyStateFromCloud(prefs);
    final lastCompleted = prefs.getString(_k(_lastCompletedKey));
    final selectedDate = prefs.getString(_k(_dailyQuestionsDateKey));
    final savedQuestions = prefs.getStringList(_k(_dailyQuestionsListKey));

    final bank = await _loadQuestionBank();
    List<_DailyQuestion> todaysQuestions;

    if (selectedDate == today &&
        savedQuestions != null &&
        savedQuestions.length >= 4 &&
        savedQuestions.length <= 5) {
      todaysQuestions = savedQuestions
          .map((prompt) => bank.firstWhere(
                (q) => q.prompt == prompt,
                orElse: () => _DailyQuestion.fallback(prompt),
              ))
          .toList();
    } else {
      if (selectedDate != null &&
          selectedDate != today &&
          savedQuestions != null &&
          savedQuestions.isNotEmpty) {
        await prefs.setStringList(
          _k(_dailyQuestionsPreviousListKey),
          savedQuestions,
        );
      }
      final previousPrompts =
          prefs.getStringList(_k(_dailyQuestionsPreviousListKey))?.toSet() ??
              const <String>{};
      todaysQuestions = _pickDailyQuestions(
        bank,
        avoidPrompts: previousPrompts,
      );
      await prefs.setString(_k(_dailyQuestionsDateKey), today);
      await prefs.setStringList(
        _k(_dailyQuestionsListKey),
        todaysQuestions.map((q) => q.prompt).toList(),
      );
      if (lastCompleted != today) {
        await prefs.remove(_k(_lastCompletedKey));
      }
      await _pushDailyStateToCloud(prefs);
    }

    if (!mounted) return;
    await _pushDailyStateToCloud(prefs);
    final questionCount = todaysQuestions.length.clamp(1, 5);
    const perQuestionDelayMs = 100;
    const perQuestionDurationMs = 240;
    final totalMs =
        ((questionCount - 1) * perQuestionDelayMs) + perQuestionDurationMs;
    _questionFlowController.duration = Duration(milliseconds: totalMs);
    setState(() {
      _questions = todaysQuestions;
      _completedToday = (lastCompleted == today);
      _loading = false;
    });
    if (!_completedToday && !_questionFlowPlayed) {
      _questionFlowPlayed = true;
      _questionFlowController.forward(from: 0);
    }
  }

  Future<List<_DailyQuestion>> _loadQuestionBank() async {
    try {
      final raw = await rootBundle.loadString(_questionsAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) return _fallbackQuestions;
      final questions = decoded
          .whereType<Map<String, dynamic>>()
          .map(_DailyQuestion.fromJson)
          .whereType<_DailyQuestion>()
          .toList();
      if (questions.length < 4) return _fallbackQuestions;
      return questions;
    } catch (_) {
      return _fallbackQuestions;
    }
  }

  List<_DailyQuestion> _pickDailyQuestions(
    List<_DailyQuestion> bank, {
    Set<String> avoidPrompts = const <String>{},
  }) {
    final rng = Random();
    final selected = <_DailyQuestion>[];
    final usedPrompts = <String>{};

    _DailyQuestion? pickOne(List<_DailyQuestion> pool) {
      if (pool.isEmpty) return null;
      final shuffled = List<_DailyQuestion>.from(pool)..shuffle(rng);
      return shuffled.firstWhere(
        (q) => !usedPrompts.contains(q.prompt),
        orElse: () => shuffled.first,
      );
    }

    for (final category in _requiredCategories) {
      final categoryPool = bank.where((q) => q.category == category).toList();
      final filtered = categoryPool
          .where((q) => !avoidPrompts.contains(q.prompt))
          .toList();
      final picked = pickOne(filtered.isNotEmpty ? filtered : categoryPool);
      if (picked == null) continue;
      selected.add(picked);
      usedPrompts.add(picked.prompt);
    }

    List<_DailyQuestion> remainingPool() {
      final filtered = bank
          .where(
            (q) =>
                !usedPrompts.contains(q.prompt) &&
                !avoidPrompts.contains(q.prompt),
          )
          .toList();
      if (filtered.isNotEmpty) return filtered;
      return bank.where((q) => !usedPrompts.contains(q.prompt)).toList();
    }

    while (selected.length < 4) {
      final remaining = remainingPool();
      if (remaining.isEmpty) break;
      final picked = pickOne(remaining);
      if (picked == null) break;
      selected.add(picked);
      usedPrompts.add(picked.prompt);
    }

    final remaining = remainingPool();
    if (remaining.isNotEmpty && rng.nextBool()) {
      final picked = pickOne(remaining);
      if (picked != null) {
        selected.add(picked);
      }
    }

    selected.shuffle(rng);
    return selected.take(5).toList();
  }

  String _todayStamp() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _completeForToday() async {
    if (_selectedAnswers.length != _questions.length) {
      return;
    }

    final alreadyCompletedInCloud = await _isAlreadyCompletedTodayInCloud();
    if (alreadyCompletedInCloud) {
      if (!mounted) return;
      setState(() => _completedToday = true);
      return;
    }

    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_k(_lastCompletedKey), _todayStamp());
    await _pushDailyStateToCloud(prefs);
    try {
      final gardenState = await GardenStorage.load();
      final boosted = gardenState.copyWith(
        fertilizerCount: (gardenState.fertilizerCount + 2).clamp(0, 999999),
      );
      await GardenStorage.save(boosted);
    } catch (_) {
      // If garden storage fails, keep daily completion flow uninterrupted.
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _completedToday = true;
    });
  }

  Future<bool> _isAlreadyCompletedTodayInCloud() async {
    final raw = await CloudBlobStateService.fetch(_cloudField);
    if (raw == null || raw.isEmpty) return false;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return false;
      final map = Map<String, dynamic>.from(decoded);
      final lastCompleted = map['lastCompletedDate'] as String?;
      return lastCompleted == _todayStamp();
    } catch (_) {
      return false;
    }
  }

  Future<void> _hydrateDailyStateFromCloud(SharedPreferences prefs) async {
    final raw = await CloudBlobStateService.fetch(_cloudField);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final map = Map<String, dynamic>.from(decoded);

      final selectedDate = map['selectedDate'] as String?;
      final lastCompleted = map['lastCompletedDate'] as String?;
      final selectedQuestions = (map['selectedQuestions'] as List<dynamic>?)
          ?.whereType<String>()
          .toList();
      final previousQuestions = (map['previousQuestions'] as List<dynamic>?)
          ?.whereType<String>()
          .toList();

      if (selectedDate != null && selectedDate.isNotEmpty) {
        await prefs.setString(_k(_dailyQuestionsDateKey), selectedDate);
      }
      if (lastCompleted != null && lastCompleted.isNotEmpty) {
        await prefs.setString(_k(_lastCompletedKey), lastCompleted);
      }
      if (selectedQuestions != null && selectedQuestions.isNotEmpty) {
        await prefs.setStringList(_k(_dailyQuestionsListKey), selectedQuestions);
      }
      if (previousQuestions != null && previousQuestions.isNotEmpty) {
        await prefs.setStringList(
          _k(_dailyQuestionsPreviousListKey),
          previousQuestions,
        );
      }
    } catch (_) {
      // Keep local prefs when cloud payload cannot be decoded.
    }
  }

  Future<void> _pushDailyStateToCloud(SharedPreferences prefs) async {
    final payload = <String, dynamic>{
      'selectedDate': prefs.getString(_k(_dailyQuestionsDateKey)) ?? '',
      'lastCompletedDate': prefs.getString(_k(_lastCompletedKey)) ?? '',
      'selectedQuestions': prefs.getStringList(_k(_dailyQuestionsListKey)) ?? const [],
      'previousQuestions':
          prefs.getStringList(_k(_dailyQuestionsPreviousListKey)) ?? const [],
    };
    await CloudBlobStateService.push(_cloudField, jsonEncode(payload));
  }

  String _scopeSuffix() {
    final uid = UserSession.currentUser?.uid;
    if (uid == null || uid.isEmpty) return 'guest';
    return uid;
  }

  String _k(String base) => '${base}_${_scopeSuffix()}';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsManager>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        addVignette: true,
        breathe: true,
        child: Stack(
          children: [
            Positioned.fill(
              child: KeyedSubtree(
                key: ValueKey<String>('daily_theme_fx_${settings.themeColor}'),
                child: RepaintBoundary(
                  child: buildThemeEffect(settings.themeColor),
                ),
              ),
            ),
            SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
                    child: _glassPanel(
                      context,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) {
                          final fade = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          );
                          final scale = Tween<double>(begin: 0.95, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          );
                          return FadeTransition(
                            opacity: fade,
                            child: ScaleTransition(
                              scale: scale,
                              child: child,
                            ),
                          );
                        },
                        child: _loading
                            ? const Padding(
                                key: ValueKey<String>('daily-loading'),
                                padding: EdgeInsets.symmetric(vertical: 36),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : (_completedToday
                                ? _buildCompletedState(context)
                                : _buildQuestionnaireState(context)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const ImmersiveBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    return Column(
      key: const ValueKey<String>('daily-completed'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t(context, 'daily_check_in'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        LocalizedText(
          'You showed up today.\nThat matters more than you think.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.88),
            fontWeight: FontWeight.w500,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 18),
        LocalizedText(
          '+2 added to your garden 🌱',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.98),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        LocalizedText(
          "Come back tomorrow, whenever you're ready.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.55,
            color: Colors.white.withValues(alpha: 0.82),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
            child: _continueButton(
              label: t(context, 'continue'),
              enabled: true,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionnaireState(BuildContext context) {
    final canContinue = _selectedAnswers.length == _questions.length && !_saving;
    return Column(
      key: const ValueKey<String>('daily-questionnaire'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t(context, 'daily_check_in'),
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        LocalizedText(
          'A quiet moment for today',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.66),
          ),
        ),
        const SizedBox(height: 14),
        LocalizedText(
          "There's no right answer.\nJust go with what feels closest.",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.56),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 40),
        for (int i = 0; i < _questions.length; i++) ...[
          _buildAnimatedQuestionBlock(i, _questions[i], _questions.length),
          if (i != _questions.length - 1) const SizedBox(height: 36),
        ],
        const SizedBox(height: 42),
        _continueButton(
          label: _saving ? t(context, 'saving') : t(context, 'continue'),
          enabled: canContinue,
          onTap: _completeForToday,
        ),
      ],
    );
  }

  Widget _buildAnimatedQuestionBlock(
    int index,
    _DailyQuestion question,
    int totalQuestions,
  ) {
    const perQuestionDelayMs = 100.0;
    const perQuestionDurationMs = 240.0;
    final safeTotal = totalQuestions.clamp(1, 5);
    final totalMs =
        ((safeTotal - 1) * perQuestionDelayMs) + perQuestionDurationMs;
    final start = ((index * perQuestionDelayMs) / totalMs).clamp(0.0, 1.0);
    final end =
        (((index * perQuestionDelayMs) + perQuestionDurationMs) / totalMs)
            .clamp(0.0, 1.0);
    final curved = CurvedAnimation(
      parent: _questionFlowController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(curved);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: slide,
        child: _buildQuestionBlock(index, question),
      ),
    );
  }

  Widget _buildQuestionBlock(int index, _DailyQuestion question) {
    final selected = _selectedAnswers[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocalizedText(
          '${question.emoji} ${question.prompt}',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.93),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 10,
          runSpacing: 10,
          children: question.options.map((option) {
            final isSelected = selected == option;
            return _optionButton(
              label: option,
              selected: isSelected,
              onTap: () {
                setState(() {
                  _selectedAnswers[index] = option;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _optionButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        scale: selected ? 1.03 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [
                      Colors.white.withValues(alpha: 0.30),
                      Colors.white.withValues(alpha: 0.18),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.17),
                      Colors.white.withValues(alpha: 0.1),
                    ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.62 : 0.3),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.18),
                      blurRadius: 10,
                      spreadRadius: 0.4,
                    ),
                  ]
                : null,
          ),
          child: LocalizedText(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: selected ? 0.99 : 0.92),
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _continueButton({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: enabled
              ? [
                  Colors.white.withValues(alpha: 0.34),
                  Colors.white.withValues(alpha: 0.2),
                ]
              : [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.1),
                ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: enabled ? 0.5 : 0.24),
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.14),
                  blurRadius: 14,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: enabled ? 0.98 : 0.72),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    return AnimatedScale(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      scale: enabled ? 1.0 : 0.995,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: button,
        ),
      ),
    );
  }

  Widget _glassPanel(BuildContext context, {required Widget child}) {
    final screenW = MediaQuery.sizeOf(context).width;
    final panelW = min(screenW - 20, 760.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: panelW,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DailyQuestion {
  const _DailyQuestion({
    required this.prompt,
    required this.options,
    required this.category,
    required this.emoji,
  });

  factory _DailyQuestion.fromJson(Map<String, dynamic> json) {
    final prompt = (json['question'] as String?)?.trim() ?? '';
    final category = (json['category'] as String?)?.trim().toLowerCase() ?? '';
    final emoji = (json['emoji'] as String?)?.trim() ?? '';
    final optionsRaw = json['options'];
    if (prompt.isEmpty || optionsRaw is! List) return _DailyQuestion.fallback(prompt);
    if (!_DailyQuestion.validCategories.contains(category)) {
      return _DailyQuestion.fallback(prompt);
    }
    final options = optionsRaw
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (options.length < 2) return _DailyQuestion.fallback(prompt);
    return _DailyQuestion(
      prompt: prompt,
      options: _DailyQuestion.withNotSure(options.take(4).toList()),
      category: category,
      emoji: emoji.isEmpty ? '🌿' : emoji,
    );
  }

  factory _DailyQuestion.fallback(String prompt) => _DailyQuestion(
        prompt: prompt.isEmpty ? 'Take a quiet moment.' : prompt,
        options: _DailyQuestion.withNotSure(
          const ['Not yet', 'Maybe', 'Yes'],
        ),
        category: 'reflection',
        emoji: '🌿',
      );

  static const Set<String> validCategories = <String>{
    'state',
    'need',
    'reflection',
    'action',
  };

  static List<String> withNotSure(List<String> options) {
    final cleaned = options
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (!cleaned.any((e) => e.toLowerCase() == 'not sure')) {
      cleaned.add('Not sure');
    }
    return cleaned;
  }

  final String prompt;
  final List<String> options;
  final String category;
  final String emoji;
}

const List<_DailyQuestion> _fallbackQuestions = <_DailyQuestion>[
  _DailyQuestion(
    prompt: 'How are you feeling right now?',
    options: ['Calm', 'Okay', 'Heavy', 'Not sure'],
    category: 'state',
    emoji: '😌',
  ),
  _DailyQuestion(
    prompt: 'What do you need more of today?',
    options: ['Rest', 'Focus', 'Connection', 'Not sure'],
    category: 'need',
    emoji: '🤍',
  ),
  _DailyQuestion(
    prompt: 'What is one thing on your mind?',
    options: ['Work', 'People', 'Myself', 'Not sure'],
    category: 'reflection',
    emoji: '🪞',
  ),
  _DailyQuestion(
    prompt: 'What would help you feel grounded?',
    options: ['Quiet time', 'A short walk', 'A deep breath', 'Not sure'],
    category: 'action',
    emoji: '🌱',
  ),
];
