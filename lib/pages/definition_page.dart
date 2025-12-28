import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';
import 'story_page.dart';

class DefinitionPage extends StatelessWidget {
  final String storyTitle;
  final String topic;
  const DefinitionPage({
    super.key,
    required this.storyTitle,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color headerColor = isDark ? Colors.white : const Color(0xFF2F1654);
    final Color bodyColor = isDark
        ? Colors.white.withOpacity(0.92)
        : const Color(0xFF2F1654);

    const double lh = 1.6;
    final TextStyle h1 = TextStyle(
      fontFamily: 'Cinzel',
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: headerColor,
    );
    final TextStyle h2 = TextStyle(
      fontFamily: 'Cinzel',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: headerColor,
    );
    final TextStyle body = TextStyle(
      fontFamily: 'Cinzel',
      fontSize: 16,
      height: lh,
      color: bodyColor,
    );

    final _Def def = _defs[topic] ?? _defs.values.first;

    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Definition',
          style: TextStyle(fontFamily: 'Cinzel', fontSize: 26),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(def.title, style: h1),
            const SizedBox(height: 12),
            Text(def.shortDescription, style: body),
            const SizedBox(height: 30),
            Text("Common Symptoms", style: h2),
            const SizedBox(height: 12),
            ...def.symptoms.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•  ', style: body.copyWith(fontSize: 18)),
                    Expanded(child: Text(s, style: body)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: SizedBox(
                  width: 240,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF451B80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StoryPage(storyTitle: storyTitle, topic: topic),
                        ),
                      );
                    },
                    child: const Text(
                      "Start Story",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Def {
  final String title;
  final String shortDescription;
  final List<String> symptoms;
  const _Def({
    required this.title,
    required this.shortDescription,
    required this.symptoms,
  });
}

const Map<String, _Def> _defs = {
  'Anxiety': _Def(
    title: 'Anxiety 😮‍💨',
    shortDescription:
        "Anxiety is a feeling of unease or tension that can come with racing thoughts and a restless body. "
        "It’s your mind’s way of staying alert — but sometimes it stays on too long. "
        "With calm choices and patience, you can teach it to rest again.",
    symptoms: [
      "Racing thoughts and difficulty focusing",
      "Fast heartbeat or shortness of breath",
      "Avoiding stressful situations",
    ],
  ),
  'Depression': _Def(
    title: 'Depression 🌧️',
    shortDescription:
        "Depression feels like a quiet weight that makes everything slower. "
        "It can dull joy and motivation, but small steps — movement, sunlight, connection — slowly lift the fog. "
        "Healing takes time, and that’s okay.",
    symptoms: [
      "Low mood or fatigue most of the day",
      "Loss of interest or pleasure",
      "Feelings of hopelessness or guilt",
    ],
  ),
  'Loneliness': _Def(
    title: 'Loneliness 🫥',
    shortDescription:
        "Loneliness is the space between you and the world — even when surrounded by people. "
        "It often comes from disconnection, not distance. "
        "Tiny acts of reaching out can rebuild warmth and belonging.",
    symptoms: [
      "Feeling isolated or unseen",
      "Emotional emptiness or sadness",
      "Desire for meaningful connection",
    ],
  ),
};
