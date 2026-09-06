import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'config/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'screens/paper_detail_screen.dart';
import 'screens/web/web_landing_screen.dart';
import 'l10n/app_localizations.dart';
import 'l10n_web/web_localizations.dart';
import 'services/digest_service.dart';
import 'services/settings_manager.dart';
import 'services/service_locator.dart';
import 'services/update_service.dart';
import 'services/push_notification_service.dart';
import 'utils/route_observer.dart';
import 'web/web_privacy_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Settings Manager
  await SettingsManager.init();

  // Persist current app version from PackageInfo
  try {
    final info = await PackageInfo.fromPlatform();
    await SettingsManager().setCurrentAppVersion(info.version);
  } catch (e) {
    debugPrint('Error reading app version: $e'); // ignore: avoid_print
  }

  // Initialize Service Locator (all singleton services)
  // Build type is determined at compile time via BuildConfig.bundleAllLangs.
  await ServiceLocator().initialize();

  final serviceLocator = ServiceLocator();
  final logger = serviceLocator.loggerService;
  // Firebase.initializeApp() was fired unawaited in ServiceLocator().initialize()
  // so it wouldn't block the first frame. But registerHandlers() below touches
  // FirebaseMessaging statics that require Firebase.app() to exist — awaiting
  // here (memoized, no-op if already done) closes that race without adding
  // meaningful latency, since Firebase init is normally already done or near-done.
  await logger.initialize();
  logger.logAppLifecycle('App Starting...');

  // Set status bar style — both modes use dark surfaces, so always light icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.light, // Both modes have dark surfaces
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Keep native apps portrait-first, but let web use full desktop layouts.
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Register FCM listeners before runApp — must be early so onMessageOpenedApp isn't missed.
  // Firebase is guaranteed ready by the `await logger.initialize()` above.
  PushNotificationService().registerHandlers();

  // Notification tap → fetch paper → open PaperDetailScreen
  PushNotificationService.onPaperOpen = (paperId) async {
    debugPrint('[NAV] onPaperOpen fired: $paperId');
    final paper = await DigestService().fetchPaperById(paperId);
    debugPrint('[NAV] paper fetched: ${paper?.title ?? "null"}');
    debugPrint(
        '[NAV] navigatorKey.currentState: ${appNavigatorKey.currentState}');
    if (paper == null) return;
    // Wait for navigator to be ready if app is resuming from background
    await Future.delayed(const Duration(milliseconds: 300));
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => PaperDetailScreen(paper: paper)),
    );
  };

  // Delay permission prompt / token registration so it doesn't compete with
  // first-frame render and PDF extraction for CPU on a cold, throttled launch.
  Future.delayed(const Duration(seconds: 3), () {
    PushNotificationService().init();
  });

  // Schedule version check after 5 seconds — only on GitHub builds.
  // Store-channel builds inject NoOpUpdateService, where isEnabled = false.
  if (ServiceLocator().updateService.isEnabled) {
    Future.delayed(const Duration(seconds: 5), () {
      ServiceLocator().updateService.checkForUpdates();
    });
  }

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

  static Future<void> changeLocale(BuildContext context, Locale locale) {
    return context
            .findAncestorStateOfType<_NanoSolveHiveAppState>()
            ?.setLocale(locale) ??
        Future.value();
  }

  @override
  State<NanoSolveHiveApp> createState() => _NanoSolveHiveAppState();
}

class _NanoSolveHiveAppState extends State<NanoSolveHiveApp>
    with TickerProviderStateMixin {
  late Locale _locale;
  late Function(UpdateState, double) _updateListener;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    final settingsManager = SettingsManager();
    _locale = _resolveInitialLocale(settingsManager);

    _fadeController = AnimationController(
      vsync: this,
      value: 1.0,
      duration: const Duration(milliseconds: 150),
    );

    // Attach global update listener for automatic notifications
    _attachUpdateListener();
  }

  Future<void> setLocale(Locale locale) async {
    await _fadeController.animateTo(0.0);
    if (!mounted) return;
    setState(() => _locale = locale);
    await _fadeController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 220),
    );
  }

  void _attachUpdateListener() {
    _updateListener = (state, progress) {
      if (!mounted) return;
      // Rebuild UI to show/hide update badge on settings icon
      setState(() {});
    };
    ServiceLocator().updateService.addStateListener(_updateListener);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    ServiceLocator().updateService.removeStateListener(_updateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsManager = SettingsManager();
    final shouldShowOnboarding = !settingsManager.hasShownOnboarding;

    final darkModeEnabled = settingsManager.darkModeEnabled;

    return MaterialApp(
      title: 'NanoSolve Hive',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      navigatorObservers: [routeObserver],
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        WebLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      routes: {
        '/privacy': (_) => const WebPrivacyScreen(),
      },
      builder: kIsWeb
          ? null
          : (context, child) {
              final isRTL = Directionality.of(context) == TextDirection.rtl;
              if (!isRTL) return child!;
              return Stack(
                children: [
                  child!,
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 20,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragEnd: (details) {
                        if ((details.primaryVelocity ?? 0) < -300) {
                          Navigator.of(context, rootNavigator: false)
                              .maybePop();
                        }
                      },
                    ),
                  ),
                ],
              );
            },
      home: kIsWeb
          ? const WebLandingScreen()
          : (shouldShowOnboarding
              ? const OnboardingScreen()
              : const MainScreen()),
    );
  }
}

Locale _resolveInitialLocale(SettingsManager settingsManager) {
  final storedLanguage = settingsManager.storedUserLanguage?.toLowerCase();
  if (_isSupportedLanguageCode(storedLanguage)) {
    return Locale(storedLanguage!);
  }

  if (kIsWeb) {
    final browserLocale = _matchSupportedLocale(
      ui.PlatformDispatcher.instance.locales,
    );
    if (browserLocale != null) {
      return browserLocale;
    }
  }

  return const Locale('en');
}

bool _isSupportedLanguageCode(String? languageCode) {
  if (languageCode == null || languageCode.isEmpty) {
    return false;
  }

  return AppLocalizations.supportedLocales.any(
    (locale) => locale.languageCode == languageCode,
  );
}

Locale? _matchSupportedLocale(List<Locale> preferredLocales) {
  for (final locale in preferredLocales) {
    final languageCode = locale.languageCode.toLowerCase();
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == languageCode) {
        return supported;
      }
    }
  }

  return null;
}
