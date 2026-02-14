import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../widgets/nanosolve_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

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
              AppColors.pastelLavender.withValues(alpha: 0.05),
              AppColors.pastelAqua.withValues(alpha: 0.05),
              const Color(0xFF0A0A12),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, spacing, sizing, l10n, typography),
              Expanded(
                  child: _buildContent(context, spacing, sizing, typography)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(context, spacing, sizing, l10n, typography) {
    return Padding(
      padding: EdgeInsets.all(spacing.contentPadding),
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

  Widget _buildContent(
    BuildContext context,
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.contentPadding),
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
            onTap: () => _launchUrl('https://nanosolve.io'),
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
            onTap: () => _launchUrl('mailto:contact@nanosolve.io'),
          ),
          SizedBox(height: spacing.cardSpacing * 2),
          _buildSectionTitle(
              context, AppLocalizations.of(context)!.aboutShare, typography),
          SizedBox(height: spacing.cardSpacing),
          _buildShareCard(context, spacing, sizing, typography),
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
              applicationVersion: 'v$appVersion ($buildNumber)',
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
            color: const Color(0xFF141928),
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
          '${AppLocalizations.of(context)!.aboutVersion} $appVersion ($buildNumber)',
          style: typography.subtitle.copyWith(
            color: AppColors.textMuted,
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
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border:
            Border.all(color: AppColors.pastelLavender.withValues(alpha: 0.2)),
      ),
      child: Text(
        AppLocalizations.of(context)!.aboutDescription,
        style: typography.subtitle.copyWith(
          color: AppColors.textMuted,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(spacing.cardPadding),
        decoration: BoxDecoration(
          color: const Color(0xFF141928).withValues(alpha: 0.8),
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: typography.subtitle
                        .copyWith(color: AppColors.textMuted),
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
  ) {
    const String appDownloadUrl = 'https://nanosolve.io/download';

    return Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
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
            AppLocalizations.of(context)!.aboutShareTitle,
            style: typography.title.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.pastelAqua,
              fontSize: (typography.title.fontSize ?? 16) + 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.space16),
          Text(
            AppLocalizations.of(context)!.aboutShareDesc,
            style: typography.subtitle.copyWith(
              color: AppColors.textMuted,
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
          GestureDetector(
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
                      AppLocalizations.of(context)!.aboutShareAppLink,
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
            color: AppColors.textMuted,
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
    debugPrint('🔗 [CustomTabs] Launching URL: $url');
    try {
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
        Uri.parse(url),
        customTabsOptions: theme,
        safariVCOptions: const SafariViewControllerOptions(
          preferredBarTintColor: AppColors.pastelLavender,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
      debugPrint('🔗 [CustomTabs] URL launched successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ [CustomTabs] Error launching $url: $e');
      debugPrint('❌ [CustomTabs] Stack trace: $stackTrace');
    }
  }
}
