import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/responsive_config.dart';
import '../../widgets/nanosolve_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(context),
              Expanded(child: _buildContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final header = responsive.getSecondaryHeaderConfig();

    return Container(
      padding: EdgeInsets.all(header.padding),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.settingsBack,
                    style: header.backStyle?.copyWith(
                      color: AppColors.pastelLavender,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Icon(Icons.info_outline,
                    size: header.iconSize, color: AppColors.pastelLavender),
              ],
            ),
            SizedBox(height: header.spacing),
            NanosolveLogo(height: header.logoHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getSettingsScreenConfig();

    return SingleChildScrollView(
      padding: EdgeInsets.all(config.contentPadding),
      child: Column(
        children: [
          _buildAppInfo(context, config),
          SizedBox(height: config.cardSpacing * 2),
          _buildSectionTitle(
              context, AppLocalizations.of(context)!.aboutSection, config),
          SizedBox(height: config.cardSpacing),
          _buildDescriptionCard(context, config),
          SizedBox(height: config.cardSpacing * 2),
          _buildSectionTitle(
              context, AppLocalizations.of(context)!.aboutConnect, config),
          SizedBox(height: config.cardSpacing),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.aboutWebsite,
            subtitle: AppLocalizations.of(context)!.aboutWebsiteUrl,
            icon: Icons.language,
            color: AppColors.pastelAqua,
            config: config,
            onTap: () => _launchUrl('https://nanosolve.io'),
          ),
          SizedBox(height: config.cardSpacing),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.aboutContactUs,
            subtitle: AppLocalizations.of(context)!.aboutContactUsDesc,
            icon: Icons.email_outlined,
            color: AppColors.pastelMint,
            config: config,
            onTap: () => _launchUrl('mailto:contact@nanosolve.io'),
          ),
          SizedBox(height: config.cardSpacing * 2),
          _buildSectionTitle(
              context, AppLocalizations.of(context)!.aboutShare, config),
          SizedBox(height: config.cardSpacing),
          _buildShareCard(context, config),
          SizedBox(height: config.cardSpacing * 2),
          _buildFooter(context, config),
  
          SizedBox(height: config.cardSpacing * 2),
          _buildSectionTitle(
              context, AppLocalizations.of(context)!.aboutLegal, config),
          SizedBox(height: config.cardSpacing),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.aboutPrivacyPolicy,
            subtitle: AppLocalizations.of(context)!.aboutPrivacyPolicyDesc,
            icon: Icons.policy_outlined,
            color: AppColors.pastelLavender,
            config: config,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          SizedBox(height: config.cardSpacing),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.aboutTermsOfService,
            subtitle: AppLocalizations.of(context)!.aboutTermsOfServiceDesc,
            icon: Icons.description_outlined,
            color: AppColors.pastelLavender,
            config: config,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
            ),
          ),
          SizedBox(height: config.cardSpacing * 2),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.aboutOpenSourceLicenses,
            subtitle: AppLocalizations.of(context)!.aboutOpenSourceLicensesDesc,
            icon: Icons.code,
            color: AppColors.pastelAqua,
            config: config,
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

  Widget _buildAppInfo(BuildContext context, SettingsScreenConfig config) {
    return Column(
      children: [
        Container(
          width: config.iconContainerSize * 2,
          height: config.iconContainerSize * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF141928),
            border: Border.all(
              color: AppColors.pastelLavender.withValues(alpha: 0.5),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pastelLavender.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: NanosolveLogo(height: config.iconContainerSize),
          ),
        ),
        SizedBox(height: config.cardSpacing),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelAqua, AppColors.pastelMint],
          ).createShader(bounds),
          child: Text(
            AppLocalizations.of(context)!.aboutAppName,
            style: config.titleStyle?.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          '${AppLocalizations.of(context)!.aboutVersion} $appVersion ($buildNumber)',
          style: config.subtitleStyle?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, SettingsScreenConfig config) {
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
            style: config.cardTitleStyle?.copyWith(
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
      BuildContext context, SettingsScreenConfig config) {
    return Container(
      padding: EdgeInsets.all(config.cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border:
            Border.all(color: AppColors.pastelLavender.withValues(alpha: 0.2)),
      ),
      child: Text(
        AppLocalizations.of(context)!.aboutDescription,
        style: config.subtitleStyle?.copyWith(
          color: AppColors.textMuted,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildLinkItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required SettingsScreenConfig config,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(config.cardPadding),
        decoration: BoxDecoration(
          color: const Color(0xFF141928).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: config.iconContainerSize,
              height: config.iconContainerSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(icon, size: config.iconSize, color: color),
            ),
            SizedBox(width: config.cardSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: config.cardTitleStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: config.subtitleStyle
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: config.arrowSize, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildShareCard(BuildContext context, SettingsScreenConfig config) {
    const String appDownloadUrl = 'https://nanosolve.io/download';

    return Container(
      padding: EdgeInsets.all(config.cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.pastelAqua.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.pastelAqua.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.aboutShareTitle,
            style: config.cardTitleStyle?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.pastelAqua,
              fontSize: (config.cardTitleStyle?.fontSize ?? 16) + 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.space16),
          Text(
            AppLocalizations.of(context)!.aboutShareDesc,
            style: config.subtitleStyle?.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.space24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pastelAqua.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Placeholder for QR code - will be replaced with actual QR code widget
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          size: 80,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'QR Code',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            appDownloadUrl,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
                    size: 18,
                    color: AppColors.pastelAqua,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.aboutShareAppLink,
                    style: config.subtitleStyle?.copyWith(
                      color: AppColors.pastelAqua,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 14,
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

  Widget _buildFooter(BuildContext context, SettingsScreenConfig config) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.aboutFooterMessage,
          style: config.subtitleStyle?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.aboutCopyright,
          style: config.subtitleStyle?.copyWith(
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    debugPrint('🔗 [URLLauncher] Launching URL: $url');
    try {
      final uri = Uri.parse(url);
      debugPrint('🔗 [URLLauncher] Parsed URI: $uri');
      debugPrint(
          '🔗 [URLLauncher] Attempting to launch in external application...');

      if (await canLaunchUrl(uri)) {
        debugPrint('🔗 [URLLauncher] URL is launchable');
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('🔗 [URLLauncher] URL launched successfully');
      } else {
        debugPrint('❌ [URLLauncher] Cannot launch URL: $url');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [URLLauncher] Error launching $url: $e');
      debugPrint('❌ [URLLauncher] Stack trace: $stackTrace');
    }
  }
}
