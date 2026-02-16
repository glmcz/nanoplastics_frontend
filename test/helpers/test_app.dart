import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import 'package:nanoplastics_app/config/app_theme.dart';

/// Wraps a widget in a fully-configured MaterialApp for widget testing.
///
/// Provides localization delegates, dark theme, and a Scaffold ancestor
/// so that ScaffoldMessenger.of(context) works for SnackBars.
Widget buildTestableWidget(
  Widget child, {
  Locale locale = const Locale('en'),
  NavigatorObserver? navigatorObserver,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('cs'),
      Locale('es'),
      Locale('fr'),
      Locale('ru'),
    ],
    theme: AppTheme.darkTheme,
    navigatorObservers:
        navigatorObserver != null ? [navigatorObserver] : const [],
    home: Scaffold(body: child),
  );
}
