import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/in_progress_story.dart';
import '../services/story_progress_service.dart';
import '../services/achievement_service.dart';
import '../utils/story_resume_catalog.dart';
import '../effects/theme_effect_manager.dart';
import '../localization/app_strings.dart';
import '../providers/settings_manager.dart';
import '../theme/app_themes.dart';
import '../utils/theme_manager.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/app_button.dart';
import '../widgets/glitch_text.dart';
import '../widgets/localized_text.dart';
import 'settings_page.dart';
import 'about_mh.dart';
import 'profile_page.dart';
import 'story_page.dart';
import 'story_selection_page.dart';
import 'my_space_page.dart';
import 'collections_page.dart';
import 'daily_questions_page.dart';
import '../garden/garden_page.dart';

class StartPage extends StatefulWidget {
  final ThemeManager themeManager;
  const StartPage({super.key, required this.themeManager});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final StoryProgressService _progressService = StoryProgressService();
  final AchievementService _achievementService = AchievementService();

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
            Positioned.fill(
              child: KeyedSubtree(
                key: ValueKey<String>('start_theme_fx_${settings.themeColor}'),
                child: RepaintBoundary(
                  child: buildThemeEffect(settings.themeColor),
                ),
              ),
            ),
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
                              fontSize: 72,
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
                          onTap: () => showContinueList(context),
                        ),
                        const SizedBox(height: 15),
                        _glassButton(
                          label: t(context, 'explore_collections'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CollectionsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        _glassButton(
                          label: t(context, 'daily_check_in'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DailyQuestionsPage(),
                              ),
                            );
                          },
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
                text: t(context, 'my_space'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MySpacePage()),
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

  Future<List<InProgressStory>> getInProgressStories() async {
    return _progressService.fetchUnfinishedStories();
  }

  Future<void> showContinueList(BuildContext context) async {
    final stories = await getInProgressStories();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.48),
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        final maxH = size.height * 0.62;
        final w = (size.width - 40).clamp(280.0, 420.0);
        return Theme(
          data: Theme.of(context),
          child: Material(
            type: MaterialType.transparency,
            color: Colors.transparent,
            child: Center(
              child: SizedBox(
                width: w,
                height: maxH,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: stories.isEmpty
                            ? _buildEmptyContinueState(dialogContext)
                            : _buildContinueListContent(dialogContext, stories),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueListContent(
    BuildContext context,
    List<InProgressStory> stories,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(context, 'continue_where_left'),
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 21,
            color: Colors.white.withOpacity(0.95),
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: stories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = stories[index];
              return _continueItem(
                context: context,
                item: item,
                onTap: () {
                  Navigator.of(context).pop();
                  _openStoryFromInProgress(item);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContinueState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(context, 'continue_where_left'),
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 21,
            color: Colors.white.withOpacity(0.95),
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          t(context, 'no_unfinished_stories'),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.5,
            color: Colors.white.withOpacity(0.84),
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
          ),
        ),
        const SizedBox(height: 14),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white.withOpacity(0.24)),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              this.context,
              MaterialPageRoute(builder: (_) => const StorySelectionPage()),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: LocalizedText(
              t(context, 'start_new_story'),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _continueItem({
    required BuildContext context,
    required InProgressStory item,
    required VoidCallback onTap,
  }) {
    final emoji = StoryResumeCatalog.emojis[item.storyId] ?? '📖';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withOpacity(0.08),
        highlightColor: Colors.white.withOpacity(0.04),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      StoryResumeCatalog.displayTitleForId(item.storyId),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        decorationColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${t(context, 'scene')} ${item.sceneIndex}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        decoration: TextDecoration.none,
                        decorationColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: Colors.white.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openStoryFromInProgress(InProgressStory selected) {
    if (!mounted) return;
    final routeConfig = _routeConfigForStoryId(selected.storyId);
    if (routeConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(context, 'story_not_available'))),
      );
      return;
    }
    final clampedScene = selected.sceneIndex < 1 ? 1 : selected.sceneIndex;
    unawaited(_achievementService.trackContinueUsage());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryPage(
          storyTitle: routeConfig.storyTitle,
          topic: routeConfig.topic,
          initialSceneIndex: clampedScene,
          resumeStoryId: selected.storyId,
        ),
      ),
    );
  }

  _StoryRouteConfig? _routeConfigForStoryId(String storyId) {
    switch (storyId) {
      case 'too_loud_inside':
        return const _StoryRouteConfig(
          storyTitle: 'Too Loud Inside',
          topic: 'Anxiety',
        );
      case 'alone_again':
        return const _StoryRouteConfig(
          storyTitle: 'Alone, Again',
          topic: 'Loneliness',
        );
      case 'what_still_remains':
        return const _StoryRouteConfig(
          storyTitle: 'What Still Remains',
          topic: 'Depression',
        );
      case 'the_day_after':
        return const _StoryRouteConfig(
          storyTitle: 'The Space You Left',
          topic: 'Grief',
        );
      case 'almost_there':
        return const _StoryRouteConfig(
          storyTitle: 'Almost There',
          topic: 'Failure',
        );
      default:
        return null;
    }
  }

  Widget _glassButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: 180,
      child: AppButton(label: label, onTap: onTap),
    );
  }
}

class _StoryRouteConfig {
  final String storyTitle;
  final String topic;

  const _StoryRouteConfig({required this.storyTitle, required this.topic});
}
