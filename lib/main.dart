import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'config/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'l10n/app_localizations.dart';
import 'services/settings_manager.dart';
import 'services/service_locator.dart';
import 'utils/route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Settings Manager
  await SettingsManager.init();

  // Persist current app version from PackageInfo
  try {
    final info = await PackageInfo.fromPlatform();
    await SettingsManager().setCurrentAppVersion(info.version);
  } catch (e) {
    debugPrint('Error reading app version: $e');
  }

  // Detect and persist build type FIRST (before ServiceLocator init)
  // This ensures PdfService knows which languages to extract
  final settingsManager = SettingsManager();
  if (settingsManager.buildType == 'UNKNOWN') {
    const bundleAllLangs =
        bool.fromEnvironment('BUNDLE_ALL_LANGS', defaultValue: false);
    await settingsManager.setBuildType(bundleAllLangs ? 'FULL' : 'LITE');
  }

  // Initialize Service Locator (all singleton services)
  // Now PdfService will know correct build type from SettingsManager
  // This initializes: LoggerService, PdfService, UpdateService
  await ServiceLocator().initialize();

  final serviceLocator = ServiceLocator();
  final logger = serviceLocator.loggerService;
  logger.logAppLifecycle('App Starting...');
  logger.logUserAction('build_type_set', params: {
    'type': settingsManager.buildType,
  });

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Note: Firebase is already initialized in LoggerService.initialize()

  // Schedule version check after 5 seconds
  Future.delayed(const Duration(seconds: 5), () {
    ServiceLocator().updateService.checkForUpdates();
  });

  runApp(const RestartableApp());
}

class RestartableApp extends StatefulWidget {
  const RestartableApp({super.key});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartableAppState>()?.restartApp();
  }

  @override
  State<RestartableApp> createState() => _RestartableAppState();
}

class _RestartableAppState extends State<RestartableApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: const NanoSolveHiveApp(),
    );
  }
}

class NanoSolveHiveApp extends StatefulWidget {
  const NanoSolveHiveApp({super.key});

  @override
  State<NanoSolveHiveApp> createState() => _NanoSolveHiveAppState();
}

class _NanoSolveHiveAppState extends State<NanoSolveHiveApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    final settingsManager = SettingsManager();
    final languageCode = settingsManager.userLanguage;
    _locale = Locale(languageCode);
  }

  void _updateLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsManager = SettingsManager();
    final shouldShowOnboarding = !settingsManager.hasShownOnboarding;

    return MaterialApp(
      title: 'NanoSolve Hive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorObservers: [routeObserver],

      // Localization support
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English (default)
        Locale('cs', ''), // Czech
        Locale('es', ''), // Spanish
        Locale('ru', ''), // Russian
        Locale('fr', ''), // French
      ],
      locale: _locale,

      home:
          shouldShowOnboarding ? const OnboardingScreen() : const MainScreen(),
    );
  }
}
