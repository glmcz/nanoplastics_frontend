import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../services/settings_manager.dart';
import '../../services/service_locator.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../widgets/glowing_header_separator.dart';
import '../../utils/app_theme_colors.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  late SettingsManager _settingsManager;
  bool _analyticsEnabled = true;
  bool _updateNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _settingsManager = ServiceLocator().settingsManager;
    _loadSettings();
  }

  void _loadSettings() {
    _analyticsEnabled = _settingsManager.analyticsEnabled;
    _updateNotificationsEnabled = _settingsManager.pushNotificationsEnabled;
  }

  Future<void> _updateAnalytics(bool value) async {
    setState(() => _analyticsEnabled = value);
    await _settingsManager.setAnalyticsEnabled(value);
  }

  Future<void> _setUpdateNotifications(bool value) async {
    setState(() => _updateNotificationsEnabled = value);
    await _settingsManager.setPushNotificationsEnabled(value);
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
              AppColors.pastelMint
                  .withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppColors.pastelLavender
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
    final cardPad = spacing.cardPadding;
    final cardSpace = spacing.cardSpacing;
    final iconContainer = sizing.iconContainer;
    final iconSz = sizing.iconMd;
    final arrowSz = sizing.arrowSize;
    final tc = AppThemeColors.of(context);
    final titleStyle = typography.display.copyWith(color: tc.textMain);
    final subtitleStyle = typography.subtitle.copyWith(color: tc.textMuted);
    final cardTitleStyle = typography.title.copyWith(color: tc.textMain);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,
          vertical: spacing.contentPaddingV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(titleStyle, subtitleStyle),
          SizedBox(height: cardSpace * 2),
          _buildSectionTitle(AppLocalizations.of(context)!.privacyDataAnalytics,
              AppColors.pastelMint, cardTitleStyle),
          SizedBox(height: cardSpace),
          _buildToggleItem(
            title: AppLocalizations.of(context)!.privacyAnalytics,
            subtitle: AppLocalizations.of(context)!.privacyAnalyticsDesc,
            icon: Icons.analytics_outlined,
            value: _analyticsEnabled,
            color: AppColors.pastelMint,
            cardPad: cardPad,
            iconContainer: iconContainer,
            iconSz: iconSz,
            cardSpace: cardSpace,
            cardTitleStyle: cardTitleStyle,
            subtitleStyle: subtitleStyle,
            onChanged: _updateAnalytics,
          ),
          SizedBox(height: cardSpace * 2),
          _buildSectionTitle(AppLocalizations.of(context)!.privacyNotifications,
              AppColors.pastelAqua, cardTitleStyle),
          SizedBox(height: cardSpace),
          _buildToggleItem(
            title: AppLocalizations.of(context)!.privacyUpdateNotifications,
            subtitle:
                AppLocalizations.of(context)!.privacyUpdateNotificationsDesc,
            icon: Icons.system_update_outlined,
            value: _updateNotificationsEnabled,
            color: AppColors.pastelAqua,
            cardPad: cardPad,
            iconContainer: iconContainer,
            iconSz: iconSz,
            cardSpace: cardSpace,
            cardTitleStyle: cardTitleStyle,
            subtitleStyle: subtitleStyle,
            onChanged: _setUpdateNotifications,
          ),
          SizedBox(height: cardSpace * 2),
          _buildSectionTitle(AppLocalizations.of(context)!.privacySecurity,
              AppColors.pastelLavender, cardTitleStyle),
          SizedBox(height: cardSpace),
          _buildInfoItem(
            title: AppLocalizations.of(context)!.privacyDataEncryption,
            subtitle: AppLocalizations.of(context)!.privacyDataEncryptionDesc,
            icon: Icons.enhanced_encryption_outlined,
            color: AppColors.pastelLavender,
            cardPad: cardPad,
            iconContainer: iconContainer,
            iconSz: iconSz,
            cardSpace: cardSpace,
            cardTitleStyle: cardTitleStyle,
            subtitleStyle: subtitleStyle,
          ),
          SizedBox(height: cardSpace),
          _buildInfoItem(
            title: AppLocalizations.of(context)!.privacyLocalStorage,
            subtitle: AppLocalizations.of(context)!.privacyLocalStorageDesc,
            icon: Icons.phone_android_outlined,
            color: AppColors.pastelLavender,
            cardPad: cardPad,
            iconContainer: iconContainer,
            iconSz: iconSz,
            cardSpace: cardSpace,
            cardTitleStyle: cardTitleStyle,
            subtitleStyle: subtitleStyle,
          ),
          SizedBox(height: cardSpace * 2),
          _buildSectionTitle(AppLocalizations.of(context)!.privacyLegal,
              AppColors.pastelAqua, cardTitleStyle),
          SizedBox(height: cardSpace),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.privacyPolicy,
            icon: Icons.policy_outlined,
            color: AppColors.pastelAqua,
            cardPad: cardPad,
            iconContainer: iconContainer,
            iconSz: iconSz,
            cardSpace: cardSpace,
            arrowSz: arrowSz,
            cardTitleStyle: cardTitleStyle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          SizedBox(height: cardSpace),
          _buildLinkItem(
            title: AppLocalizations.of(context)!.privacyTermsOfService,
            icon: Icons.description_outlined,
            color: AppColors.pastelAqua,
            cardPad: cardPad,
            iconContainer: iconContainer,
            iconSz: iconSz,
            cardSpace: cardSpace,
            arrowSz: arrowSz,
            cardTitleStyle: cardTitleStyle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
            ),
          ),
          SizedBox(height: cardSpace * 2),
        ],
      ),
    );
  }

  Widget _buildTitleSection(TextStyle titleStyle, TextStyle subtitleStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelMint, AppColors.pastelLavender],
          ).createShader(bounds),
          child: Text(
            AppLocalizations.of(context)!.privacyTitle,
            style: titleStyle.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          AppLocalizations.of(context)!.privacySubtitle,
          style: subtitleStyle.copyWith(
            color: AppThemeColors.of(context).textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      String title, Color color, TextStyle cardTitleStyle) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppConstants.space8),
        Text(
          title,
          style: cardTitleStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Color color,
    required double cardPad,
    required double iconContainer,
    required double iconSz,
    required double cardSpace,
    required TextStyle cardTitleStyle,
    required TextStyle subtitleStyle,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(cardPad),
      decoration: BoxDecoration(
        color: AppThemeColors.of(context).cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: iconContainer,
            height: iconContainer,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(icon, size: iconSz, color: color),
          ),
          SizedBox(width: cardSpace),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: cardTitleStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.of(context).textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  subtitle,
                  style: subtitleStyle.copyWith(
                    color: AppThemeColors.of(context).textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textDark,
            inactiveTrackColor: AppThemeColors.of(context).switchInactiveTrack,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double cardPad,
    required double iconContainer,
    required double iconSz,
    required double cardSpace,
    required TextStyle cardTitleStyle,
    required TextStyle subtitleStyle,
  }) {
    return Container(
      padding: EdgeInsets.all(cardPad),
      decoration: BoxDecoration(
        color: AppThemeColors.of(context).cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: iconContainer,
            height: iconContainer,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(icon, size: iconSz, color: color),
          ),
          SizedBox(width: cardSpace),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: cardTitleStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.of(context).textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  subtitle,
                  style: subtitleStyle.copyWith(
                    color: AppThemeColors.of(context).textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle,
              size: iconSz, color: color.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required String title,
    required IconData icon,
    required Color color,
    required double cardPad,
    required double iconContainer,
    required double iconSz,
    required double cardSpace,
    required double arrowSz,
    required TextStyle cardTitleStyle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(cardPad),
        decoration: BoxDecoration(
          color:
              AppThemeColors.of(context).cardBackground.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: iconContainer,
              height: iconContainer,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(icon, size: iconSz, color: color),
            ),
            SizedBox(width: cardSpace),
            Expanded(
              child: Text(
                title,
                style: cardTitleStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.of(context).textMain,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: arrowSz, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
