import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/settings_manager.dart';
import '../services/service_locator.dart';
import '../utils/pdf_utils.dart';
import '../utils/app_theme_colors.dart';
import '../main.dart';

/// Shared language selection logic for screens that support language switching.
/// Handles language selection, PDF downloads, and app restart.
mixin LanguageSelectionMixin<T extends StatefulWidget> on State<T> {
  /// List of supported languages with flags and codes.
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'flag': '🇺🇸', 'name': 'English'},
    {'code': 'cs', 'flag': '🇨🇿', 'name': 'Čeština'},
    {'code': 'es', 'flag': '🇪🇸', 'name': 'Español'},
    {'code': 'fr', 'flag': '🇫🇷', 'name': 'Français'},
    {'code': 'ru', 'flag': '🇷🇺', 'name': 'Русский'},
  ];

  late SettingsManager settingsManager;
  late String selectedLanguage;

  /// Initialize language state (call in initState).
  void initLanguageSelection() {
    settingsManager = ServiceLocator().settingsManager;
    selectedLanguage = settingsManager.userLanguage;
  }

  /// Handle language selection with PDF download and app restart.
  Future<void> selectLanguage(String code) async {
    if (selectedLanguage == code) return;

    setState(() => selectedLanguage = code);
    await settingsManager.setUserLanguage(code);

    // Download PDFs for non-EN languages in LITE build
    if (code != 'en' && settingsManager.buildType == 'LITE') {
      final success = await _downloadPDFForLanguageWithProgress(code);
      if (!success && mounted) {
        _showOfflineFallbackDialog(code);
        return;
      }
    }

    if (mounted) {
      RestartableApp.restartApp(context);
    }
  }

  /// Download PDF for a specific language with progress feedback.
  Future<bool> _downloadPDFForLanguageWithProgress(String langCode) async {
    try {
      final resolved = await resolveMainReport(langCode);
      if (resolved != null) return true;

      if (!mounted) return false;

      double progress = 0;
      bool isCancelled = false;
      bool dialogDismissed = false;
      late StateSetter dialogSetState;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            dialogSetState = setState;
            return AlertDialog(
              backgroundColor: AppThemeColors.of(context).dialogBackground,
              title: Text(
                'Downloading ${supportedLanguages.firstWhere((l) => l['code'] == langCode)['name']}',
                style: const TextStyle(color: AppColors.pastelAqua),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.pastelAqua,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AppThemeColors.of(context).textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    isCancelled = true;
                    dialogDismissed = true;
                    if (mounted) Navigator.of(context).pop();
                  },
                  child:
                      const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ),
      );

      await downloadReport(
        langCode,
        onProgress: (progressValue) {
          if (!isCancelled && mounted) {
            dialogSetState(() => progress = progressValue);
          }
        },
      );

      if (isCancelled) return false;

      if (!dialogDismissed && mounted) {
        Navigator.of(context).pop();
        dialogDismissed = true;
      }
      return true;
    } catch (e) {
      // Dialog already dismissed by user cancel or error—no double pop
      return false;
    }
  }

  /// Show fallback dialog when PDF download fails.
  void _showOfflineFallbackDialog(String attemptedLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Download Failed',
            style: TextStyle(color: AppColors.pastelAqua)),
        content: Text(
          'Unable to download language files. Would you like to retry or use English?',
          style: TextStyle(color: AppThemeColors.of(context).textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              selectLanguage('en');
            },
            child: const Text('Use English',
                style: TextStyle(color: AppColors.pastelMint)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              selectLanguage(attemptedLanguage);
            },
            child: const Text('Retry',
                style: TextStyle(color: AppColors.pastelAqua)),
          ),
        ],
      ),
    );
  }
}
