import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/theme_manager.dart';
import '../widgets/glitch_text.dart';
import 'settings_page.dart';
import 'about_mh.dart';
import 'profile_page.dart';
import 'story_selection_page.dart';
import '../widgets/gradient_scaffold.dart';

class StartPage extends StatefulWidget {
  final ThemeManager themeManager;
  const StartPage({super.key, required this.themeManager});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    if (_controller.isAnimating) _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientScaffold(
      drawer: _buildSideDrawer(context),
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
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
                    label: 'Start',
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
                  _glassButton(label: 'Continue', onTap: () {}),
                ],
              ),
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
                  builder: (ctx) => IconButton(
                    tooltip: 'Menu',
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF2A2140)
          : const Color(0xFF6441A5),
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
                text: 'Settings',
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
              const SizedBox(height: 20),
              _menuButton(
                text: 'About Mental Health',
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
                text: 'Profile',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9E7CC1),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
          elevation: 0,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black87,
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _glassButton({required String label, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: 160,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.1),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
