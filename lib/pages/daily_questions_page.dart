import 'dart:ui';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../effects/theme_effect_manager.dart';
import '../garden/garden_storage.dart';
import '../providers/settings_manager.dart';
import '../widgets/app_button.dart';
import '../widgets/app_gradient_background.dart';

class DailyQuestionsPage extends StatefulWidget {
  const DailyQuestionsPage({super.key});

  @override
  State<DailyQuestionsPage> createState() => _DailyQuestionsPageState();
}

class _DailyQuestionsPageState extends State<DailyQuestionsPage> {
  static const String _lastCompletedKey = 'daily_questions_last_completed_date';
  static const String _dailyQuestionsDateKey = 'daily_questions_selected_date';
  static const String _dailyQuestionsListKey = 'daily_questions_selected_list';
  static const String _questionsAssetPath = 'assets/data/daily_questions.json';

  final Map<int, String> _selectedAnswers = <int, String>{};
  List<_DailyQuestion> _questions = const <_DailyQuestion>[];
  bool _loading = true;
  bool _completedToday = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDailyStatus();
  }

  Future<void> _loadDailyStatus() async {
    final today = _todayStamp();
    final prefs = await SharedPreferences.getInstance();
    final lastCompleted = prefs.getString(_lastCompletedKey);
    final selectedDate = prefs.getString(_dailyQuestionsDateKey);
    final savedQuestions = prefs.getStringList(_dailyQuestionsListKey);

    final bank = await _loadQuestionBank();
    List<_DailyQuestion> todaysQuestions;

    if (selectedDate == today &&
        savedQuestions != null &&
        savedQuestions.length == 4) {
      todaysQuestions = savedQuestions
          .map((prompt) => bank.firstWhere(
                (q) => q.prompt == prompt,
                orElse: () => _DailyQuestion.fallback(prompt),
              ))
          .toList();
    } else {
      todaysQuestions = _pickFourQuestions(bank);
      await prefs.setString(_dailyQuestionsDateKey, today);
      await prefs.setStringList(
        _dailyQuestionsListKey,
        todaysQuestions.map((q) => q.prompt).toList(),
      );
      if (lastCompleted != today) {
        await prefs.remove(_lastCompletedKey);
      }
    }

    if (!mounted) return;
    setState(() {
      _questions = todaysQuestions;
      _completedToday = (lastCompleted == today);
      _loading = false;
    });
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

  List<_DailyQuestion> _pickFourQuestions(List<_DailyQuestion> bank) {
    final pool = List<_DailyQuestion>.from(bank);
    pool.shuffle(Random());
    return pool.take(4).toList();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions.')),
      );
      return;
    }
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCompletedKey, _todayStamp());
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
            Positioned.fill(child: buildThemeEffect(settings.themeColor)),
            Positioned(
              top: 12,
              left: 12,
              child: SafeArea(
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back',
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
                  child: _glassPanel(
                    context,
                    child: _loading
                        ? const Padding(
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
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Daily Check-in',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'You gained +2 fertilizers for the garden',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Come back tomorrow for new questions',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 28),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
            child: AppButton(
              label: 'Back',
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionnaireState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Daily Check-in',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A quiet moment for today',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 22),
        for (int i = 0; i < _questions.length; i++) ...[
          _buildQuestionBlock(i, _questions[i]),
          if (i != _questions.length - 1) const SizedBox(height: 20),
        ],
        const SizedBox(height: 28),
        AppButton(
          label: _saving ? 'Saving...' : 'Complete Today',
          onTap: _saving ? null : _completeForToday,
        ),
      ],
    );
  }

  Widget _buildQuestionBlock(int index, _DailyQuestion question) {
    final selected = _selectedAnswers[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.prompt,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 15,
            height: 1.35,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 8,
          runSpacing: 8,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: selected ? 0.24 : 0.12),
          border: Border.all(
            color: Colors.white.withValues(alpha: selected ? 0.6 : 0.28),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: selected ? 0.98 : 0.9),
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
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
  const _DailyQuestion({required this.prompt, required this.options});

  factory _DailyQuestion.fromJson(Map<String, dynamic> json) {
    final prompt = (json['question'] as String?)?.trim() ?? '';
    final optionsRaw = json['options'];
    if (prompt.isEmpty || optionsRaw is! List) return _DailyQuestion.fallback(prompt);
    final options = optionsRaw
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (options.length < 2) return _DailyQuestion.fallback(prompt);
    return _DailyQuestion(prompt: prompt, options: options.take(4).toList());
  }

  factory _DailyQuestion.fallback(String prompt) => _DailyQuestion(
        prompt: prompt.isEmpty ? 'Take a quiet moment.' : prompt,
        options: const ['Not yet', 'Maybe', 'Yes'],
      );

  final String prompt;
  final List<String> options;
}

const List<_DailyQuestion> _fallbackQuestions = <_DailyQuestion>[
  _DailyQuestion(
    prompt: 'How are you feeling right now?',
    options: ['Calm', 'Okay', 'Heavy'],
  ),
  _DailyQuestion(
    prompt: 'What do you need more of today?',
    options: ['Rest', 'Focus', 'Connection'],
  ),
  _DailyQuestion(
    prompt: 'What is one thing on your mind?',
    options: ['Work', 'People', 'Myself'],
  ),
  _DailyQuestion(
    prompt: 'What would help you feel grounded?',
    options: ['Quiet time', 'A short walk', 'A deep breath'],
  ),
];
