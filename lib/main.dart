import 'package:flutter/material.dart';
import 'utils/theme_manager.dart';
import 'pages/sign_in_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeManager _themeManager = ThemeManager();

  @override
  void dispose() {
    _themeManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeManager,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Storium',
          themeMode: _themeManager.themeMode,
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.transparent,
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.transparent,
          ),
          home: SignInPage(themeManager: _themeManager),
        );
      },
    );
  }
}
