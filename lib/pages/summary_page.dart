import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';
import 'story_page.dart';

class SummaryPage extends StatelessWidget {
  final String title;
  final String topic;
  final String mood;
  final String emotion;
  final int score;

  const SummaryPage({
    super.key,
    required this.title,
    required this.topic,
    required this.mood,
    required this.emotion,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final face = score >= 66 ? '😊' : (score >= 40 ? '😐' : '😟');

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Summary', style: TextStyle(fontFamily: 'Cinzel')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'The End',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  _autoSummary(mood, score, topic),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.white.withOpacity(0.92),
                  ),
                ),
                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Mood', mood),

                    Column(
                      children: [
                        const Text(
                          'Emotion',
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          face,
                          style: const TextStyle(
                            fontSize: 52, // bigger emoji
                          ),
                        ),
                      ],
                    ),

                    _kv('Score', '$score%'),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _replay(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF451B80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Replay Story',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => _saveAndQuit(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Save & Quit',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "ℹ️  ",
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    Flexible(
                      child: Text(
                        "Storium reflects fictional emotional patterns and is not a diagnostic tool.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _kv(String k, String v) => Column(
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
  );

  void _replay(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StoryPage(storyTitle: title, topic: topic),
      ),
    );
  }

  void _saveAndQuit(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
