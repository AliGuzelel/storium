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
        storyScenes = _depressionScenes;
        break;
      case 'Loneliness':
        storyScenes = _lonelinessScenes;
        break;
      default:
        storyScenes = _griefScenes;
    }
  }

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

  final Map<int, Map<String, dynamic>> _depressionScenes = {
    1: {
      'image': 'assets/images/stories/depression_1.png',
      'text':
          "Your alarm buzzes. You check your phone. At the top of your notifications is a message from Alex.\n\n\"You okay?\"\n\nSeeing their name still hits you in the chest.",
      'choices': [
        {
          'text': "Open the message, then close it without replying",
          'nextScene': 2,
          'stat': 'anxiety',
        },
        {
          'text': "Put the phone face-down and sit up",
          'nextScene': 2,
          'stat': 'calm',
        },
      ],
    },

    2: {
      'image': 'assets/images/stories/depression_2.png',
      'text':
          "You sit on the edge of the bed. Their old hoodie is still hanging over your chair — a reminder you never quite dealt with.",
      'choices': [
        {
          'text': "Fold the hoodie and put it away",
          'nextScene': 3,
          'stat': 'calm',
        },
        {
          'text': "Hold it for a while and let the memories flood in",
          'nextScene': 3,
          'stat': 'anxiety',
        },
      ],
    },

    3: {
      'image': 'assets/images/stories/depression_3.png',
      'text':
          "Your phone buzzes again.\n\n\"Not trying to push. Just checking. — Alex\"\n\nYour throat tightens. Part of you wants to answer. Part of you doesn’t want to feel anything at all.",
      'choices': [
        {
          'text': "Text back \"I'm fine\" even though you’re not",
          'nextScene': 4,
          'stat': 'anxiety',
        },
        {
          'text': "Don’t reply. Take one slow breath instead",
          'nextScene': 4,
          'stat': 'calm',
        },
      ],
    },

    4: {
      'image': 'assets/images/stories/depression_4.png',
      'text':
          "You head to the kitchen for water. On the fridge, there’s still a photo of you and Alex — hair messy, sun in your eyes, both of you laughing.\n\nThe memory hits harder than you expect.",
      'choices': [
        {
          'text': "Take the photo down gently and put it away",
          'nextScene': 5,
          'stat': 'calm',
        },
        {
          'text': "Keep staring at it until your chest tightens",
          'nextScene': 5,
          'stat': 'anxiety',
        },
      ],
    },

    5: {
      'image': 'assets/images/stories/depression_5.png',
      'text':
          "Back on the bed, your thoughts start to spiral.\n\nWhat went wrong. What you should’ve said. Why they’re checking on you now. Why everything feels heavier than it should.",
      'choices': [
        {
          'text':
              "Stand up, plant your feet on the floor, and take a full, deliberate breath",
          'nextScene': 6,
          'stat': 'calm',
        },
        {
          'text': "Replay the breakup in your head until it hurts",
          'nextScene': 6,
          'stat': 'anxiety',
        },
      ],
    },

    6: {
      'image': 'assets/images/stories/depression_6.png',
      'text':
          "You open the window. Cold air rushes in, brushing against your skin. For a moment, it helps.\n\nThen you notice a couple walking below, laughing about something only they understand.",
      'choices': [
        {
          'text': "Focus on the cold air and slow your breathing",
          'nextScene': 7,
          'stat': 'calm',
        },
        {
          'text': "Shut the window quickly and pull the curtains closed",
          'nextScene': 7,
          'stat': 'anxiety',
        },
      ],
    },

    7: {
      'image': 'assets/images/stories/depression_7.png',
      'text':
          "Your phone starts to ring.\n\nAlex is calling.\n\nYour stomach twists. You weren’t ready for this.",
      'choices': [
        {
          'text': "Answer the call with a quiet \"hey\"",
          'nextScene': 8,
          'stat': 'anxiety',
        },
        {
          'text': "Let it ring out and watch the screen until it stops",
          'nextScene': 9,
          'stat': 'anxiety',
        },
      ],
    },

    8: {
      'image': 'assets/images/stories/depression_8.png',
      'text':
          "Their voice is softer than you remembered.\n\n\"Hey… I just wanted to hear your voice,\" they say. No accusations. Just concern.\n\nIt hurts in a familiar way.",
      'choices': [
        {
          'text': "Tell them it’s been hard lately",
          'nextScene': 10,
          'stat': 'calm',
        },
        {
          'text': "Say \"I’m okay\" even though your voice shakes",
          'nextScene': 10,
          'stat': 'anxiety',
        },
      ],
    },

    9: {
      'image': 'assets/images/stories/depression_9.png',
      'text':
          "The call ends. A voicemail appears a moment later.\n\n\"I won’t push. Just… please don’t disappear,\" Alex says.\n\nHearing their voice without answering aches in your chest.",
      'choices': [
        {
          'text': "Sit with the feeling and take a slow breath",
          'nextScene': 11,
          'stat': 'calm',
        },
        {
          'text': "Open your old chat and reread the arguments",
          'nextScene': 11,
          'stat': 'anxiety',
        },
      ],
    },

    10: {
      'image': 'assets/images/stories/depression_10.png',
      'text':
          "You talk for a little while. Nothing big, just small pieces of life.\n\nAlex admits, \"I’m not calling to reopen everything. I just… still worry about you.\"",
      'choices': [
        {
          'text': "Tell them you appreciate that they still care",
          'nextScene': 12,
          'stat': 'calm',
        },
        {
          'text': "Change the subject because it’s too much",
          'nextScene': 12,
          'stat': 'anxiety',
        },
      ],
    },

    11: {
      'image': 'assets/images/stories/depression_11.png',
      'text':
          "You stay sitting in the quiet room. The voicemail replays in your head.\n\nGuilt mixes with loneliness until you’re not sure which one is heavier.",
      'choices': [
        {
          'text': "Get up, drink some water, and breathe",
          'nextScene': 13,
          'stat': 'calm',
        },
        {
          'text': "Stay frozen on the bed, staring at nothing",
          'nextScene': 13,
          'stat': 'anxiety',
        },
      ],
    },

    12: {
      'image': 'assets/images/stories/depression_12.png',
      'text':
          "The call winds down. Alex's voice is gentle.\n\n\"Try to rest tonight, okay?\" they say.\n\nYou can hear that they mean it.",
      'choices': [
        {
          'text': "Say a quiet \"goodnight\" before hanging up",
          'nextScene': 14,
          'stat': 'calm',
        },
        {
          'text': "Let the silence stretch until they end the call",
          'nextScene': 14,
          'stat': 'anxiety',
        },
      ],
    },

    13: {
      'image': 'assets/images/stories/depression_13.png',
      'text':
          "The room feels heavier than before. Alex doesn’t send anything else.\n\nYou’re alone with the unread messages and the weight in your chest.",
      'choices': [
        {
          'text': "Put your phone away and dim the lights",
          'nextScene': 14,
          'stat': 'calm',
        },
        {
          'text': "Keep staring at the screen until your eyes burn",
          'nextScene': 14,
          'stat': 'anxiety',
        },
      ],
    },

    14: {
      'image': 'assets/images/stories/depression_14.png',
      'text':
          "You lie down, staring at the ceiling. Today wasn’t easy. It wasn’t simple. But you are still here.\n\nBetween the messages, the memories, and the quiet, you made it through another day.",
      'choices': [
        {
          'text': "Let the day end and close your eyes slowly",
          'nextScene': -1,
          'stat': 'calm',
        },
        {
          'text': "Cry quietly until sleep finally pulls you under",
          'nextScene': -1,
          'stat': 'anxiety',
        },
      ],
    },
  };

  final Map<int, Map<String, dynamic>> _lonelinessScenes = {
    1: {
      'image': 'assets/images/stories/loneliness_1.png',
      'text':
          "The city lights flicker against the window. Messages sit on 'seen', group chats move without you. The room feels louder in its silence.",
      'choices': [
        {
          'text': "Put on your shoes and step outside",
          'nextScene': 2,
          'stat': 'calm',
        },
        {
          'text': "Stay in bed and scroll one more time",
          'nextScene': 3,
          'stat': 'overwhelmed',
        },
      ],
    },
    2: {
      'image': 'assets/images/stories/loneliness_2.png',
      'text':
          "Cold air meets your face. Streets glow softly. Cars pass, people walk in pairs and small groups, their laughter trailing behind them.",
      'choices': [
        {
          'text': "Walk with no destination, just moving",
          'nextScene': 4,
          'stat': 'uncertain',
        },
        {'text': "Head toward a familiar café", 'nextScene': 5, 'stat': 'calm'},
      ],
    },
    3: {
      'image': 'assets/images/stories/loneliness_3.png',
      'text':
          "The screen lights your face. Everyone seems surrounded by friends, plans, lives. You feel like you’re pressing your face to the glass from outside.",
      'choices': [
        {
          'text': "Mute notifications and drop the phone beside you",
          'nextScene': 4,
          'stat': 'uncertain',
        },
        {
          'text': "Keep tapping through stories you’re not in",
          'nextScene': 6,
          'stat': 'hurt',
        },
      ],
    },
    4: {
      'image': 'assets/images/stories/loneliness_4.png',
      'text':
          "Your footsteps become a slow rhythm. Buildings, signs, small details you never noticed before appear when you finally look up.",
      'choices': [
        {
          'text': "Observe the details: windows, trees, small lights",
          'nextScene': 7,
          'stat': 'calm',
        },
        {
          'text': "Walk faster to get this over with",
          'nextScene': 6,
          'stat': 'overwhelmed',
        },
      ],
    },
    5: {
      'image': 'assets/images/stories/loneliness_5.png',
      'text':
          "The café door opens with a soft chime. Warm light, low music, the quiet comfort of strangers sharing the same space.",
      'choices': [
        {
          'text': "Order something small and sit by the window",
          'nextScene': 7,
          'stat': 'calm',
        },
        {
          'text': "Take your drink to go and leave quickly",
          'nextScene': 6,
          'stat': 'uncertain',
        },
      ],
    },
    6: {
      'image': 'assets/images/stories/loneliness_6.png',
      'text':
          "You move through the city like a ghost. Present, but not quite belonging to anything around you. A familiar ache settles in your chest.",
      'choices': [
        {
          'text': "Send a simple message: “Hey, are you free?”",
          'nextScene': 8,
          'stat': 'hurt',
        },
        {
          'text': "Decide to just walk until your mind softens",
          'nextScene': 7,
          'stat': 'uncertain',
        },
      ],
    },
    7: {
      'image': 'assets/images/stories/loneliness_7.png',
      'text':
          "You sit. Maybe on a bench, maybe by a window. People pass by, living small pieces of their lives. You’re not part of their stories, but you are still here.",
      'choices': [
        {
          'text': "Breathe slowly and notice you’re not the only one alone",
          'nextScene': 8,
          'stat': 'calm',
        },
        {
          'text': "Tell yourself no one would notice if you disappeared",
          'nextScene': 9,
          'stat': 'hurt',
        },
      ],
    },
    8: {
      'image': 'assets/images/stories/loneliness_8.png',
      'text':
          "Your phone buzzes — a reply, a small heart, a “sorry, I was busy”. Not everything is fixed, but the emptiness feels less sharp.",
      'choices': [
        {
          'text': "Walk home slowly, letting the night hold you gently",
          'nextScene': 10,
          'stat': 'calm',
        },
        {
          'text': "Head home quickly, unsure how you feel",
          'nextScene': 10,
          'stat': 'uncertain',
        },
      ],
    },
    9: {
      'image': 'assets/images/stories/loneliness_9.png',
      'text':
          "The thought lingers: maybe you’re easy to forget. It hurts more than you want to admit. You hold that pain quietly, like a fragile glass.",
      'choices': [
        {
          'text': "Acknowledge the pain instead of arguing with it",
          'nextScene': 8,
          'stat': 'hurt',
        },
        {
          'text': "Shut everything down and go straight home",
          'nextScene': 10,
          'stat': 'overwhelmed',
        },
      ],
    },
    10: {
      'image': 'assets/images/stories/loneliness_10.png',
      'text':
          "Back in your room, the same four walls greet you. But you’re not quite the same as when you left. The streets were quiet, but they reminded you: you do exist here.",
      'choices': [
        {'text': "Let the night end", 'nextScene': -1, 'stat': 'calm'},
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
