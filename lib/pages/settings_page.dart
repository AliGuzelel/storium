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

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontFamily: 'Cinzel')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dark Mode",
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
                ),
                Switch(
                  activeColor: const Color(0xFF451B80),
                  value: widget.themeManager.isDarkMode,
                  onChanged: (value) =>
                      setState(() => widget.themeManager.toggleTheme(value)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Music Volume",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
              ),
            ),
            Slider(
              activeColor: const Color(0xFF451B80),
              value: musicVolume,
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => musicVolume = v),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Sound Effects Volume",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
              ),
            ),
            Slider(
              activeColor: const Color(0xFF451B80),
              value: soundVolume,
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => soundVolume = v),
            ),
            const Spacer(),
            const Text(
              "Storium v1.0.0",
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              "Developed with 💜 by Ali Yakup Guzelel, Harir Duraid, Sulafa Yahya",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
