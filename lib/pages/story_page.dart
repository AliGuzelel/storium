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
          "You walk home slower than usual tonight. Your phone is in your hand, but there’s nothing new.\nThe street looks ordinary, but you feel strangely out of place in it.",
      'choices': [
        {
          'text': "Put your phone away and keep walking",
          'nextScene': 2,
          'stat': 'calm',
        },
        {
          'text': "Check your notifications again anyway",
          'nextScene': 3,
          'stat': 'anxiety',
        },
      ],
    },

    2: {
      'image': 'assets/images/stories/loneliness_2.png',
      'text':
          "You slip your phone into your pocket. For a few steps, it feels like a small act of control.\nWithout the screen, you notice the sounds more clearly — cars in the distance, a door closing, someone laughing far away.",
      'choices': [
        {
          'text': "Focus on your footsteps and breathing",
          'nextScene': 4,
          'stat': 'calm',
        },
        {
          'text': "Reach for your phone again without thinking",
          'nextScene': 3,
          'stat': 'anxiety',
        },
      ],
    },

    3: {
      'image': 'assets/images/stories/loneliness_3.png',
      'text':
          "Your screen lights up with the group chat.\nThey’re making plans for tomorrow — memes, voice notes, inside jokes. No one asks if you’re coming. It’s like the conversation knows how to move without you.",
      'choices': [
        {
          'text': "Type something, then erase it before sending",
          'nextScene': 5,
          'stat': 'anxiety',
        },
        {
          'text': "Mute the chat and lock your phone",
          'nextScene': 4,
          'stat': 'calm',
        },
      ],
    },

    4: {
      'image': 'assets/images/stories/loneliness_4.png',
      'text':
          "You keep walking. The city feels like background noise.\nYou watch a couple pass you, talking quietly. A group of friends cross the street together, sharing a joke you can’t hear.\nYou feel like a ghost moving through someone else’s evening.",
      'choices': [
        {
          'text': "Slow your pace and just observe",
          'nextScene': 6,
          'stat': 'calm',
        },
        {
          'text': "Walk faster like you’re trying to catch up to something",
          'nextScene': 5,
          'stat': 'anxiety',
        },
      ],
    },

    5: {
      'image': 'assets/images/stories/loneliness_5.png',
      'text':
          "You open another app out of habit — social media this time.\nStories flash by: dinner tables, crowded rooms, people pressed together in group photos.\nYou spot a place you recognize, with people you know. No one told you they were going.",
      'choices': [
        {
          'text': "Keep watching their stories in silence",
          'nextScene': 6,
          'stat': 'anxiety',
        },
        {
          'text': "Exit the app before you reach the end",
          'nextScene': 6,
          'stat': 'calm',
        },
      ],
    },

    6: {
      'image': 'assets/images/stories/loneliness_6.png',
      'text':
          "You tuck your phone away again. The screen goes dark, but the feeling it left behind doesn’t.\nA thought appears quietly: when did you start becoming someone people forgot to invite?",
      'choices': [
        {
          'text': "Tell yourself people are just busy",
          'nextScene': 7,
          'stat': 'calm',
        },
        {
          'text': "Blame yourself for drifting away",
          'nextScene': 7,
          'stat': 'anxiety',
        },
      ],
    },

    7: {
      'image': 'assets/images/stories/loneliness_7.png',
      'text':
          "You scroll through your recent calls.\nYour mom’s name sits near the top — a missed call from days ago. You remember seeing it and thinking, \"I’ll call her when I feel better.\"\nThat moment never came.",
      'choices': [
        {
          'text': "Think seriously about calling her tonight",
          'nextScene': 8,
          'stat': 'calm',
        },
        {
          'text': "Swipe away from the call log and look at nothing",
          'nextScene': 8,
          'stat': 'anxiety',
        },
      ],
    },

    8: {
      'image': 'assets/images/stories/loneliness_8.png',
      'text':
          "You turn onto your street. Apartment windows glow above you.\nSome show silhouettes moving around, others just the flicker of a TV. Behind each window, there’s a life happening.\nYours feels like it’s paused on the loading screen.",
      'choices': [
        {
          'text': "Walk slowly and let your thoughts drift",
          'nextScene': 9,
          'stat': 'calm',
        },
        {
          'text': "Keep your eyes on the ground and head to the door",
          'nextScene': 10,
          'stat': 'anxiety',
        },
      ],
    },

    9: {
      'image': 'assets/images/stories/loneliness_9.png',
      'text':
          "You stop for a moment near the entrance.\nYou look up at the windows and wonder how many people up there feel just as disconnected — scrolling, overthinking, convincing themselves nobody would understand.",
      'choices': [
        {
          'text': "Let yourself feel a little less alone in that thought",
          'nextScene': 10,
          'stat': 'calm',
        },
        {
          'text': "Shake the thought off and go inside",
          'nextScene': 10,
          'stat': 'anxiety',
        },
      ],
    },

    10: {
      'image': 'assets/images/stories/loneliness_10.png',
      'text':
          "In the elevator, your reflection stares back at you in the metal doors.\n\nYou look like yourself, but more drained around the eyes. You realize you don’t remember the last time you felt fully present with someone.",
      'choices': [
        {
          'text': "Hold your gaze and admit you’re not okay",
          'nextScene': 11,
          'stat': 'anxiety',
        },
        {
          'text': "Look away and focus on the floor numbers changing",
          'nextScene': 11,
          'stat': 'calm',
        },
      ],
    },

    11: {
      'image': 'assets/images/stories/loneliness_11.png',
      'text':
          "Your room greets you with the same familiar quiet.\nYou drop your things and sit on the edge of the bed. The day feels like it happened around you, not with you.\nYour phone rests beside you, face up, waiting for a notification that doesn’t come.",
      'choices': [
        {
          'text': "Open your gallery and look at old photos",
          'nextScene': 12,
          'stat': 'anxiety',
        },
        {
          'text': "Stay still and just stare at the floor",
          'nextScene': 12,
          'stat': 'calm',
        },
      ],
    },

    12: {
      'image': 'assets/images/stories/loneliness_12.png',
      'text':
          "You lie back.\nWhether you looked at old pictures or just the ceiling, the same quiet weight settles in your chest — made of half-finished messages, almost-calls, and plans that didn’t have your name on them.",
      'choices': [
        {
          'text': "Breathe slowly and let the feeling move through you",
          'nextScene': 13,
          'stat': 'calm',
        },
        {
          'text': "Curl up on your side and stay very still",
          'nextScene': 13,
          'stat': 'anxiety',
        },
      ],
    },

    13: {
      'image': 'assets/images/stories/loneliness_13.png',
      'text':
          "You’re still alone tonight.\nThe loneliness didn’t disappear, but you carried it from the street to your room and survived another day with it.\nFor now, that has to be enough — and quietly, it is.",
      'choices': [
        {'text': "End the night quietly", 'nextScene': -1, 'stat': 'calm'},
        {
          'text': "Stay awake a little longer with your thoughts",
          'nextScene': -1,
          'stat': 'anxiety',
        },
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
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        height: 1.55,
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
