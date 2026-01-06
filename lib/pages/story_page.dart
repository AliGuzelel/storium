import 'dart:ui';
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
      case 'Grief':
        storyScenes = _griefScenes;
        break;
      case 'Depression':
      case 'Loneliness':
        storyScenes = _depressionScenes;
        break;
      default:
        storyScenes = _griefScenes;
    }
  }

  // ===================== GRIEF =====================

  final Map<int, Map<String, dynamic>> _griefScenes = {
    1: {
      'image': 'assets/images/stories/grief_1.png',
      'text':
          "The house is quiet in a way it never was before. Your father’s shoes are still by the door. For a moment, you expect to hear his voice.",
      'choices': [
        {'text': "Stand there and breathe", 'nextScene': 2, 'stat': 'calm'},
        {'text': "Turn away quickly", 'nextScene': 3, 'stat': 'anxiety'},
      ],
    },
    2: {
      'image': 'assets/images/stories/grief_2.png',
      'text':
          "You stay still. Your chest feels tight, but the air slowly finds its way in. The silence hurts — yet it also feels honest.",
      'choices': [
        {'text': "Distract yourself", 'nextScene': 3, 'stat': 'anxiety'},
        {'text': "Let the feeling come", 'nextScene': 4, 'stat': 'calm'},
      ],
    },
    3: {
      'image': 'assets/images/stories/grief_3.png',
      'text':
          "You move to another room. Your phone lights up, but no message feels right. Everything feels slightly unreal, like you’re watching yourself.",
      'choices': [
        {'text': "Sit down", 'nextScene': 4, 'stat': 'calm'},
        {'text': "Keep moving", 'nextScene': 5, 'stat': 'anxiety'},
      ],
    },
    4: {
      'image': 'assets/images/stories/grief_4.png',
      'text':
          "You sit. A memory surfaces — something small. A look, a laugh, advice he once gave you. It catches you off guard.",
      'choices': [
        {'text': "Push it away", 'nextScene': 5, 'stat': 'anxiety'},
        {'text': "Hold onto the memory", 'nextScene': 6, 'stat': 'calm'},
      ],
    },
    5: {
      'image': 'assets/images/stories/grief_5.png',
      'text':
          "Your thoughts race. There’s guilt, anger, questions with no answers. You wonder if you should feel stronger by now.",
      'choices': [
        {
          'text': "Remind yourself grief has no rules",
          'nextScene': 6,
          'stat': 'calm',
        },
        {
          'text': "Judge yourself for struggling",
          'nextScene': 7,
          'stat': 'anxiety',
        },
      ],
    },
    6: {
      'image': 'assets/images/stories/grief_6.png',
      'text':
          "You realize something quietly: missing him means the love is still here. That part never left.",
      'choices': [
        {'text': "Accept the feeling", 'nextScene': 8, 'stat': 'calm'},
        {'text': "Stay in the moment", 'nextScene': 7, 'stat': 'anxiety'},
      ],
    },
    7: {
      'image': 'assets/images/stories/grief_7.png',
      'text':
          "The weight feels heavy, but not unbearable. You don’t need to solve anything today. Just being here is enough.",
      'choices': [
        {'text': "Let the day pass quietly", 'nextScene': 9, 'stat': 'anxiety'},
        {'text': "Take a slow breath", 'nextScene': 8, 'stat': 'calm'},
      ],
    },
    8: {
      'image': 'assets/images/stories/grief_8.png',
      'text':
          "You feel tired, but a little steadier. Grief doesn’t disappear — it changes shape. And so do you.",
      'choices': [
        {
          'text': "Let the day carry you forward",
          'nextScene': 10,
          'stat': 'calm',
        },
        {
          'text': "Sit quietly with the feeling",
          'nextScene': 10,
          'stat': 'calm',
        },
      ],
    },
    9: {
      'image': 'assets/images/stories/grief_9.png',
      'text':
          "You get through the day. Not perfectly. But honestly. The weight is still there — just not as sharp.",
      'choices': [
        {
          'text': "Acknowledge what you survived today",
          'nextScene': 10,
          'stat': 'calm',
        },
        {'text': "Rest without expectations", 'nextScene': 10, 'stat': 'calm'},
      ],
    },
    10: {
      'image': 'assets/images/stories/grief_10.png',
      'text':
          "Tonight, you are allowed to rest. Grief will walk beside you — but it does not erase who you are becoming.",
      'choices': [
        {'text': "Let the day end", 'nextScene': -1, 'stat': 'calm'},
      ],
    },
  };

  // ===================== DEPRESSION / LONELINESS =====================

  final Map<int, Map<String, dynamic>> _depressionScenes = {
    1: {
      'image': 'assets/images/stories/depression_1.jpg',
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
      'image': 'assets/images/stories/depression_2.jpg',
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
      'image': 'assets/images/stories/depression_3.jpg',
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
      'image': 'assets/images/stories/depression_4.jpg',
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
      'image': 'assets/images/stories/depression_5.jpg',
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
      'image': 'assets/images/stories/depression_6.jpg',
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
      'image': 'assets/images/stories/depression_7.jpg',
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
      'image': 'assets/images/stories/depression_8.jpg',
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
      'image': 'assets/images/stories/depression_9.jpg',
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
      'image': 'assets/images/stories/depression_10.jpg',
      'text':
          "Night settles. Today wasn’t perfect. But it wasn’t nothing. Small steps counted — the kind that add up.",
      'choices': [
        {'text': "Let the day end", 'nextScene': -1, 'stat': 'calm'},
      ],
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
    });

    if (nextScene == -1) {
      _goToSummary();
      return;
    }

    if (!storyScenes.containsKey(nextScene)) {
      _goToSummary();
      return;
    }

    setState(() {
      currentScene = nextScene;
    });

    final next = storyScenes[nextScene];
    if (next != null && (next['choices'] as List).isEmpty) {
      _goToSummary();
    }
  }

  double get _moodValue {
    final total = calm + anxiety;
    if (total == 0) return 0.0;
    return ((calm - anxiety) / total).clamp(-1.0, 1.0);
  }

  Alignment get _moodAlignment => Alignment(_moodValue, 0);

  String get _moodEmoji {
    if (_moodValue > 0.2) return "🙂";
    if (_moodValue < -0.2) return "🙁";
    return "😐";
  }

  Widget _glass({
    required Widget child,
    double radius = 22,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
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

  Widget _glassChoiceButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.10),
            highlightColor: Colors.white.withOpacity(0.06),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = storyScenes[currentScene]!;
    final String? imagePath = scene['image'] as String?;
    final bool hasImage = imagePath != null && imagePath.isNotEmpty;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          widget.storyTitle,
          style: const TextStyle(fontFamily: 'Cinzel'),
        ),
        backgroundColor: Colors.white.withOpacity(0.04),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top image
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                if (hasImage)
                  Positioned.fill(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          alignment: Alignment.center,
                          color: Colors.black12,
                          child: const Text(
                            'Image not found',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        );
                      },
                    ),
                  )
                else
                  const SizedBox.expand(),

                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.10)),
                ),
              ],
            ),
          ),

          // Bottom content
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: _glass(
                radius: 26,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Text(
                      scene['text'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 18,
                        height: 1.6,
                        color:
                            Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),

                    ...(scene['choices'] as List).map<Widget>((choice) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: _glassChoiceButton(
                          label: choice['text'],
                          onTap: () => _chooseOption(
                            choice['stat'],
                            choice['nextScene'],
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 14),

                    _EmojiMoodBar(emoji: _moodEmoji, alignment: _moodAlignment),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiMoodBar extends StatelessWidget {
  final String emoji;
  final Alignment alignment;

  const _EmojiMoodBar({required this.emoji, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 10,
              color: Colors.white.withOpacity(0.22),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 2,
                      height: 10,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    alignment: alignment,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        width: 18,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
