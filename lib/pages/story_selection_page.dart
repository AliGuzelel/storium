import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../models/story_progress.dart';
import '../services/story_progress_service.dart';
import '../widgets/gradient_scaffold.dart';
import 'definition_page.dart';

class StorySelectionPage extends StatefulWidget {
  const StorySelectionPage({super.key});

  @override
  State<StorySelectionPage> createState() => _StorySelectionPageState();
}

class _StorySelectionPageState extends State<StorySelectionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  StoryProgressData _progressData = const StoryProgressData();
  final StoryProgressService _progressService = StoryProgressService();
  late final Animation<Offset> _slide;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final data = await _progressService.load();
    if (!mounted) return;
    setState(() {
      _progressData = data;
    });
  }

  bool _isStoryCompleted(String storyTitle, String topic) {
    final finished = _progressData.finishedStories.map((e) => e.toLowerCase()).toSet();
    final byTitle = storyTitle.toLowerCase();
    final byTopic = topic.toLowerCase();
    return finished.contains(byTitle) || finished.contains(byTopic);
  }

  Widget _glassPanel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    double radius = 24,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _storyCard(
    BuildContext context, {
    required String title,
    required String topic,
    required String emoji,
    required String desc,
    required List<String> chips,
    required bool isCompleted,
  }) {
    return _glassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 26,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        splashColor: Colors.white.withOpacity(0.08),
        highlightColor: Colors.white.withOpacity(0.05),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DefinitionPage(storyTitle: title, topic: topic),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.white.withOpacity(0.24)
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? Colors.white.withOpacity(0.34)
                      : Colors.white.withOpacity(0.18),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  if (isCompleted)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6DDA8A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      height: 1.25,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chips.map((c) => _chip(c)).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.75),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.5,
          color: Colors.white.withOpacity(0.85),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(t(context, 'choose_story'),
            style: const TextStyle(fontFamily: 'Cinzel')),
        backgroundColor: Colors.white.withOpacity(0.04),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      _glassPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            Text(
                              t(context, 'pick_feeling'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 20,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t(context, 'pick_story_mood'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                height: 1.35,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      _storyCard(
                        context,
                        title: t(context, 'the_day_after'),
                        topic: 'Grief',
                        emoji: '🕊️',
                        desc: 'A quiet story about loss and love.',
                        chips: const ['Reflective', 'Gentle'],
                        isCompleted: _isStoryCompleted('The Day After', 'Grief'),
                      ),
                      const SizedBox(height: 14),

                      _storyCard(
                        context,
                        title: t(context, 'what_still_remains'),
                        topic: 'Depression',
                        emoji: '🌙',
                        desc: 'Between messages, memories, and the quiet ache.',
                        chips: const ['Emotional', 'Heavy'],
                        isCompleted: _isStoryCompleted(
                          'What Still Remains',
                          'Depression',
                        ),
                      ),
                      const SizedBox(height: 14),

                      _storyCard(
                        context,
                        title: t(context, 'alone_again'),
                        topic: 'Loneliness',
                        emoji: '🌫️',
                        desc: 'A quiet ache you carry through the night.',
                        chips: const ['Soft', 'Dark'],
                        isCompleted: _isStoryCompleted('Alone, Again', 'Loneliness'),
                      ),
                      const SizedBox(height: 14),

                      _storyCard(
                        context,
                        title: t(context, 'almost_there'),
                        topic: 'Failure',
                        emoji: '⏳',
                        desc: 'The quiet pressure of trying to be enough.',
                        chips: const ['Stress', 'Realistic'],
                        isCompleted: _isStoryCompleted('Almost There', 'Failure'),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
