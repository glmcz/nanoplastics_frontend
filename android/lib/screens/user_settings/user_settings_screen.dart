import 'package:flutter/material.dart';
import 'dart:ui';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../widgets/header_back_button.dart';
import 'user_profile.dart';
import 'language_screen.dart';
import 'privacy_security_screen.dart';
import 'about_screen.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
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
              Expanded(
                child: _buildContent(),
              ),
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
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
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
                Icon(
                  Icons.settings,
                  size: sizing.iconMd,
                  color: AppColors.pastelMint,
                ),
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(typography),
          SizedBox(height: spacing.cardSpacing * 2),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.settingsProfile,
            icon: Icons.person_outline,
            color: AppColors.pastelMint,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            ),
          ),
          SizedBox(height: spacing.cardSpacing),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.settingsLanguage,
            icon: Icons.language,
            color: AppColors.pastelAqua,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LanguageScreen()),
            ),
          ),
          SizedBox(height: spacing.cardSpacing),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.settingsPrivacySecurity,
            icon: Icons.lock_outline,
            color: AppColors.pastelMint,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
            ),
          ),
          SizedBox(height: spacing.cardSpacing),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.settingsAbout,
            icon: Icons.info_outline,
            color: AppColors.pastelLavender,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
          SizedBox(height: spacing.cardSpacing),
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
            colors: [AppColors.pastelMint, AppColors.pastelAqua],
          ).createShader(bounds),
          child: Text(
            AppLocalizations.of(context)!.settingsTitle,
            style: typography.display.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          AppLocalizations.of(context)!.settingsSubtitle,
          style: typography.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    required Color color,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(spacing.cardPadding),
        decoration: BoxDecoration(
          color: const Color(0xFF141928).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: sizing.iconContainer,
              height: sizing.iconContainer,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                icon,
                size: sizing.iconMd,
                color: color,
              ),
            ),
            SizedBox(width: spacing.cardSpacing),
            Expanded(
              child: Text(
                title,
                style: typography.title.copyWith(
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: sizing.arrowSize,
              color: color.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
