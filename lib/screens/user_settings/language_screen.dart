import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../services/settings_manager.dart';
import '../../utils/pdf_utils.dart';
import '../../services/service_locator.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../widgets/glowing_header_separator.dart';
import '../../main.dart';
import '../../utils/app_theme_colors.dart';

class LanguageScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;

  const LanguageScreen({super.key, this.onLanguageChanged});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late SettingsManager _settingsManager;
  late String _selectedLanguage;

  final List<LanguageOption> _languages = [
    const LanguageOption(
        code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    const LanguageOption(
        code: 'cs', name: 'Czech', nativeName: 'Čeština', flag: '🇨🇿'),
    const LanguageOption(
        code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    const LanguageOption(
        code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    const LanguageOption(
        code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
  ];

  @override
  void initState() {
    super.initState();
    _settingsManager = ServiceLocator().settingsManager;
    _selectedLanguage = _settingsManager.userLanguage;
  }

  Future<void> _selectLanguage(String code) async {
    if (_selectedLanguage == code) return;

    final previousLanguage = _selectedLanguage;
    setState(() => _selectedLanguage = code);
    await _settingsManager.setUserLanguage(code);

    // Download PDFs for non-EN languages in LITE build with progress
    if (code != 'en' && _settingsManager.buildType == 'LITE') {
      final success = await _downloadPDFForLanguageWithProgress(code);
      if (!success) {
        // Restore previous selection so the user can retry the same language
        if (mounted) {
          setState(() => _selectedLanguage = previousLanguage);
          await _settingsManager.setUserLanguage(previousLanguage);
          _showOfflineFallbackDialog(code);
          return;
        }
      }
    }

    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!(Locale(code));
    }

    // Restart the app to apply the new language
    if (mounted) {
      RestartableApp.restartApp(context);
      return;
    }
  }

  Future<bool> _downloadPDFForLanguageWithProgress(String langCode) async {
    try {
      // Check if already downloaded
      final resolved = await resolveMainReport(langCode);
      if (resolved != null) return true;

      // Show progress dialog
      if (!mounted) return false;

      double progress = 0;
      final cancellationToken = Completer<void>();
      void Function(VoidCallback)? updateDialog;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            updateDialog = setDialogState;
            return AlertDialog(
              backgroundColor: AppThemeColors.of(context).dialogBackground,
              title: Text(
                'Downloading ${_languages.firstWhere((l) => l.code == langCode).name}',
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
                    // Trigger cancellation
                    if (!cancellationToken.isCompleted) {
                      cancellationToken.complete();
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: AppColors.pastelMint),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Download with progress callback and cancellation token
      await downloadReport(
        langCode,
        onProgress: (progressValue) {
          updateDialog?.call(() => progress = progressValue);
        },
        cancellationToken: cancellationToken,
      );

      // Close progress dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      return true;
    } catch (e) {
      // Close progress dialog if still open
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      return false;
    }
  }

  void _showOfflineFallbackDialog(String attemptedLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Download Failed',
            style: TextStyle(color: AppColors.pastelAqua)),
        content: Text(
          'Unable to download ${_languages.firstWhere((l) => l.code == attemptedLanguage).name} language files. Would you like to retry or use English?',
          style: TextStyle(color: AppThemeColors.of(context).textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _selectLanguage('en'); // Fallback to English
            },
            child: const Text('Use English',
                style: TextStyle(color: AppColors.pastelMint)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _selectLanguage(attemptedLanguage); // Retry
            },
            child: const Text('Retry',
                style: TextStyle(color: AppColors.pastelAqua)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelAqua
                  .withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppColors.pastelMint
                  .withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppThemeColors.of(context).gradientEnd,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildContent(),
                    ),
                    ...GlowingHeaderSeparator.build(
                      glowColor: AppColors.energy,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,
          vertical: spacing.contentPaddingV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_back_ios,
                      color: AppThemeColors.of(context).textMain,
                      size: sizing.backIcon),
                  const SizedBox(width: AppConstants.space4),
                  Flexible(
                    child: Text(
                      l10n.categoryDetailBackToOverview,
                      style: typography.back.copyWith(
                        color: AppThemeColors.of(context).textMain,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing.headerSpacing),
          NanosolveLogo(height: sizing.logoHeightLg),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,
          vertical: spacing.contentPaddingV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(typography),
          SizedBox(height: spacing.cardSpacing * 2),
          ..._languages.map((lang) => Padding(
                padding: EdgeInsets.only(bottom: spacing.cardSpacing),
                child: _buildLanguageItem(
                  lang,
                  spacing,
                  sizing,
                  typography,
                ),
              )),
          SizedBox(height: spacing.cardSpacing),
          _buildInfoCard(spacing, sizing, typography),
          SizedBox(height: spacing.cardSpacing * 2),
        ],
      ),
    );
  }

  Widget _buildTitleSection(AppTypography typography) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelAqua, AppColors.pastelMint],
          ).createShader(bounds),
          child: Text(
            AppLocalizations.of(context)!.languageTitle,
            style: typography.display.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          AppLocalizations.of(context)!.languageSubtitle,
          style: typography.subtitle.copyWith(
            color: AppThemeColors.of(context).textMuted,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLanguageItem(
    LanguageOption language,
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
  ) {
    final isSelected = _selectedLanguage == language.code;

    return InkWell(
      onTap: () => _selectLanguage(language.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(spacing.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pastelAqua.withValues(alpha: 0.15)
              : AppThemeColors.of(context)
                  .cardBackground
                  .withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: isSelected
                ? AppColors.pastelAqua.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pastelAqua.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              language.flag,
              style: TextStyle(fontSize: sizing.iconMd + 6),
            ),
            SizedBox(width: spacing.cardSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: typography.title.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.pastelAqua
                          : AppThemeColors.of(context).textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language.nativeName,
                    style: typography.subtitle.copyWith(
                      color: isSelected
                          ? AppColors.pastelAqua.withValues(alpha: 0.7)
                          : AppThemeColors.of(context).textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: sizing.iconMd,
              height: sizing.iconMd,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.pastelAqua : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.pastelAqua : AppColors.textDark,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check,
                      size: sizing.iconMd * 0.65,
                      color: const Color(0xFF0A0A12))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
  ) {
    return Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.pastelAqua.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.pastelAqua.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: sizing.iconMd,
            color: AppColors.pastelAqua,
          ),
          SizedBox(width: spacing.cardSpacing),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.languageInfoMessage,
              style: typography.subtitle.copyWith(
                color: AppThemeColors.of(context).textMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}
