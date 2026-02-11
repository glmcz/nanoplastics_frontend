import 'package:flutter/material.dart';
import 'dart:ui';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../services/settings_manager.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../widgets/header_back_button.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final _settingsManager = SettingsManager();

  bool _analyticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _analyticsEnabled = _settingsManager.analyticsEnabled;
  }

  Future<void> _updateAnalytics(bool value) async {
    setState(() => _analyticsEnabled = value);
    await _settingsManager.setAnalyticsEnabled(value);
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
              AppColors.pastelMint.withValues(alpha: 0.05),
              AppColors.pastelLavender.withValues(alpha: 0.05),
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
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);

    return Container(
      padding: EdgeInsets.all(spacing.headerPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeaderBackButton(
                  label: AppLocalizations.of(context)!.settingsBack,
                  color: AppColors.pastelMint,
                ),
                Icon(Icons.lock_outline,
                    size: sizing.iconMd, color: AppColors.pastelMint),
              ],
            ),
            SizedBox(height: spacing.headerSpacing),
            NanosolveLogo(height: sizing.logoHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    final contentPad = spacing.contentPadding;
    final cardPad = spacing.cardPadding;
    final cardSpace = spacing.cardSpacing;
    final iconContainer = sizing.iconContainer;
    final iconSz = sizing.iconMd;
    final arrowSz = sizing.arrowSize;
    final titleStyle = typography.display.copyWith(color: AppColors.textMain);
    final subtitleStyle =
        typography.subtitle.copyWith(color: AppColors.textMuted);
    final cardTitleStyle = typography.title.copyWith(color: AppColors.textMain);

    return SingleChildScrollView(
      padding: EdgeInsets.all(contentPad),
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
            onTap: () {
              // Open privacy policy
            },
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
            onTap: () {
              // Open terms of service
            },
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
            color: AppColors.textMuted,
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
        color: const Color(0xFF141928).withValues(alpha: 0.8),
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
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  subtitle,
                  style: subtitleStyle.copyWith(
                    color: AppColors.textMuted,
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
            inactiveTrackColor: const Color(0xFF0A0A12),
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
        color: const Color(0xFF141928).withValues(alpha: 0.8),
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
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  subtitle,
                  style: subtitleStyle.copyWith(
                    color: AppColors.textMuted,
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
          color: const Color(0xFF141928).withValues(alpha: 0.8),
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
                  color: Colors.white,
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
