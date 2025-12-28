import 'package:flutter/material.dart';

class AboutMentalHealthPage extends StatelessWidget {
  const AboutMentalHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const double lh = 1.6;
    final Color bodyColor = isDark
        ? Colors.white.withOpacity(0.92)
        : const Color(0xFF2F1654);
    final Color headerColor = isDark ? Colors.white : const Color(0xFF2F1654);

    TextStyle h1 = TextStyle(
      fontFamily: 'Cinzel',
      fontSize: 26,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
      color: headerColor,
    );
    TextStyle h2 = TextStyle(
      fontFamily: 'Cinzel',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: headerColor,
    );
    TextStyle body = TextStyle(
      fontFamily: 'Cinzel',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: lh,
      color: bodyColor,
    );
    TextStyle small = body.copyWith(
      fontSize: 14,
      color: bodyColor.withOpacity(0.9),
    );

    final cardBg = isDark
        ? const Color(0xFF1F1A2B).withOpacity(0.85)
        : theme.colorScheme.surface.withOpacity(0.92);

    final List<BoxShadow> cardShadow = [
      if (isDark)
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 10),
        )
      else
        BoxShadow(
          color: const Color(0xFF6A41A1).withOpacity(0.08),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 10),
        ),
    ];

    Widget card(Widget child) => Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: cardShadow,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFF2F1654).withOpacity(0.06),
        ),
      ),
      child: child,
    );

    Widget bullets(List<String> items) => Column(
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('About Mental Health', style: h1.copyWith(fontSize: 24)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              card(
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
                    bullets([
                      "It changes over time — and that’s okay. 🌖",
                      "Everyone struggles sometimes; you’re not alone. 🤝",
                      "Small steps can make a big difference. 🍃",
                    ]),
                  ],
                ),
              ),

              card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Why It Matters', style: h1),
                    const SizedBox(height: 8),
                    bullets([
                      "Better focus and decision-making 🧠",
                      "Healthier relationships and communication 🫶",
                      "More energy and motivation ⚡",
                      "Greater resilience when life gets heavy 🛡️",
                    ]),
                  ],
                ),
              ),

              card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Common Challenges (In Our Stories)', style: h1),
                    const SizedBox(height: 8),
                    Text('Anxiety 😮‍💨', style: h2),
                    const SizedBox(height: 6),
                    bullets([
                      "Racing thoughts, restlessness, and overthinking",
                      "Tight chest or fast heartbeat during stress",
                      "Avoiding situations that feel overwhelming",
                    ]),
                    const SizedBox(height: 10),
                    Text('Depression 🌧️', style: h2),
                    const SizedBox(height: 6),
                    bullets([
                      "Low mood or numbness most of the day",
                      "Loss of interest in things you used to enjoy",
                      "Changes in sleep or appetite; low energy",
                    ]),
                    const SizedBox(height: 10),
                    Text('Loneliness 🫥', style: h2),
                    const SizedBox(height: 6),
                    bullets([
                      "Feeling disconnected — even around people",
                      "Withdrawing from friends or routines",
                      "Longing to be seen, heard, or understood",
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      "Storium isn’t a medical tool — it’s a gentle, interactive space to notice patterns, feelings, and choices.",
                      style: small,
                    ),
                  ],
                ),
              ),

              card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How Storium Helps 🎮', style: h1),
                    const SizedBox(height: 8),
                    bullets([
                      "Play through everyday scenarios in a safe space",
                      "Reflect on choices — notice what soothes vs. what spikes anxiety",
                      "Build small skills: breathing, reframing, reaching out",
                      "Finish with a warm summary — no judgment, just insight",
                    ]),
                  ],
                ),
              ),

              card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gentle Skills You Can Try 🌿', style: h1),
                    const SizedBox(height: 8),
                    bullets([
                      "🫁 4-7-8 Breathing: inhale 4, hold 7, exhale 8 — repeat x4",
                      "📝 Label It: “I’m feeling anxious; it will pass.” Naming helps",
                      "🔁 Reframe: “I failed” → “I learned something I can use”",
                      "📅 Micro-steps: 10-minute walk, 1 page read, 1 message to a friend",
                      "🤗 Reach Out: share with someone you trust",
                    ]),
                  ],
                ),
              ),

              card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🆘 When To Seek Extra Support 🆘', style: h1),
                    const SizedBox(height: 8),
                    Text(
                      "If intense feelings last for weeks, disrupt daily life, or you feel unsafe, consider professional help. "
                      "Speaking with a counselor, therapist, or doctor can be a brave next step.",
                      style: body,
                    ),
                    const SizedBox(height: 10),
                    bullets([
                      "Emergency: contact your local emergency number 🚑",
                      "Helplines / talk lines in your region ☎️",
                      "Campus or community counseling services 🧾",
                    ]),
                    const SizedBox(height: 6),
                    Text(
                      "Storium doesn’t diagnose or treat conditions. It’s a supportive companion — not a substitute for care.",
                      style: small.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              card(
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
