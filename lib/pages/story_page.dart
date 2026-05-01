import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/story_progress_service.dart';
import '../utils/story_resume_catalog.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/localized_text.dart';
import 'summary_page.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({
    super.key,
    required this.storyTitle,
    required this.topic,
    this.initialSceneIndex,
    this.resumeStoryId,
  });

  final String storyTitle;
  final String topic;
  final int? initialSceneIndex;
  
  final String? resumeStoryId;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  int calm = 0, anxiety = 0;
  int choicesMade = 0;
  int currentScene = 1;
  bool _startedFromResume = false;
  late final Map<int, Map<String, dynamic>> storyScenes;

  String? _resolvedSceneImagePath(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.contains('/failure_')) {
      return path.replaceAll('/failure_', '/depression_');
    }
    return path;
  }

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

  final Map<int, Map<String, dynamic>> _failureScenes = {
    1: {
      'image': 'assets/images/stories/failure/failure1.png',
      'text':
          "You stare at your screen. The deadline is tomorrow. The cursor blinks, waiting. You’ve started this assignment three times already.",
      'choices': [
        {
          'text': "Open a new tab and start fresh",
          'nextScene': 2,
          'stat': 'calm',
        },
        {
          'text': "Check your phone for a bit",
          'nextScene': 3,
          'stat': 'anxiety',
        },
      ],
    },

    2: {
      'image': 'assets/images/stories/failure/failure2.png',
      'text':
          "You take a breath and type a single sentence. It’s not perfect — but it’s something.",
      'choices': [
        {'text': "Leave it as it is for now", 'nextScene': 4, 'stat': 'calm'},
        {'text': "Try rewriting it again", 'nextScene': 3, 'stat': 'anxiety'},
      ],
    },

    3: {
      'image': 'assets/images/stories/failure/failure3.png',
      'text':
          "Your mind spirals. \"What if I fail? What if everyone else is doing better than me?\" The pressure builds.",
      'choices': [
        {
          'text': "Let the thoughts run for a moment",
          'nextScene': 4,
          'stat': 'anxiety',
        },
        {
          'text': "Shift your focus back to the screen",
          'nextScene': 4,
          'stat': 'calm',
        },
      ],
    },

    4: {
      'image': 'assets/images/stories/failure/failure4.png',
      'text':
          "You remind yourself: this doesn’t have to be perfect. It just has to be done.",
      'choices': [
        {'text': "Continue working like this", 'nextScene': 6, 'stat': 'calm'},
        {
          'text': "Pause and rethink everything",
          'nextScene': 5,
          'stat': 'anxiety',
        },
      ],
    },

    5: {
      'image': 'assets/images/stories/failure/failure5.png',
      'text':
          "Time passes. You feel stuck. The fear of doing it wrong is stopping you from doing anything at all.",
      'choices': [
        {'text': "Do a small part of it", 'nextScene': 6, 'stat': 'calm'},
        {'text': "Leave it for later", 'nextScene': 7, 'stat': 'anxiety'},
      ],
    },

    6: {
      'image': 'assets/images/stories/failure/failure6.png',
      'text':
          "You make progress. Not fast, not perfect — but real. The weight feels slightly lighter.",
      'choices': [
        {'text': "Stay in the flow", 'nextScene': 8, 'stat': 'calm'},
        {
          'text': "Slow down and double-check things",
          'nextScene': 7,
          'stat': 'anxiety',
        },
      ],
    },

    7: {
      'image': 'assets/images/stories/failure/failure7.png',
      'text':
          "You sit back, feeling behind. The fear is still there. But so is the chance to try again.",
      'choices': [
        {'text': "Come back to it gradually", 'nextScene': 8, 'stat': 'calm'},
        {
          'text': "Wait until you feel ready",
          'nextScene': 9,
          'stat': 'anxiety',
        },
      ],
    },

    8: {
      'image': 'assets/images/stories/failure/failure8.png',
      'text':
          "You continue. Slowly, steadily. The work starts to take shape. It’s not perfect — but it’s yours.",
      'choices': [
        {'text': "Leave it here for now", 'nextScene': 10, 'stat': 'calm'},
        {
          'text': "Keep adjusting a few things",
          'nextScene': 9,
          'stat': 'anxiety',
        },
      ],
    },

    9: {
      'image': 'assets/images/stories/failure/failure9.png',
      'text':
          "Doubt lingers. But even now, you’ve done more than you thought you could.",
      'choices': [
        {
          'text': "Acknowledge what you’ve done",
          'nextScene': 10,
          'stat': 'calm',
        },
        {
          'text': "Think about what’s missing",
          'nextScene': 10,
          'stat': 'anxiety',
        },
      ],
    },

    10: {
      'image': 'assets/images/stories/failure/failure10.png',
      'text':
          "You look at what you've done. It’s not perfect. But it’s something real — something you actually made.",
      'choices': [
        {'text': "Sit with it for a moment", 'nextScene': 11, 'stat': 'calm'},
        {
          'text': "Think about how it could’ve been better",
          'nextScene': 11,
          'stat': 'anxiety',
        },
      ],
    },
    11: {
      'image': 'assets/images/stories/failure/failure11.png',
      'text':
          "For a second, the pressure fades. Not completely — but enough. You realize you didn’t avoid it this time.",
      'choices': [
        {'text': "Let that be enough for now", 'nextScene': 12, 'stat': 'calm'},
        {
          'text': "Push yourself a little more",
          'nextScene': 12,
          'stat': 'anxiety',
        },
      ],
    },
    12: {
      'image': 'assets/images/stories/failure/failure12.png',
      'text':
          "Tomorrow will still come. There will still be expectations, deadlines, and doubt. But today, you showed up — even if it didn’t feel like enough.",
      'choices': [
        {'text': "Let the day end", 'nextScene': -1, 'stat': 'calm'},
      ],
    },
  };

  final Map<int, Map<String, dynamic>> _griefScenes = {
    1: {
      'image': 'assets/images/stories/grief/grief1.png',
      'text':
          "You wake up.\n\nFor a second, everything feels normal.\n\nThen it returns. Not a thought.\nNot a memory.\n\nJust a weight.",
      'choices': [
        {'text': "Continue", 'nextScene': 2, 'stat': 'none'},
      ],
    },
    2: {
      'image': 'assets/images/stories/grief/grief2.png',
      'text':
          "You stay in bed.\n\nStaring at the ceiling.\n\nYour phone is nearby. You don't reach for it.\n\nYou already know what it says.\n\n\"I'm so sorry for your loss.\"",
      'choices': [
        {'text': "Continue", 'nextScene': 3, 'stat': 'none'},
      ],
    },
    3: {
      'image': 'assets/images/stories/grief/grief3.png',
      'text':
          "You step into the hallway.\n\nEverything looks the same.\nBut it feels… empty.\n\nHis door is ahead. Slightly open.",
      'choices': [
        {'text': "Walk past it", 'nextScene': 4, 'stat': 'anxiety'},
        {'text': "Stop for a moment", 'nextScene': 5, 'stat': 'calm'},
      ],
    },
    4: {
      'image': 'assets/images/stories/grief/grief4a.png',
      'text':
          "You walk past the door.\n\nYou don't look at it.\n\nBut you feel it behind you.\n\nLike something you're avoiding.",
      'choices': [
        {'text': "Continue", 'nextScene': 6, 'stat': 'none'},
      ],
    },
    5: {
      'image': 'assets/images/stories/grief/grief4b.png',
      'text':
          "You stop in front of the door.\n\nIt's still slightly open.\n\nLike it's waiting.\n\nYour hand almost moves.",
      'choices': [
        {'text': "Continue", 'nextScene': 6, 'stat': 'none'},
      ],
    },
    6: {
      'image': 'assets/images/stories/grief/grief5.png',
      'text':
          "You stand there.\n\nCloser now.\n\nCloser than you were yesterday.\n\nThe silence feels heavier here.",
      'choices': [
        {'text': "Push the door open", 'nextScene': 7, 'stat': 'calm'},
        {'text': "Step back", 'nextScene': 8, 'stat': 'anxiety'},
      ],
    },
    7: {
      'image': 'assets/images/stories/grief/grief6a.png',
      'text':
          "You push the door open.\n\nNothing changed.\n\nEverything is still there.\n\nExactly how he left it.",
      'choices': [
        {'text': "Continue", 'nextScene': 9, 'stat': 'none'},
      ],
    },
    8: {
      'image': 'assets/images/stories/grief/grief6b.png',
      'text':
          "You step back.\n\nIt feels like too much.\n\nLike something will break if you go in.\n\nSo you don't.",
      'choices': [
        {'text': "Continue", 'nextScene': 9, 'stat': 'none'},
      ],
    },
    9: {
      'image': 'assets/images/stories/grief/grief7.png',
      'text':
          "You move away.\n\nBut not far.\n\nThe house feels different now.\n\nLike it noticed.",
      'choices': [
        {'text': "Continue", 'nextScene': 10, 'stat': 'none'},
      ],
    },
    10: {
      'image': 'assets/images/stories/grief/grief8.png',
      'text':
          "Your phone buzzes again.\n\nYou look at it this time.\n\nMore messages.\n\nMore words you don't want.",
      'choices': [
        {'text': "Open them", 'nextScene': 11, 'stat': 'calm'},
        {'text': "Lock your phone", 'nextScene': 12, 'stat': 'anxiety'},
      ],
    },
    11: {
      'image': 'assets/images/stories/grief/grief9a.png',
      'text':
          "You read one message.\n\nThen another.\n\nThey all say the same thing.\n\nBut somehow… it helps a little.",
      'choices': [
        {'text': "Continue", 'nextScene': 13, 'stat': 'none'},
      ],
    },
    12: {
      'image': 'assets/images/stories/grief/grief9b.png',
      'text':
          "You lock your phone.\n\nYou don't want to read them.\n\nNot now.\n\nNot like this.",
      'choices': [
        {'text': "Continue", 'nextScene': 13, 'stat': 'none'},
      ],
    },
    13: {
      'image': 'assets/images/stories/grief/grief10.png',
      'text':
          "You find yourself back in the hallway.\n\nYou didn't plan to come back.\n\nBut you did.\n\nLike something pulled you here.",
      'choices': [
        {'text': "Continue", 'nextScene': 14, 'stat': 'none'},
      ],
    },
    14: {
      'image': 'assets/images/stories/grief/grief11.png',
      'text':
          "The door is still open.\n\nExactly how you left it.\n\nNothing changed.\n\nExcept you.",
      'choices': [
        {'text': "Go inside", 'nextScene': 15, 'stat': 'calm'},
        {'text': "Walk away", 'nextScene': 16, 'stat': 'anxiety'},
      ],
    },
    15: {
      'image': 'assets/images/stories/grief/grief12a.png',
      'text':
          "You step inside.\n\nAnd this time… you stay.\n\nIt hurts more than before.\n\nBut you don't leave.",
      'choices': [
        {'text': "Continue", 'nextScene': 17, 'stat': 'none'},
      ],
    },
    16: {
      'image': 'assets/images/stories/grief/grief12b.png',
      'text':
          "You turn away again.\n\nFaster this time.\n\nLike something might follow you.\n\nBut it doesn't.",
      'choices': [
        {'text': "Continue", 'nextScene': 17, 'stat': 'none'},
      ],
    },
    17: {
      'image': 'assets/images/stories/grief/grief13.png',
      'text':
          "You stop.\n\nSomewhere between rooms.\n\nBetween staying and leaving.\n\nYou don't know which one is easier.",
      'choices': [
        {'text': "Go back", 'nextScene': 18, 'stat': 'calm'},
        {'text': "Keep moving", 'nextScene': 19, 'stat': 'anxiety'},
      ],
    },
    18: {
      'image': 'assets/images/stories/grief/grief14a.png',
      'text':
          "You go back.\n\nYou don't rush it this time.\n\nYou just stand there.\n\nAnd for a moment… you don't fight it.",
      'choices': [
        {'text': "Continue", 'nextScene': -1, 'stat': 'none'},
      ],
    },
    19: {
      'image': 'assets/images/stories/grief/grief14b.png',
      'text':
          "You keep moving.\n\nRoom to room.\n\nWithout stopping.\n\nLike standing still might make it real.",
      'choices': [
        {'text': "Continue", 'nextScene': -1, 'stat': 'none'},
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

  final Map<int, Map<String, dynamic>> _anxietyScenes = {
    1: {
      'image': 'assets/images/stories/anxiety/anxiety1.png',
      'text':
          "You're mid-conversation.\n\nEveryone's talking at once.\n\nYou say something small.\n\nIt lands… and then moves on.",
      'choices': [
        {'text': "Continue", 'nextScene': 2, 'stat': 'none'},
      ],
    },
    2: {
      'image': 'assets/images/stories/anxiety/anxiety2.png',
      'text':
          "No one reacts.\n\nWhich should be normal.\n\nBut your mind holds onto it.\n\nReplays it anyway.",
      'choices': [
        {'text': "Continue", 'nextScene': 3, 'stat': 'none'},
      ],
    },
    3: {
      'image': 'assets/images/stories/anxiety/anxiety3.png',
      'text':
          "\"That sounded off.\"\n\nYou weren’t thinking that a second ago.\n\nNow it feels obvious.\n\nLike you missed it in real time.",
      'choices': [
        {'text': "Go over it", 'nextScene': 4, 'stat': 'anxiety'},
        {'text': "Stay in the moment", 'nextScene': 5, 'stat': 'calm'},
      ],
    },
    4: {
      'image': 'assets/images/stories/anxiety/anxiety4.png',
      'text':
          "You replay the tone.\n\nThen the wording.\n\nThen their faces.\n\nIt keeps changing.",
      'choices': [
        {'text': "Continue", 'nextScene': 6, 'stat': 'none'},
      ],
    },
    5: {
      'image': 'assets/images/stories/anxiety/anxiety5.png',
      'text':
          "You nod along.\n\nTry to listen again.\n\nIt’s harder now.\n\nYou’re split in two.",
      'choices': [
        {'text': "Continue", 'nextScene': 6, 'stat': 'none'},
      ],
    },
    6: {
      'image': 'assets/images/stories/anxiety/anxiety6.png',
      'text':
          "They’re still talking.\n\nYou’re still there.\n\nBut not fully.\n\nSomething pulled you inward.",
      'choices': [
        {'text': "Continue", 'nextScene': 7, 'stat': 'none'},
      ],
    },
    7: {
      'image': 'assets/images/stories/anxiety/anxiety7.png',
      'text':
          "You adjust how you're sitting.\n\nThen your hands.\n\nThen your face.\n\nIt starts feeling unnatural.",
      'choices': [
        {'text': "Continue", 'nextScene': 8, 'stat': 'none'},
      ],
    },
    8: {
      'image': 'assets/images/stories/anxiety/anxiety8.png',
      'text':
          "Someone laughs.\n\nYou smile a second late.\n\nIt feels noticeable.\n\nEven if it isn’t.",
      'choices': [
        {'text': "Stay longer", 'nextScene': 9, 'stat': 'calm'},
        {'text': "Leave early", 'nextScene': 10, 'stat': 'anxiety'},
      ],
    },
    9: {
      'image': 'assets/images/stories/anxiety/anxiety9.png',
      'text':
          "You stay.\n\nIt gets slightly louder inside.\n\nHarder to follow what’s real.\n\nAnd what you’re adding.",
      'choices': [
        {'text': "Continue", 'nextScene': 11, 'stat': 'none'},
      ],
    },
    10: {
      'image': 'assets/images/stories/anxiety/anxiety10.png',
      'text':
          "You make an excuse.\n\nIt sounds normal enough.\n\nBut you keep replaying it.\n\nOn the way out.",
      'choices': [
        {'text': "Continue", 'nextScene': 11, 'stat': 'none'},
      ],
    },
    11: {
      'image': 'assets/images/stories/anxiety/anxiety11.png',
      'text':
          "You’re alone now.\n\nIt should feel easier.\n\nIt doesn’t.\n\nIt just gets quieter around you.",
      'choices': [
        {'text': "Continue", 'nextScene': 12, 'stat': 'none'},
      ],
    },
    12: {
      'image': 'assets/images/stories/anxiety/anxiety12.png',
      'text':
          "Without the noise,\nit gets clearer.\n\nEvery small moment from before\nstarts lining up.",
      'choices': [
        {'text': "Continue", 'nextScene': 13, 'stat': 'none'},
      ],
    },
    13: {
      'image': 'assets/images/stories/anxiety/anxiety13.png',
      'text':
          "You keep walking.\n\nNot really going anywhere.\n\nJust… not stopping.\n\nLike stopping might catch up to you.",
      'choices': [
        {'text': "Continue", 'nextScene': 14, 'stat': 'none'},
      ],
    },
    14: {
      'image': 'assets/images/stories/anxiety/anxiety14.png',
      'text':
          "You reach for your phone.\n\nUnlock it.\n\nDon’t open anything.\n\nLock it again.",
      'choices': [
        {'text': "Check something", 'nextScene': 15, 'stat': 'anxiety'},
        {'text': "Put it away", 'nextScene': 16, 'stat': 'calm'},
      ],
    },
    15: {
      'image': 'assets/images/stories/anxiety/anxiety15.png',
      'text':
          "You open a chat.\n\nScroll up.\n\nLooking for a moment that felt wrong.\n\nYou find one.",
      'choices': [
        {'text': "Continue", 'nextScene': 17, 'stat': 'none'},
      ],
    },
    16: {
      'image': 'assets/images/stories/anxiety/anxiety16.png',
      'text':
          "You keep it in your pocket.\n\nBut your mind fills the gap.\n\nReconstructing things anyway.\n\nWorse than before.",
      'choices': [
        {'text': "Continue", 'nextScene': 17, 'stat': 'none'},
      ],
    },
    17: {
      'image': 'assets/images/stories/anxiety/anxiety17.png',
      'text':
          "You’re home now.\n\nThe day is quieter.\n\nBut your head isn’t.\n\nIt’s more focused now.",
      'choices': [
        {'text': "Continue", 'nextScene': 18, 'stat': 'none'},
      ],
    },
    18: {
      'image': 'assets/images/stories/anxiety/anxiety18.png',
      'text':
          "You notice your breathing.\n\nThen your heartbeat.\n\nIt feels slightly off.\n\nNow it’s all you can feel.",
      'choices': [
        {'text': "Continue", 'nextScene': 19, 'stat': 'none'},
      ],
    },
    19: {
      'image': 'assets/images/stories/anxiety/anxiety19.png',
      'text':
          "You lie down.\n\nIt gets louder in the dark.\n\nEvery thought feels unfinished.\n\nLike something needs fixing.",
      'choices': [
        {'text': "Try to sleep", 'nextScene': 20, 'stat': 'calm'},
        {'text': "Stay awake", 'nextScene': 21, 'stat': 'anxiety'},
      ],
    },
    20: {
      'image': 'assets/images/stories/anxiety/anxiety20.png',
      'text':
          "You close your eyes.\n\nYour body slows down.\n\nYour mind doesn’t.\n\nIt keeps going without you.",
      'choices': [
        {'text': "Continue", 'nextScene': -1, 'stat': 'none'},
      ],
    },
    21: {
      'image': 'assets/images/stories/anxiety/anxiety21.png',
      'text':
          "You stay up.\n\nSwitching between thoughts and nothing.\n\nTime passes without moving.\n\nMorning doesn’t feel far.",
      'choices': [
        {'text': "Continue", 'nextScene': -1, 'stat': 'none'},
      ],
    },
  };

  final StoryProgressService _progressService = StoryProgressService();

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
      case 'Failure':
        storyScenes = _failureScenes;
        break;
      case 'Anxiety':
        storyScenes = _anxietyScenes;
        break;
      default:
        storyScenes = _griefScenes;
    }
    _restoreProgress();
  }

  Future<void> _restoreProgress() async {
    final data = await _progressService.load();
    if (!mounted) return;

    final sid = (widget.resumeStoryId != null &&
            widget.resumeStoryId!.trim().isNotEmpty)
        ? widget.resumeStoryId!.trim()
        : (StoryResumeCatalog.storyIdFromStoryTitleAndTopic(
              storyTitle: widget.storyTitle,
              topic: widget.topic,
            ) ??
            StoryResumeCatalog.storyIdFromNormalizedTopic(widget.topic));

    final topicMatches =
        data.currentTopic?.toLowerCase() == widget.topic.toLowerCase();

    final initialScene = widget.initialSceneIndex;
    final fromMap =
        (sid != null && sid.isNotEmpty) ? data.inProgressStories[sid] : null;
    int? sceneToUse = initialScene;
    if (sceneToUse == null &&
        fromMap != null &&
        fromMap > 0 &&
        storyScenes.containsKey(fromMap)) {
      sceneToUse = fromMap;
    }
    if (sceneToUse == null &&
        topicMatches &&
        data.currentScene != null &&
        storyScenes.containsKey(data.currentScene)) {
      sceneToUse = data.currentScene;
    }

    if (sceneToUse != null && storyScenes.containsKey(sceneToUse)) {
      _startedFromResume = sceneToUse > 1;
      setState(() {
        currentScene = sceneToUse!;
        if (topicMatches) {
          calm = data.currentCalm;
          anxiety = data.currentAnxiety;
          choicesMade = data.currentChoicesMade;
        }
      });
      await _progressService.recordProgress(
        storyTitle: widget.storyTitle,
        topic: widget.topic,
        currentScene: currentScene,
        calm: calm,
        anxiety: anxiety,
        currentChoicesMade: choicesMade,
        resumeStoryId: sid,
      );
      return;
    }

    await _progressService.recordProgress(
      storyTitle: widget.storyTitle,
      topic: widget.topic,
      currentScene: currentScene,
      calm: calm,
      anxiety: anxiety,
      currentChoicesMade: choicesMade,
      resumeStoryId: sid,
    );
    _startedFromResume = false;
  }

  Future<void> _goToSummary() async {
    final total = calm + anxiety;
    final score = total == 0 ? 0 : ((calm / total) * 100).round();
    final String mood = (calm >= anxiety)
        ? (calm == anxiety ? "Balanced" : "Calm")
        : "Anxious";
    final String emotion = "Calm $calm • Anxiety $anxiety";

    final newlyUnlocked = await _progressService.markStoryCompleted(
      storyTitle: widget.storyTitle,
      topic: widget.topic,
      choicesMadeInStory: choicesMade,
      calm: calm,
      anxiety: anxiety,
      resumeStoryId: widget.resumeStoryId,
      resumedFromSavedProgress: _startedFromResume,
    );

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
            anxietyCount: anxiety,
            newlyUnlockedAchievements: newlyUnlocked,
            resumeStoryId: widget.resumeStoryId,
            griefStayedEnding:
                widget.topic == 'Grief' ? (calm >= anxiety) : null,
          ),
        ),
      );
    });
  }

  void _chooseOption(String stat, int nextScene) {
    setState(() {
      if (stat == 'calm') {
        calm++;
        choicesMade++;
      } else if (stat == 'anxiety') {
        anxiety++;
        choicesMade++;
      }
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

    _progressService.recordProgress(
      storyTitle: widget.storyTitle,
      topic: widget.topic,
      currentScene: currentScene,
      calm: calm,
      anxiety: anxiety,
      currentChoicesMade: choicesMade,
      resumeStoryId: widget.resumeStoryId,
    );

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
    required Widget label,
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
              child: label,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = storyScenes[currentScene]!;
    final String? imagePath = _resolvedSceneImagePath(
      scene['image'] as String?,
    );
    final bool hasImage = imagePath != null && imagePath.isNotEmpty;

    return GradientScaffold(
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
                    LocalizedText(
                      scene['text'] as String,
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
                      final rawStat = choice['stat'];
                      final statStr =
                          rawStat is String ? rawStat : 'none';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: _glassChoiceButton(
                          label: LocalizedText(
                            choice['text'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () => _chooseOption(
                            statStr,
                            choice['nextScene'] as int,
                          ),
                        ),
                      );
                    }),

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
  const _EmojiMoodBar({required this.emoji, required this.alignment});

  final Alignment alignment;
  final String emoji;

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

