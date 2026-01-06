import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';
import '../utils/theme_manager.dart';

class SettingsPage extends StatefulWidget {
  final ThemeManager themeManager;
  const SettingsPage({super.key, required this.themeManager});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double musicVolume = 50, soundVolume = 50;

  Widget _glassPanel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    double radius = 26,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Cinzel',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(0.92),
      ),
    );
  }

  Widget _subText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        height: 1.35,
        color: Colors.white.withOpacity(0.72),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontFamily: 'Cinzel')),
        backgroundColor: Colors.white.withOpacity(0.04),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _glassPanel(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.18),
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "🌙",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle("Dark Mode"),
                                  const SizedBox(height: 3),
                                  _subText("Switch themes to match your vibe."),
                                ],
                              ),
                            ),
                            Switch(
                              activeColor: const Color(0xFF451B80),
                              value: widget.themeManager.isDarkMode,
                              onChanged: (value) => setState(
                                () => widget.themeManager.toggleTheme(value),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _glassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Audio"),
                            const SizedBox(height: 6),
                            _subText("Control music and sound effects."),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                const Text(
                                  "🎵",
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Music Volume",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF451B80),
                                inactiveTrackColor: Colors.white.withOpacity(
                                  0.25,
                                ),
                                thumbColor: Colors.white.withOpacity(0.92),
                                overlayColor: const Color(
                                  0xFF451B80,
                                ).withOpacity(0.15),
                              ),
                              child: Slider(
                                value: musicVolume,
                                min: 0,
                                max: 100,
                                onChanged: (v) =>
                                    setState(() => musicVolume = v),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Text(
                                  "🔔",
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Sound Effects Volume",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF451B80),
                                inactiveTrackColor: Colors.white.withOpacity(
                                  0.25,
                                ),
                                thumbColor: Colors.white.withOpacity(0.92),
                                overlayColor: const Color(
                                  0xFF451B80,
                                ).withOpacity(0.15),
                              ),
                              child: Slider(
                                value: soundVolume,
                                min: 0,
                                max: 100,
                                onChanged: (v) =>
                                    setState(() => soundVolume = v),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _glassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("About"),
                            const SizedBox(height: 8),
                            Text(
                              "Storium v1.0.0",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _subText(
                              "Developed with 💜 by Ali Yakup Guzelel, Harir Duraid",
                            ),
                          ],
                        ),
                      ),

                      // ✅ This pushes content to fill height when there’s extra space
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
