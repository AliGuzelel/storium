import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../services/story_progress_service.dart';
import '../theme/ui_tokens.dart';
import '../utils/app_strings.dart';
import '../utils/story_resume_catalog.dart';
import '../widgets/app_button.dart';
import '../widgets/app_glass.dart';
import '../widgets/achievement_popup.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/localized_text.dart';
import 'story_page.dart';

class SummaryPage extends StatefulWidget {
  final String title;
  final String topic;
  final String mood;
  final String emotion;
  final int score;

  
  final int anxietyCount;
  final List<AchievementModel> newlyUnlockedAchievements;
  final String? resumeStoryId;

  
  final bool? griefStayedEnding;

  const SummaryPage({
    super.key,
    required this.title,
    required this.topic,
    required this.mood,
    required this.emotion,
    required this.score,
    this.anxietyCount = 0,
    this.newlyUnlockedAchievements = const [],
    this.resumeStoryId,
    this.griefStayedEnding,
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showAchievementsSequence(context, widget.newlyUnlockedAchievements);
    });
  }

  @override
  Widget build(BuildContext context) {
    final face = widget.score >= 66 ? '😊' : (widget.score >= 40 ? '😐' : '😟');
    final barValue = widget.anxietyCount == 0
        ? 1.0
        : (widget.score / 100).clamp(0.0, 1.0);
    final moodMessage = _moodMessageForScore(widget.score);

    return GradientScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const maxCardWidth = 520.0;
            final pad = UiTokens.pagePadding * 2;
            final cardWidth = (constraints.maxWidth - pad)
                .clamp(0.0, maxCardWidth)
                .toDouble();
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(UiTokens.pagePadding),
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: cardWidth,
                  child: AppGlass(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
                    radius: 26,
                    showBorder: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          t(context, 'the_end'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            face,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 108),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LocalizedText(
                          moodMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                        const SizedBox(height: 18),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 12,
                            width: double.infinity,
                            color: Colors.white.withOpacity(0.18),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOutCubic,
                                    width: constraints.maxWidth * barValue,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF8ED5A7),
                                          Color(0xFF5C9BF5),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (widget.topic == 'Grief' &&
                            widget.griefStayedEnding != null) ...[
                          const SizedBox(height: 18),
                          LocalizedText(
                            widget.griefStayedEnding!
                                ? "You didn't run from it.\n\nYou stayed.\n\nEven when it felt heavy,\neven when it hurt more than expected.\n\nThat doesn't make it easier.\nBut it makes it real.\n\nGrief isn't something you fix.\n\nSometimes, it's something you learn\nto sit with.\n\nAnd today, you did."
                                : "You kept moving.\n\nYou didn't stop long enough to face it.\n\nAnd maybe that's all you could do today.\n\nGrief doesn't follow rules.\n\nIt doesn't wait until you're ready.\n\nAvoiding it doesn't mean you're weak.\n\nIt just means… it still feels like too much.\n\nAnd that's okay.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              height: 1.65,
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (!(widget.topic == 'Grief' &&
                            widget.griefStayedEnding != null)) ...[
                          LocalizedText(
                            _autoSummary(
                              widget.mood,
                              widget.score,
                              widget.topic,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              height: 1.65,
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _kvColumn(t(context, 'mood'), widget.mood)),
                            Expanded(
                              child: _kvColumn(t(context, 'emotion'), widget.emotion),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: t(context, 'replay_story'),
                                onTap: () => _replay(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppButton(
                                label: t(context, 'save_quit'),
                                onTap: () => _saveAndQuit(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LocalizedText(
                          "Storium reflects fictional emotional patterns and is not a diagnostic tool.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.72),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _moodMessageForScore(int score) {
    if (score >= 66) return "You handled this with patience.";
    if (score >= 40) return "You were figuring things out - that's okay.";
    return "This path carried a lot. You didn't avoid it.";
  }

  String _autoSummary(String mood, int score, String topic) {
    String topicLine;

    switch (topic) {
      case 'Grief':
        topicLine =
            "You moved through a day shaped by loss, memories, and moments that will never feel simple. This story wasn’t about ‘getting over’ anything — it was about making it through.";
        break;
      case 'Depression':
        topicLine =
            "You walked through a day touched by something that ended, and the heaviness it left behind. Some thoughts pulled you down, but you still stayed with the story.";
        break;
      case 'Loneliness':
        topicLine =
            "You moved through a world full of people and still felt apart from it. From streets to screens to your room, you carried a quiet ache most others never see.";
        break;
      default:
        topicLine =
            "You stayed with some difficult feelings instead of running away from them. That alone already says a lot about you.";
    }

    const closingLine =
        "However this story turned out, reaching the end means you stayed with your feelings for a little while. That’s a brave thing to do — and you deserve gentleness after it.";

    return "$topicLine\n\n$closingLine";
  }

  Widget _kvColumn(String k, String v) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      LocalizedText(
        k,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 13,
          color: Colors.white70,
        ),
      ),
      const SizedBox(height: 4),
      LocalizedText(
        v,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    ],
  );

  Future<void> _replay(BuildContext context) async {
    final service = StoryProgressService();
    final sid =
        widget.resumeStoryId ??
        StoryResumeCatalog.storyIdFromStoryTitleAndTopic(
          storyTitle: widget.title,
          topic: widget.topic,
        );
    if (sid != null) {
      await service.discardStoryProgress(
        resumeStoryId: sid,
        storyTitle: widget.title,
        topic: widget.topic,
      );
    }
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StoryPage(
          storyTitle: widget.title,
          topic: widget.topic,
          resumeStoryId: widget.resumeStoryId ?? sid,
        ),
      ),
    );
  }

  void _saveAndQuit(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
