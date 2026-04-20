import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'models/user_session.dart';
import 'utils/theme_manager.dart';
import 'providers/settings_manager.dart';
import 'providers/saved_images_store.dart';
import 'pages/sign_in_page.dart';
import 'services/user_session_cloud_sync.dart';
import 'theme/app_themes.dart';
import 'utils/app_asset_precache.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configurePersistentImageCache();
  await UserSession.loadFromStorage();
  final settingsManager = SettingsManager();
  await settingsManager.initialize();
  await UserSessionCloudSync.hydrateIfSignedIn(
    settingsManager: settingsManager,
  );
  final savedImagesStore = SavedImagesStore();
  await savedImagesStore.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsManager),
        ChangeNotifierProvider.value(value: savedImagesStore),
      ],
      child: MyApp(),
    ),
  );
}

void _configurePersistentImageCache() {
  const targetMaximumEntries = 2000;
  const targetMaximumBytes = 512 * 1024 * 1024; // 512 MB
  final cache = PaintingBinding.instance.imageCache;
  if (cache.maximumSize < targetMaximumEntries) {
    cache.maximumSize = targetMaximumEntries;
  }
  if (cache.maximumSizeBytes < targetMaximumBytes) {
    cache.maximumSizeBytes = targetMaximumBytes;
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeManager _themeManager = ThemeManager();
  bool _didScheduleRasterPrecache = false;

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
        if (!_didScheduleRasterPrecache && child != null) {
          _didScheduleRasterPrecache = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              unawaited(precacheStoriumRasterAssets(context));
            }
          });
        }
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
