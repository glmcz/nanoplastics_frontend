import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import 'package:nanoplastics_app/config/app_theme.dart';

/// Wraps a widget in a fully-configured MaterialApp for widget testing.
///
/// Provides localization delegates, dark theme, and a Scaffold ancestor
/// so that ScaffoldMessenger.of(context) works for SnackBars.
/// [textScaleFactor] and [disableAnimations] exist so accessibility rules can
/// be tested rather than assumed: 200% text scaling and the OS reduce-motion
/// setting are both acceptance criteria.
Widget buildTestableWidget(
  Widget child, {
  Locale locale = const Locale('en'),
  NavigatorObserver? navigatorObserver,
  double textScaleFactor = 1.0,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    // Taken from the generated list, exactly as main.dart does. Hardcoding it
    // here once omitted Arabic, so every Arabic test silently fell back to
    // English and passed without testing anything.
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    navigatorObservers:
        navigatorObserver != null ? [navigatorObserver] : const [],
    // Applied at the app builder, not around `home`: a pushed route sits
    // above `home` in the tree and would otherwise miss these overrides.
    builder: (context, routeChild) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScaleFactor),
        disableAnimations: disableAnimations,
      ),
      child: routeChild ?? const SizedBox.shrink(),
    ),
    home: Scaffold(body: child),
  );
}
