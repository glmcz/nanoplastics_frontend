import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'settings_manager.dart';
import '../firebase_options.dart';

/// Logger service for Firebase Analytics and Error Tracking
/// Handles: App lifecycle, user events, performance metrics, and error collection
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  bool _initialized = false;

  /// Check if analytics is enabled if not only print into console don't sent to firebase.
  bool _isAnalyticsEnabled() {
    try {
      return SettingsManager().analyticsEnabled;
    } catch (e) {
      // SettingsManager not initialized yet, default to true for logging during startup
      return true;
    }
  }

  /// Initialize Firebase and Crashlytics
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase with options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Set up Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
        _logToConsole(
          'Flutter Error',
          details.exception.toString(),
          StackTrace.fromString(details.stack.toString()),
          'ERROR',
        );
      };

      // Handle async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          fatal: true,
        );
        _logToConsole(
          'Async Error',
          error.toString(),
          stack,
          'FATAL',
        );
        return true;
      };

      // Enable Crashlytics collection based on analytics setting
      final analyticsEnabled = _isAnalyticsEnabled();
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(analyticsEnabled);

      _logToConsole('LoggerService',
          'Firebase & Crashlytics initialized (collection: $analyticsEnabled)');
      _initialized = true;
    } catch (e, stackTrace) {
      _logToConsole(
        'LoggerService Initialization Failed',
        e.toString(),
        stackTrace,
        'ERROR',
      );
    }
  }

  /// Log app lifecycle events
  void logAppLifecycle(String event) {
    _logToConsole('App Lifecycle', event);
    if (_initialized && _isAnalyticsEnabled()) {
      FirebaseCrashlytics.instance.log('APP_LIFECYCLE: $event');
    }
  }

  /// Log user actions (e.g., button taps, navigation)
  void logUserAction(String action, {Map<String, dynamic>? params}) {
    final message = params != null ? '$action - ${params.toString()}' : action;

    _logToConsole('User Action', message);

    if (_initialized && _isAnalyticsEnabled()) {
      FirebaseCrashlytics.instance.log('USER_ACTION: $message');
    }
  }

  /// Log feature usage
  void logFeatureUsage(String feature,
      {String? category, Map<String, dynamic>? metadata}) {
    final message = 'Feature: $feature | Category: ${category ?? "general"}';
    _logToConsole('Feature Usage', message);

    if (_initialized && _isAnalyticsEnabled()) {
      FirebaseCrashlytics.instance.log('FEATURE_USAGE: $message');
      if (metadata != null) {
        FirebaseCrashlytics.instance
            .setCustomKey('feature_metadata', metadata.toString());
      }
    }
  }

  /// Log PDF viewer interactions
  void logPDFInteraction(String action, {int? page, double? zoomLevel}) {
    final details = 'Action: $action, Page: $page, Zoom: $zoomLevel';
    _logToConsole('PDF Interaction', details);

    if (_initialized && _isAnalyticsEnabled()) {
      FirebaseCrashlytics.instance.log('PDF_INTERACTION: $details');
    }
  }

  /// Log idea submission
  void logIdeaSubmission({
    required String category,
    required String title,
    int? contentLength,
  }) {
    final message =
        'Category: $category, Title: $title, Length: $contentLength chars';
    _logToConsole('Idea Submission', message);

    if (_initialized && _isAnalyticsEnabled()) {
      FirebaseCrashlytics.instance.log('IDEA_SUBMISSION: $message');
      FirebaseCrashlytics.instance.setCustomKey('idea_category', category);
    }
  }

  /// Log language changes
  void logLanguageChange(String from, String to) {
    final message = '$from → $to';
    _logToConsole('Language Change', message);

    if (_initialized && _isAnalyticsEnabled()) {
      FirebaseCrashlytics.instance.log('LANGUAGE_CHANGE: $message');
      FirebaseCrashlytics.instance.setCustomKey('current_language', to);
    }
  }

  /// Log screen navigation
  void logScreenNavigation(String screenName, {Map<String, dynamic>? params}) {
    final message =
        'Screen: $screenName, Params: ${params?.toString() ?? "none"}';
    _logToConsole('Screen Navigation', message);

    if (_initialized && _isAnalyticsEnabled()) {
      FirebaseCrashlytics.instance.log('SCREEN_NAV: $message');
      FirebaseCrashlytics.instance.setCustomKey('current_screen', screenName);
    }
  }

  /// Log API/Network calls
  void logNetworkCall(
    String endpoint, {
    required String method,
    int? statusCode,
    int? durationMs,
  }) {
    final message =
        'Method: $method, Endpoint: $endpoint, Status: $statusCode, Duration: ${durationMs}ms';
    _logToConsole('Network Call', message);

    if (_initialized && _isAnalyticsEnabled()) {
      FirebaseCrashlytics.instance.log('NETWORK: $message');
    }
  }

  /// Log errors with context
  void logError(
    String title,
    Object error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]) {
    _logToConsole(title, error.toString(), stackTrace, 'ERROR');

    if (_initialized) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: title,
        fatal: false,
      );

      // Add context information
      if (context != null) {
        context.forEach((key, value) {
          FirebaseCrashlytics.instance
              .setCustomKey('error_context_$key', value.toString());
        });
      }
    }
  }

  /// Log performance metrics
  void logPerformance(
    String metric, {
    required int durationMs,
    Map<String, dynamic>? tags,
  }) {
    final message = 'Metric: $metric, Duration: ${durationMs}ms';
    _logToConsole('Performance', message);

    if (_initialized && _isAnalyticsEnabled()) {
      FirebaseCrashlytics.instance.log('PERFORMANCE: $message');

      // Flag slow operations (>1000ms)
      if (durationMs > 1000) {
        FirebaseCrashlytics.instance.setCustomKey('slow_operation', metric);
        FirebaseCrashlytics.instance
            .setCustomKey('slow_duration_ms', durationMs);
      }

      if (tags != null) {
        tags.forEach((key, value) {
          FirebaseCrashlytics.instance
              .setCustomKey('perf_tag_$key', value.toString());
        });
      }
    }
  }

  /// Log PDF rendering performance
  void logPDFPerformance({
    required int pages,
    required int durationMs,
    required int fileSizeMB,
  }) {
    final message =
        'Pages: $pages, Duration: ${durationMs}ms, FileSize: ${fileSizeMB}MB';
    _logToConsole('PDF Performance', message);

    if (_initialized && _isAnalyticsEnabled()) {
      FirebaseCrashlytics.instance.log('PDF_PERF: $message');
      FirebaseCrashlytics.instance.setCustomKey('pdf_pages', pages);
      FirebaseCrashlytics.instance.setCustomKey('pdf_file_size_mb', fileSizeMB);
    }
  }

  /// Log debug information (only in development)
  void logDebug(String title, dynamic data) {
    if (kDebugMode) {
      _logToConsole(title, data.toString(), null, 'DEBUG');
    }
  }

  /// Console logging with timestamp
  void _logToConsole(
    String title,
    String message, [
    StackTrace? stackTrace,
    String level = 'INFO',
  ]) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [$level] $title: $message');

    if (stackTrace != null && kDebugMode) {
      debugPrint('StackTrace:\n$stackTrace');
    }
  }

  /// Set user identification for error tracking
  void setUserID(String userID) {
    if (_initialized) {
      FirebaseCrashlytics.instance.setUserIdentifier(userID);
      _logToConsole('User Identification', 'Set UserID: $userID');
    }
  }

  /// Set custom metadata for error context
  void setCustomMetadata(String key, dynamic value) {
    if (_initialized) {
      FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
    }
  }

  /// Clear user data (on logout)
  Future<void> clearUserData() async {
    if (_initialized) {
      await FirebaseCrashlytics.instance.setUserIdentifier('');
      _logToConsole('Logger', 'User data cleared');
    }
  }

  /// Update Crashlytics collection when analytics setting changes
  Future<void> updateCrashlyticsCollectionEnabled() async {
    if (_initialized) {
      final analyticsEnabled = _isAnalyticsEnabled();
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(analyticsEnabled);
      _logToConsole(
          'Logger', 'Crashlytics collection updated: $analyticsEnabled');
    }
  }
}
