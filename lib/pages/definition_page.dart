import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../widgets/localized_text.dart';
import '../widgets/app_button.dart';
import '../widgets/gradient_scaffold.dart';
import 'story_page.dart';

class DefinitionPage extends StatefulWidget {
  final String storyTitle;
  final String topic;
  final String resumeStoryId;

  const DefinitionPage({
    super.key,
    required this.storyTitle,
    required this.topic,
    required this.resumeStoryId,
  });

  @override
  State<DefinitionPage> createState() => _DefinitionPageState();
}

class _DefinitionPageState extends State<DefinitionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _Def def = _defs[widget.topic] ?? _defs.values.first;

    return GradientScaffold(
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _glassPanel(
                            radius: 26,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LocalizedText(
                                  def.title,
                                  style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                LocalizedText(
                                  def.shortDescription,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.5,
                                    height: 1.45,
                                    color: Colors.white.withOpacity(0.78),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: def.tags.map(_chip).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          _glassPanel(
                            radius: 26,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LocalizedText(
                                  "What it can feel like",
                                  style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.92),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...def.symptoms.map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "•  ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white.withOpacity(
                                              0.85,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: LocalizedText(
                                            s,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              height: 1.35,
                                              color: Colors.white.withOpacity(
                                                0.78,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Center(
                              child: SizedBox(
                                width: 200,
                                child: AppButton(
                                  label: t(context, 'start_story'),
                                  height: 52,
                                  borderRadius: BorderRadius.circular(26),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StoryPage(
                                          storyTitle: widget.storyTitle,
                                          topic: widget.topic,
                                          resumeStoryId: widget.resumeStoryId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          LocalizedText(
                            t(context, 'take_your_time_stop_anytime'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassPanel({
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
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: LocalizedText(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Def {
  final String title;
  final String shortDescription;
  final List<String> symptoms;
  final List<String> tags;

  const _Def({
    required this.title,
    required this.shortDescription,
    required this.symptoms,
    required this.tags,
  });
}

const Map<String, _Def> _defs = {
  'Grief': _Def(
    title: 'Grief 🕊️',
    shortDescription:
        "Grief is the emotional response to losing someone deeply important to you. "
        "It can feel heavy, confusing, quiet, or overwhelming — sometimes all at once. "
        "There is no right way to grieve, and no timeline to follow. "
        "Grief is not a sign of weakness; it is a reflection of love that continues.",
    symptoms: [
      "Waves of sadness, numbness, or longing",
      "Feeling disconnected or unusually tired",
      "Thinking often about memories or unfinished conversations",
    ],
    tags: ["Gentle", "Reflective", "No timeline"],
  ),

  'Depression': _Def(
    title: 'Depression 🌧️',
    shortDescription:
        "Depression can feel like a quiet weight that slows everything down — thoughts, energy, and even simple tasks. "
        "It doesn’t mean you’re weak; it means you’re carrying more than most people can see. "
        "Progress often comes in small steps, and that still counts.",
    symptoms: [
      "Low mood, numbness, or emptiness most days",
      "Low energy, changes in sleep or appetite",
      "Loss of interest in things you once enjoyed",
    ],
    tags: ["Low energy", "Small steps", "Support"],
  ),

  'Loneliness': _Def(
    title: 'Loneliness 🧠',
    shortDescription:
        "Loneliness is the feeling of disconnection — even when you’re surrounded by people. "
        "It’s not about being alone; it’s about feeling unseen or unheard. "
        "Moments of warmth, honesty, and connection can slowly bring closeness back.",
    symptoms: [
      "Feeling isolated or emotionally distant",
      "Withdrawing from social situations",
      "Longing for meaningful connection",
    ],
    tags: ["Connection", "Warmth", "Reach out"],
  ),
  'Failure': _Def(
    title: 'Fear of Failure ⏳',
    shortDescription:
        "Fear of failure is the pressure that builds when you feel like your effort has to be perfect to be worth something. "
        "It can make starting feel harder than continuing, and finishing feel like it’s never enough. "
        "This fear doesn’t mean you’re incapable — it means you care about what you’re doing.",
    symptoms: [
      "Overthinking before starting or finishing tasks",
      "Avoiding work because it feels overwhelming",
      "Feeling like what you do is never enough",
    ],
    tags: ["Pressure", "Overthinking", "Self-doubt"],
  ),
  'Anxiety': _Def(
    title: 'Too Loud Inside 🧠',
    shortDescription:
        "Some days feel normal on the outside.\n\n"
        "Nothing goes wrong.\n"
        "Nothing unusual happens.\n\n"
        "But inside, your thoughts don't stop.\n\n"
        "They repeat.\n"
        "They question.\n"
        "They grow louder for no clear reason.\n\n"
        "This story is about a day like that.\n\n"
        "Take your time.",
    symptoms: [
      "Racing thoughts that are hard to slow down",
      "Replaying conversations and second-guessing yourself",
      "Physical tension, shallow breathing, or restlessness",
    ],
    tags: ["Anxiety", "Overthinking", "Grounding"],
  ),
};
