import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';
import 'summary_page.dart';

class StoryPage extends StatefulWidget {
  final String storyTitle;
  final String topic;
  const StoryPage({super.key, required this.storyTitle, required this.topic});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  int calm = 0, anxiety = 0;
  int currentScene = 1;

  late final Map<int, Map<String, dynamic>> storyScenes;

  @override
  void initState() {
    super.initState();
    switch (widget.topic) {
      case 'Anxiety':
        storyScenes = _anxietyScenes;
        break;
      case 'Depression':
      case 'Loneliness':
        storyScenes = _depressionScenes;
        break;
      default:
        storyScenes = _anxietyScenes;
    }
  }

  final Map<int, Map<String, dynamic>> _anxietyScenes = {
    1: {
      'text':
          "You wake up in a silent white room. The sound of your breath echoes back.",
      'choices': [
        {'text': "Stay calm and breathe", 'nextScene': 2, 'stat': 'calm'},
        {'text': "Run toward the wall", 'nextScene': 3, 'stat': 'anxiety'},
      ],
    },
    2: {
      'text': "You slow your breathing. A soft voice whispers your name.",
      'choices': [
        {'text': "Answer the voice", 'nextScene': 4, 'stat': 'calm'},
        {'text': "Stay silent", 'nextScene': 5, 'stat': 'anxiety'},
      ],
    },
    3: {
      'text': "You hit the wall; it ripples like water. The echoes multiply.",
      'choices': [
        {'text': "Shout for help", 'nextScene': 5, 'stat': 'anxiety'},
        {'text': "Close your eyes", 'nextScene': 4, 'stat': 'calm'},
      ],
    },
    4: {
      'text': "A calm reflection appears. “You don’t have to be afraid.”",
      'choices': [
        {'text': "Trust the voice", 'nextScene': 6, 'stat': 'calm'},
        {'text': "Doubt it", 'nextScene': 5, 'stat': 'anxiety'},
      ],
    },
    5: {
      'text': "The noise swirls like a storm. You feel lost in thought.",
      'choices': [
        {'text': "Scream back", 'nextScene': 7, 'stat': 'anxiety'},
        {'text': "Cover your ears", 'nextScene': 6, 'stat': 'anxiety'},
      ],
    },
    6: {
      'text': "Silence. The mirror cracks, but it no longer scares you.",
      'choices': [
        {'text': "Accept yourself", 'nextScene': 8, 'stat': 'calm'},
        {'text': "Walk away", 'nextScene': 7, 'stat': 'anxiety'},
      ],
    },
    7: {
      'text': "Everything blurs. You can still choose how this ends.",
      'choices': [
        {'text': "Breathe and let go", 'nextScene': 8, 'stat': 'calm'},
        {'text': "Stay silent", 'nextScene': 9, 'stat': 'anxiety'},
      ],
    },
    8: {'text': "Light fills the room. The voices fade.", 'choices': []},
    9: {'text': "You wake up again. The cycle begins anew.", 'choices': []},
  };

