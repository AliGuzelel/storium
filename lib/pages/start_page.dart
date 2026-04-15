import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/story_progress_service.dart';
import '../effects/theme_effect_manager.dart';
import '../localization/app_strings.dart';
import '../providers/settings_manager.dart';
import '../theme/app_themes.dart';
import '../utils/theme_manager.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/app_button.dart';
import '../widgets/glitch_text.dart';
import 'settings_page.dart';
import 'about_mh.dart';
import 'profile_page.dart';
import 'story_page.dart';
import 'story_selection_page.dart';
import '../garden/garden_page.dart';

class StartPage extends StatefulWidget {
  final ThemeManager themeManager;
  const StartPage({super.key, required this.themeManager});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final StoryProgressService _progressService = StoryProgressService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsManager>();
    final secondary = AppThemes.secondary(settings.themeColor);

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _buildSideDrawer(context),
      body: AppGradientBackground(
        addVignette: true,
        breathe: true,
        child: Stack(
          children: [
            Positioned.fill(child: buildThemeEffect(settings.themeColor)),
            SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: GlitchText(
                            text: 'STORIUM',
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 56,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 10,
                              color: isDark
                                  ? Colors.white.withOpacity(0.9)
                                  : const Color(0xFF2F1654),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _glassButton(
                          label: t(context, 'start'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StorySelectionPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        _glassButton(
                          label: t(context, 'continue'),
                          onTap: _continueStory,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Builder(
                          builder: (ctx) => Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.white.withOpacity(0.10),
                              highlightColor: Colors.white.withOpacity(0.04),
                              onTap: () => Scaffold.of(ctx).openDrawer(),
                              child: Center(
                                child: Tooltip(
                                  message: t(context, 'menu'),
                                  child: Icon(
                                    Icons.menu_rounded,
                                    color: Color.lerp(
                                      Colors.white,
                                      secondary,
                                      isDark ? 0.45 : 0.25,
                                    ),
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsManager>();
    final darkBase = AppThemes.darkGradient(settings.themeColor)[1];
    final lightBase = AppThemes.primary(settings.themeColor);

    return Drawer(
      backgroundColor: (isDark ? darkBase : lightBase).withOpacity(
        isDark ? 0.92 : 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _menuButton(
                accent: AppThemes.secondary(settings.themeColor),
                text: t(context, 'profile'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _menuButton(
                accent: AppThemes.secondary(settings.themeColor),
                text: t(context, 'garden'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GardenPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _menuButton(
                accent: AppThemes.secondary(settings.themeColor),
                text: t(context, 'about_mental_health'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AboutMentalHealthPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _menuButton(
                accent: AppThemes.secondary(settings.themeColor),
                text: t(context, 'settings'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SettingsPage(themeManager: widget.themeManager),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton({
    required Color accent,
    required String text,
    required VoidCallback onPressed,
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
            border: Border.all(
              color: Color.lerp(Colors.white, accent, 0.4)!.withOpacity(0.35),
              width: 1,
            ),
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
            onTap: onPressed,
            splashColor: Colors.white.withOpacity(0.10),
            highlightColor: Colors.white.withOpacity(0.06),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continueStory() async {
    final progress = await _progressService.load();
    if (!mounted) return;

    if (progress.currentTopic == null || progress.currentStoryTitle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved story progress yet.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryPage(
          storyTitle: progress.currentStoryTitle!,
          topic: progress.currentTopic!,
        ),
      ),
    );
  }

  Widget _glassButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: 180,
      child: AppButton(label: label, onTap: onTap),
    );
  }
}
