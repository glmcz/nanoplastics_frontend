import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../services/settings_manager.dart';
import '../../utils/pdf_utils.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../main.dart';
import '../pdf_viewer_screen.dart';

class LanguageScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;

  const LanguageScreen({super.key, this.onLanguageChanged});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final _settingsManager = SettingsManager();
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
    _selectedLanguage = _settingsManager.userLanguage;
  }

  Future<void> _selectLanguage(String code) async {
    if (_selectedLanguage == code) return;

    setState(() => _selectedLanguage = code);
    await _settingsManager.setUserLanguage(code);

    // Download PDFs for non-EN languages in LITE build with progress
    if (code != 'en' && _settingsManager.buildType == 'LITE') {
      final success = await _downloadPDFForLanguageWithProgress(code);
      if (!success) {
        // Show offline fallback dialog
        if (mounted) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Language changed to ${_languages.firstWhere((l) => l.code == code).name}'),
          backgroundColor: AppColors.pastelAqua.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        ),
      );

      // After restart, navigate to PDF viewer for non-EN languages in LITE build
      if (code != 'en' && _settingsManager.buildType == 'LITE') {
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted) {
            final pdfPath = await resolveMainReport(code);
            if (pdfPath != null) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PDFViewerScreen(
                    title: _languages.firstWhere((l) => l.code == code).name,
                    startPage: 1,
                    endPage: 0,
                    description: 'Language report for ${_languages.firstWhere((l) => l.code == code).name}',
                    pdfAssetPath: pdfPath.isAsset ? pdfPath.path : null,
                  ),
                ),
              );
            }
          }
        });
      }
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Download with progress callback
      await downloadReport(
        langCode,
        onProgress: (progressValue) {
          // Update the dialog with progress
          if (mounted) {
            setState(() => progress = progressValue);
          }
        },
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
          style: const TextStyle(color: Colors.white70),
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
              AppColors.pastelAqua.withValues(alpha: 0.05),
              AppColors.pastelMint.withValues(alpha: 0.05),
              const Color(0xFF0A0A12),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildContent()),
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
                      color: Colors.white, size: sizing.backIcon),
                  const SizedBox(width: AppConstants.space4),
                  Flexible(
                    child: Text(
                      l10n.categoryDetailBackToOverview,
                      style: typography.back.copyWith(
                        color: Colors.white,
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
            color: AppColors.textMuted,
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

    return GestureDetector(
      onTap: () => _selectLanguage(language.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(spacing.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pastelAqua.withValues(alpha: 0.15)
              : const Color(0xFF141928).withValues(alpha: 0.8),
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
                      color: isSelected ? AppColors.pastelAqua : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language.nativeName,
                    style: typography.subtitle.copyWith(
                      color: isSelected
                          ? AppColors.pastelAqua.withValues(alpha: 0.7)
                          : AppColors.textMuted,
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
                color: AppColors.textMuted,
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