  final Map<int, Map<String, dynamic>> _depressionScenes = {
    1: {
      'text':
          "Morning light leaks through the curtains. Your body feels heavy, like the day is already asking too much.",
      'choices': [
        {
          'text': "Sit up and place feet on the floor",
          'nextScene': 2,
          'stat': 'calm',
        },
        {
          'text': "Stay under the covers a little longer",
          'nextScene': 3,
          'stat': 'anxiety',
        },
      ],
    },
    2: {
      'text':
          "You sit up. The room is quiet. A glass of water on the nightstand reminds you to start small.",
      'choices': [
        {'text': "Drink the water slowly", 'nextScene': 4, 'stat': 'calm'},
        {
          'text': "Ignore it and stare at your phone",
          'nextScene': 5,
          'stat': 'anxiety',
        },
      ],
    },
    3: {
      'text':
          "You turn your face to the pillow. “Not today,” your mind says — but the world waits outside.",
      'choices': [
        {
          'text': "Take one deep breath and sit up",
          'nextScene': 4,
          'stat': 'calm',
        },
        {
          'text': "Scroll aimlessly a bit more",
          'nextScene': 5,
          'stat': 'anxiety',
        },
      ],
    },
    4: {
      'text':
          "You drink. Cool water softens your throat. The sky looks pale and quiet.",
      'choices': [
        {
          'text': "Open the window for fresh air",
          'nextScene': 6,
          'stat': 'calm',
        },
        {'text': "Close the curtains again", 'nextScene': 5, 'stat': 'anxiety'},
      ],
    },
    5: {
      'text':
          "Minutes pass. The feed keeps moving, but you don’t. The room grows smaller when you do nothing.",
      'choices': [
        {
          'text': "Wash your face — two minutes",
          'nextScene': 6,
          'stat': 'calm',
        },
        {
          'text': "Lie back down and mute notifications",
          'nextScene': 7,
          'stat': 'anxiety',
        },
      ],
    },
    6: {
      'text':
          "Cold water meets skin. It’s not joy, but it’s movement — a quiet kind of progress.",
      'choices': [
        {
          'text': "Step out for a 5-minute walk",
          'nextScene': 8,
          'stat': 'calm',
        },
        {
          'text': "Sit on the bed and do nothing",
          'nextScene': 7,
          'stat': 'anxiety',
        },
      ],
    },
    7: {
      'text':
          "You pause. Silence presses in. A softer voice asks for a tiny step.",
      'choices': [
        {
          'text': "Message a friend: “Hey, how are you?”",
          'nextScene': 8,
          'stat': 'calm',
        },
        {
          'text': "Turn on a show to drown thoughts",
          'nextScene': 9,
          'stat': 'anxiety',
        },
      ],
    },
    8: {
      'text':
          "Fresh air or a small connection — something shifts. The day feels less sharp.",
      'choices': [
        {'text': "Make a simple meal or snack", 'nextScene': 9, 'stat': 'calm'},
        {
          'text': "Go back inside and lie down",
          'nextScene': 7,
          'stat': 'anxiety',
        },
      ],
    },
    9: {
      'text':
          "Energy is limited, but you moved. Evening approaches. How do you want it to end?",
      'choices': [
        {
          'text': "Prepare for sleep: water, journal, lights low",
          'nextScene': 10,
          'stat': 'calm',
        },
        {
          'text': "Stay up late and keep scrolling",
          'nextScene': 10,
          'stat': 'anxiety',
        },
      ],
    },
    10: {
      'text':
          "Night settles. Today wasn’t perfect. But it wasn’t nothing. Small steps counted — the kind that add up.",
      'choices': [],
    },
  };

  void _goToSummary() {
    final total = calm + anxiety;
    final score = total == 0 ? 0 : ((calm / total) * 100).round();
    final String mood = (calm == anxiety)
        ? "Neutral"
        : (calm > anxiety ? "Calm" : "Anxious");
    final String emotion = "Calm $calm • Anxiety $anxiety";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SummaryPage(
            title: widget.storyTitle,
            topic: widget.topic,
            mood: mood,
            emotion: emotion,
            score: score,
          ),
        ),
      );
    });
  }

  void _chooseOption(String stat, int nextScene) {
    setState(() {
      if (stat == 'calm') calm++;
      if (stat == 'anxiety') anxiety++;
      currentScene = nextScene;
    });
    final next = storyScenes[nextScene]!;
    if ((next['choices'] as List).isEmpty) _goToSummary();
  }

  @override
  Widget build(BuildContext context) {
    final scene = storyScenes[currentScene]!;
    if ((scene['choices'] as List).isEmpty) _goToSummary();

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          widget.storyTitle,
          style: const TextStyle(fontFamily: 'Cinzel'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              scene['text'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                height: 1.6,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 18),
            ...(scene['choices'] as List).map<Widget>((choice) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () =>
                        _chooseOption(choice['stat'], choice['nextScene']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF451B80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      choice['text'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
