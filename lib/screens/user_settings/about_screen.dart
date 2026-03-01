import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:qr_flutter/qr_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../widgets/glowing_header_separator.dart';
import '../../services/settings_manager.dart';
import '../../services/logger_service.dart';
import '../../utils/app_theme_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _selectedVariant = 'full'; // 'full' or 'lite'
  late String appVersion;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  void _loadVersionInfo() {
    // Load version from SettingsManager (persisted on app startup)
    final settingsManager = SettingsManager();
    setState(() {
      appVersion = settingsManager.currentAppVersion ?? '1.0.0';
    });
  }

  String _getDownloadUrl() {
    if (_selectedVariant == 'lite') {
      /// Have to be same as in CI flutter-release.yaml
      return 'https://github.com/glmcz/nanoplastics_frontend/releases/latest/download/nanoplastics_app_lite.apk';
    } else {
      return 'https://github.com/glmcz/nanoplastics_frontend/releases/latest/download/nanoplastics_app.apk';
    }
  }

  String _getVariantLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _selectedVariant == 'lite'
        ? l10n.aboutVariantLiteBuild
        : l10n.aboutVariantFullBuild;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelLavender
                  .withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppColors.pastelAqua
                  .withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppThemeColors.of(context).gradientEnd,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, spacing, sizing, l10n, typography),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child:
                          _buildContent(context, spacing, sizing, typography),
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

  Widget _buildHeader(context, spacing, sizing, l10n, typography) {
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

  Widget _buildContent(
    BuildContext context,
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,
          vertical: spacing.contentPaddingV),
      child: Column(
        children: [
          _buildAppInfo(context, spacing, sizing, typography),
          SizedBox(height: spacing.cardSpacing * 2),
          _buildSectionTitle(
              context, AppLocalizations.of(context)!.aboutSection, typography),
          SizedBox(height: spacing.cardSpacing),
          _buildDescriptionCard(context, spacing, typography),
          SizedBox(height: spacing.cardSpacing * 2),
          _buildSectionTitle(
              context, AppLocalizations.of(context)!.aboutConnect, typography),
          SizedBox(height: spacing.cardSpacing),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.aboutWebsite,
            subtitle: AppLocalizations.of(context)!.aboutWebsiteUrl,
            icon: Icons.language,
            color: AppColors.pastelAqua,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () =>
                _launchUrl('https://glmcz.github.io/nanoplastics_frontend/'),
          ),
          SizedBox(height: spacing.cardSpacing),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.aboutContactUs,
            subtitle: AppLocalizations.of(context)!.aboutContactUsDesc,
            icon: Icons.email_outlined,
            color: AppColors.pastelMint,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () async {
              const email = 'support@nanosolve.io';
              final Uri emailUri = Uri(scheme: 'mailto', path: email);
              bool launched = false;
              if (await url_launcher.canLaunchUrl(emailUri)) {
                launched = await url_launcher.launchUrl(
                  emailUri,
                  mode: url_launcher.LaunchMode.externalApplication,
                );
              }
              if (!launched && context.mounted) {
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppThemeColors.of(context).cardBackground,
                    title: Text(
                      'Contact Us',
                      style: typography.title
                          .copyWith(color: AppThemeColors.of(context).textMain),
                    ),
                    content: Text(
                      email,
                      style:
                          typography.body.copyWith(color: AppColors.pastelMint),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: email));
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('COPY',
                            style: TextStyle(color: AppColors.pastelMint)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('CLOSE',
                            style: TextStyle(
                                color: AppThemeColors.of(context).textMuted)),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          SizedBox(height: spacing.cardSpacing),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.aboutPrivacyPolicy,
            subtitle: AppLocalizations.of(context)!.aboutPrivacyPolicyDesc,
            icon: Icons.privacy_tip_outlined,
            color: AppColors.pastelMint,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () => _launchUrl(
                'https://glmcz.github.io/nanoplastics_frontend/privacy_policy.html'),
          ),
          SizedBox(height: spacing.cardSpacing * 2),
          _buildSectionTitle(
              context, AppLocalizations.of(context)!.aboutShare, typography),
          SizedBox(height: spacing.cardSpacing),
          _buildShareCard(context, spacing, sizing, typography, l10n),
          SizedBox(height: spacing.cardSpacing * 2),
          _buildFooter(context, spacing, typography),
          SizedBox(height: spacing.cardSpacing * 2),
          _buildSectionTitle(
              context, AppLocalizations.of(context)!.aboutLegal, typography),
          SizedBox(height: spacing.cardSpacing * 2),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.aboutOpenSourceLicenses,
            subtitle: AppLocalizations.of(context)!.aboutOpenSourceLicensesDesc,
            icon: Icons.code,
            color: AppColors.pastelAqua,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'NanoSolve Hive',
              applicationVersion: 'v$appVersion',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(
    BuildContext context,
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
  ) {
    return Column(
      children: [
        Container(
          width: sizing.iconContainer * 2,
          height: sizing.iconContainer * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppThemeColors.of(context).cardBackground,
            border: Border.all(
              color: AppColors.pastelLavender.withValues(alpha: 0.5),
              width: sizing.borderThick,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pastelLavender.withValues(alpha: 0.2),
                blurRadius: sizing.shadowBlur,
                spreadRadius: sizing.shadowSpread,
              ),
            ],
          ),
          child: Center(
            child: NanosolveLogo(height: sizing.iconContainer),
          ),
        ),
        SizedBox(height: spacing.cardSpacing),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelAqua, AppColors.pastelMint],
          ).createShader(bounds),
          child: Text(
            AppLocalizations.of(context)!.aboutAppName,
            style: typography.display.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          '${AppLocalizations.of(context)!.aboutVersion} $appVersion',
          style: typography.subtitle.copyWith(
            color: AppThemeColors.of(context).textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, AppTypography typography) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.pastelLavender,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppConstants.space8),
          Text(
            title,
            style: typography.title.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.pastelLavender,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(
    BuildContext context,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    return Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: AppThemeColors.of(context).cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border:
            Border.all(color: AppColors.pastelLavender.withValues(alpha: 0.2)),
      ),
      child: Text(
        AppLocalizations.of(context)!.aboutDescription,
        style: typography.subtitle.copyWith(
          color: AppThemeColors.of(context).textMuted,
          height: typography.body.height ?? 1.6,
        ),
      ),
    );
  }

  Widget _buildLinkItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(spacing.cardPadding),
        decoration: BoxDecoration(
          color:
              AppThemeColors.of(context).cardBackground.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: sizing.iconContainer,
              height: sizing.iconContainer,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(icon, size: sizing.iconMd, color: color),
            ),
            SizedBox(width: spacing.cardSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.title.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppThemeColors.of(context).textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: typography.subtitle
                        .copyWith(color: AppThemeColors.of(context).textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: sizing.arrowSize, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildShareCard(
    BuildContext context,
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
    AppLocalizations l10n,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final appDownloadUrl = _getDownloadUrl();

    return Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: AppThemeColors.of(context).cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.pastelAqua.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.pastelAqua.withValues(alpha: 0.1),
            blurRadius: sizing.shadowBlur,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.aboutShareTitle,
            style: typography.title.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.pastelAqua,
              fontSize: (typography.title.fontSize ?? 16) + 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.space16),
          // Variant selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVariantButton('full', l10n.aboutVariantFullBuild, spacing,
                  sizing, typography),
              SizedBox(width: spacing.cardSpacing),
              _buildVariantButton('lite', l10n.aboutVariantLiteBuild, spacing,
                  sizing, typography),
            ],
          ),
          const SizedBox(height: AppConstants.space16),
          Text(
            _getVariantLabel(context),
            style: typography.subtitle.copyWith(
              color: AppColors.pastelAqua,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.space16),
          Text(
            l10n.aboutShareDesc,
            style: typography.subtitle.copyWith(
              color: AppThemeColors.of(context).textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.space24),
          Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pastelAqua.withValues(alpha: 0.3),
                  blurRadius: sizing.shadowBlur * 0.7,
                  spreadRadius: sizing.shadowSpread,
                ),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: appDownloadUrl,
                  version: QrVersions.auto,
                  size: sizing.qrCodeSize,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0A0A12),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0A0A12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.space16),
          InkWell(
            onTap: () => _launchUrl(appDownloadUrl),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.space16,
                vertical: AppConstants.space12,
              ),
              decoration: BoxDecoration(
                color: AppColors.pastelAqua.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(
                  color: AppColors.pastelAqua.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link,
                    size: sizing.linkIconSize,
                    color: AppColors.pastelAqua,
                  ),
                  SizedBox(width: spacing.sm),
                  Flexible(
                    child: Text(
                      l10n.aboutShareAppLink,
                      style: typography.subtitle.copyWith(
                        color: AppColors.pastelAqua,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.xs),
                  Icon(
                    Icons.open_in_new,
                    size: sizing.secondaryIconSize,
                    color: AppColors.pastelAqua.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantButton(
    String variantKey,
    String label,
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
  ) {
    final isSelected = _selectedVariant == variantKey;
    return InkWell(
      onTap: () => setState(() => _selectedVariant = variantKey),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.space12,
          vertical: AppConstants.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pastelAqua.withValues(alpha: 0.3)
              : AppColors.pastelAqua.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color:
                AppColors.pastelAqua.withValues(alpha: isSelected ? 0.6 : 0.3),
          ),
        ),
        child: Text(
          label,
          style: typography.subtitle.copyWith(
            color: AppColors.pastelAqua,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.aboutFooterMessage,
          style: typography.subtitle.copyWith(
            color: AppThemeColors.of(context).textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.aboutCopyright,
          style: typography.subtitle.copyWith(
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    try {
      // Try custom tabs first (Android)
      final theme = CustomTabsOptions(
        colorSchemes: CustomTabsColorSchemes.defaults(
          toolbarColor: AppColors.pastelLavender,
        ),
        shareState: CustomTabsShareState.on,
        urlBarHidingEnabled: true,
        showTitle: true,
        browser: const CustomTabsBrowserConfiguration(
          fallbackCustomTabs: [
            'com.android.chrome',
            'com.chrome.beta',
            'com.chrome.dev',
          ],
        ),
      );

      await launchUrl(
        uri,
        customTabsOptions: theme,
        safariVCOptions: const SafariViewControllerOptions(
          preferredBarTintColor: AppColors.pastelLavender,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e, stackTrace) {
      LoggerService()
          .logError('CustomTabs launch failed', '$url: $e', stackTrace);

      // Fallback to url_launcher's externalApplication mode
      try {
        final bool launched = await url_launcher.launchUrl(
          uri,
          mode: url_launcher.LaunchMode.externalApplication,
        );
        if (!launched) {
          LoggerService()
              .logError('URL launch fallback failed', url, StackTrace.current);
        }
      } catch (fallbackError, fallbackStack) {
        LoggerService().logError('URL launch fallback error',
            fallbackError.toString(), fallbackStack);
      }
    }
  }
}
