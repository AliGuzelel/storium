import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';

class AboutMentalHealthPage extends StatelessWidget {
  const AboutMentalHealthPage({super.key});

  Widget _glassCard(BuildContext context, Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
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

  Widget _bullets(TextStyle body, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: body.copyWith(fontSize: 18)),
                  Expanded(child: Text(t, style: body)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double lh = 1.55;

    final TextStyle h1 = TextStyle(
      fontFamily: 'Cinzel',
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: Colors.white.withOpacity(0.95),
    );

    final TextStyle h2 = TextStyle(
      fontFamily: 'Cinzel',
      fontSize: 19,
      fontWeight: FontWeight.w700,
      color: Colors.white.withOpacity(0.92),
    );

    final TextStyle body = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14.5,
      height: lh,
      color: Colors.white.withOpacity(0.78),
    );

    final TextStyle small = body.copyWith(
      fontSize: 13,
      color: Colors.white.withOpacity(0.70),
    );

    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'About Mental Health',
          style: TextStyle(fontFamily: 'Cinzel'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.04),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _glassCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What is Mental Health?', style: h1),
                    const SizedBox(height: 8),
                    Text(
                      "Mental health is how we think, feel, and act — it shapes how we handle stress, relate to others, and make choices. "
                      "It isn’t only the absence of illness; it’s the presence of balance, resilience, and meaning in everyday life. 💜",
                      style: body,
                    ),
                    const SizedBox(height: 12),
                    _bullets(body, [
                      "It changes over time — and that’s okay. 🌖",
                      "Everyone struggles sometimes; you’re not alone. 🤝",
                      "Small steps can make a big difference. 🍃",
                    ]),
                  ],
                ),
              ),

              _glassCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Why It Matters', style: h1),
                    const SizedBox(height: 8),
                    _bullets(body, [
                      "Better focus and decision-making 🧠",
                      "Healthier relationships and communication 🫶",
                      "More energy and motivation ⚡",
                      "Greater resilience when life gets heavy 🛡️",
                    ]),
                  ],
                ),
              ),

              _glassCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Common Challenges (In Our Stories)', style: h1),
                    const SizedBox(height: 10),

                    Text('Grief 🕊️', style: h2),
                    const SizedBox(height: 6),
                    _bullets(body, [
                      "Waves of sadness, numbness, or longing",
                      "Feeling disconnected or unusually tired",
                      "Thinking often about memories or unfinished conversations",
                    ]),
                    const SizedBox(height: 10),

                    Text('Depression 🌧️', style: h2),
                    const SizedBox(height: 6),
                    _bullets(body, [
                      "Low mood or numbness most of the day",
                      "Loss of interest in things you used to enjoy",
                      "Changes in sleep or appetite; low energy",
                    ]),
                    const SizedBox(height: 10),

                    Text('Loneliness 🫥', style: h2),
                    const SizedBox(height: 6),
                    _bullets(body, [
                      "Feeling disconnected — even around people",
                      "Withdrawing from friends or routines",
                      "Longing to be seen, heard, or understood",
                    ]),
                    const SizedBox(height: 10),
                    Text(
                      "Storium isn’t a medical tool — it’s a gentle, interactive space to notice patterns, feelings, and choices.",
                      style: small,
                    ),
                  ],
                ),
              ),

              _glassCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How Storium Helps 🎮', style: h1),
                    const SizedBox(height: 8),
                    _bullets(body, [
                      "Play through everyday scenarios in a safe space",
                      "Reflect on choices — notice what soothes vs. what spikes stress",
                      "Build small skills: breathing, reframing, reaching out",
                      "Finish with a warm summary — no judgment, just insight",
                    ]),
                  ],
                ),
              ),

              _glassCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gentle Skills You Can Try 🌿', style: h1),
                    const SizedBox(height: 8),
                    _bullets(body, [
                      "🫁 4-7-8 Breathing: inhale 4, hold 7, exhale 8 — repeat x4",
                      "📝 Label It: “I’m feeling a lot right now.” Naming helps",
                      "🔁 Reframe: “I failed” → “I learned something I can use”",
                      "📅 Micro-steps: 10-minute walk, 1 page read, 1 message to a friend",
                      "🤗 Reach Out: share with someone you trust",
                    ]),
                  ],
                ),
              ),

              _glassCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🆘 When To Seek Extra Support', style: h1),
                    const SizedBox(height: 8),
                    Text(
                      "If intense feelings last for weeks, disrupt daily life, or you feel unsafe, consider professional help. "
                      "Speaking with a counselor, therapist, or doctor can be a brave next step.",
                      style: body,
                    ),
                    const SizedBox(height: 10),
                    _bullets(body, [
                      "Emergency: contact your local emergency number 🚑",
                      "Helplines / talk lines in your region ☎️",
                      "Campus or community counseling services 🧾",
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      "Storium doesn’t diagnose or treat conditions. It’s a supportive companion — not a substitute for care.",
                      style: small.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              _glassCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Space, Your Pace 🔒', style: h1),
                    const SizedBox(height: 8),
                    Text(
                      "Your experience is yours. We keep things simple and respectful — and you always choose what to do next.",
                      style: body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
