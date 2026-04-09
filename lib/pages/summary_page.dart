import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../theme/ui_tokens.dart';
import '../utils/app_strings.dart';
import '../widgets/app_button.dart';
import '../widgets/app_glass.dart';
import '../widgets/achievement_popup.dart';
import '../widgets/gradient_scaffold.dart';
import 'story_page.dart';

class SummaryPage extends StatefulWidget {
  final String title;
  final String topic;
  final String mood;
  final String emotion;
  final int score;
  final List<AchievementModel> newlyUnlockedAchievements;

  const SummaryPage({
    super.key,
    required this.title,
    required this.topic,
    required this.mood,
    required this.emotion,
    required this.score,
    this.newlyUnlockedAchievements = const [],
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
    final barValue = (widget.score / 100).clamp(0.0, 1.0);
    final moodMessage = _moodMessageForScore(widget.score);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(t(context, 'summary'),
            style: const TextStyle(fontFamily: 'Cinzel')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.pagePadding),
          child: AppGlass(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
            radius: 26,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t(context, 'the_end'),
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(face, style: const TextStyle(fontSize: 78)),
                const SizedBox(height: 12),
                Text(
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
                    color: Colors.white.withOpacity(0.18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        width:
                            MediaQuery.sizeOf(context).width * 0.7 * barValue,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8ED5A7), Color(0xFF5C9BF5)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                Text(
                  _autoSummary(widget.mood, widget.score, widget.topic),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.65,
                    color: Colors.white.withOpacity(0.92),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Mood', widget.mood),
                    _kv('Emotion', widget.emotion),
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
                Text(
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

  Widget _kv(String k, String v) => Expanded(
    child: Column(
      children: [
        Text(
          k,
          style: const TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          v,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );

  void _replay(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StoryPage(storyTitle: widget.title, topic: widget.topic),
      ),
    );
  }

  void _saveAndQuit(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
