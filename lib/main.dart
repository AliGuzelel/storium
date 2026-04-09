import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'models/user_session.dart';
import 'utils/theme_manager.dart';
import 'providers/settings_manager.dart';
import 'pages/sign_in_page.dart';
import 'theme/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.loadFromStorage();
  final settingsManager = SettingsManager();
  await settingsManager.initialize();
  runApp(ChangeNotifierProvider.value(value: settingsManager, child: MyApp()));
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

  ThemeData _buildTheme({
    required Brightness brightness,
    required String themeColor,
  }) {
    return brightness == Brightness.dark
        ? AppThemes.dark(themeColor)
        : AppThemes.light(themeColor);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsManager>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Storium',
      locale: Locale(settings.language),
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: MediaQuery(
            key: ValueKey(
              '${settings.textScale}-${settings.themeColor}-${settings.isDarkMode}',
            ),
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(settings.textScale)),
            child: child!,
          ),
        );
      },
      theme: _buildTheme(
        brightness: Brightness.light,
        themeColor: settings.themeColor,
      ),
      darkTheme: _buildTheme(
        brightness: Brightness.dark,
        themeColor: settings.themeColor,
      ),
      home: SignInPage(themeManager: _themeManager),
    );
  }
}
