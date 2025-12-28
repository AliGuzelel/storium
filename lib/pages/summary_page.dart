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
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _kv('Mood', mood),
                    _kv('Emotion', emotion),
                    _kv('Score', '$score%'),
                  ],
                ),

                const SizedBox(height: 16),
                Text(face, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 16),

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
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _autoSummary(String mood, int score, String topic) {
    if (mood == 'Calm') {
      return topic == 'Anxiety'
          ? "You grounded yourself and softened the echoes. Calm led your choices, and the room felt safer."
          : "You made steady, gentle choices. Calm guided the path forward.";
    } else if (mood == 'Anxious') {
      return topic == 'Anxiety'
          ? "Anxiety steered many choices; the echoes grew louder. Still, awareness is progress — you can choose differently next time."
          : "The day felt heavy and reactive. Small, kind steps could shift tomorrow.";
    } else {
      return "You balanced both caution and composure. With a few calmer steps, the ending may feel even lighter.";
    }
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
