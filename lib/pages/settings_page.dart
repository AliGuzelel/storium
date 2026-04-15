import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_session.dart';
import '../localization/app_strings.dart';
import '../providers/settings_manager.dart';
import '../theme/app_themes.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/app_button.dart';
import '../utils/theme_manager.dart';
import 'sign_in_page.dart';

class SettingsPage extends StatefulWidget {
  final ThemeManager themeManager;
  const SettingsPage({super.key, required this.themeManager});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  Widget _themeOption({
    required String keyName,
    required String label,
    required Color previewColor,
  }) {
    final settings = context.watch<SettingsManager>();
    final bool isSelected = settings.themeColor == keyName;

    return GestureDetector(
      onTap: () => context.read<SettingsManager>().updateThemeColor(keyName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(isSelected ? 0.5 : 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: previewColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.75)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsManager>();
    final languageLabel = settings.language == 'tr' ? 'Turkce' : 'English';

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          t(context, 'settings'),
          style: const TextStyle(fontFamily: 'Cinzel'),
        ),
        backgroundColor: Colors.white.withOpacity(0.04),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            children: [
              _glassPanel(
                child: Row(
                  children: [
                    const Text("🌙", style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(t(context, 'dark_mode')),
                          _subText(t(context, 'switch_theme_vibe')),
                        ],
                      ),
                    ),
                    Switch(
                      activeColor: AppThemes.primary(settings.themeColor),
                      value: settings.isDarkMode,
                      onChanged: (value) =>
                          context.read<SettingsManager>().toggleDarkMode(value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _glassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(t(context, 'audio')),
                    _subText(t(context, 'control_audio')),
                    const SizedBox(height: 14),

                    Text(
                      "🎵 ${t(context, 'music_volume')}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Slider(
                      value: settings.musicVolume,
                      max: 100,
                      onChanged: (value) => context
                          .read<SettingsManager>()
                          .updateMusicVolume(value),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "🔊 ${t(context, 'sound_effects')}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Slider(
                      value: settings.soundVolume,
                      max: 100,
                      onChanged: (value) => context
                          .read<SettingsManager>()
                          .updateSoundVolume(value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _glassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(t(context, 'text_size')),
                    _subText(t(context, 'adjust_text')),
                    const SizedBox(height: 14),

                    Slider(
                      value: settings.textScale,
                      min: 0.8,
                      max: 1.3,
                      divisions: 5,
                      onChanged: (value) => context
                          .read<SettingsManager>()
                          .updateTextScale(value),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t(context, 'preview_text_size'),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14 * settings.textScale,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _glassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(t(context, 'language')),
                    _subText(t(context, 'choose_language')),
                    const SizedBox(height: 12),

                    DropdownButton<String>(
                      value: languageLabel,
                      dropdownColor: Colors.black,
                      items: ["English", "Turkce"]
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        final langCode = value == 'Turkce' ? 'tr' : 'en';
                        context.read<SettingsManager>().updateLanguage(
                          langCode,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _glassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(t(context, 'theme_colors')),
                    _subText(t(context, 'pick_visual_style')),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _themeOption(
                          keyName: 'purple',
                          label: 'Amethyst',
                          previewColor: const Color(0xFF6A41A1),
                        ),
                        _themeOption(
                          keyName: 'blue',
                          label: 'Azure',
                          previewColor: const Color(0xFF2C5CCF),
                        ),
                        _themeOption(
                          keyName: 'green',
                          label: 'Emerald',
                          previewColor: const Color(0xFF2E8B57),
                        ),
                        _themeOption(
                          keyName: 'pink',
                          label: 'Sakura',
                          previewColor: const Color(0xFFF4A7B9),
                        ),
                        _themeOption(
                          keyName: 'red',
                          label: 'Cherry',
                          previewColor: const Color(0xFF6D1A1A),
                        ),
                        _themeOption(
                          keyName: 'grayscale',
                          label: 'Silver',
                          previewColor: const Color(0xFFD7D7D7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _glassPanel(
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: t(context, 'sign_out'),
                    onTap: _signOut,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2140),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            t(context, 'sign_out'),
            style: const TextStyle(fontFamily: 'Cinzel', color: Colors.white),
          ),
          content: Text(
            t(context, 'sign_out_confirm'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                t(context, 'cancel'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A1F89),
              ),
              child: Text(
                t(context, 'sign_out'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) return;

    await UserSession.clearCurrentUser();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => SignInPage(themeManager: widget.themeManager),
      ),
      (route) => false,
    );
  }
}
