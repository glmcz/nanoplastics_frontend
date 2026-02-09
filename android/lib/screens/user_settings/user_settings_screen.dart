import 'package:flutter/material.dart';
import 'dart:ui';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/responsive_config.dart';
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
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final header = responsive.getSecondaryHeaderConfig();

    return Container(
      padding: EdgeInsets.all(header.padding),
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
                  size: header.iconSize,
                  color: AppColors.pastelMint,
                ),
              ],
            ),
            SizedBox(height: header.spacing),
            NanosolveLogo(height: header.logoHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getSettingsScreenConfig();

    return SingleChildScrollView(
      padding: EdgeInsets.all(config.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(config),
          SizedBox(height: config.cardSpacing * 2),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.settingsProfile,
            icon: Icons.person_outline,
            color: AppColors.pastelMint,
            config: config,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            ),
          ),
          SizedBox(height: config.cardSpacing),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.settingsLanguage,
            icon: Icons.language,
            color: AppColors.pastelAqua,
            config: config,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LanguageScreen()),
            ),
          ),
          SizedBox(height: config.cardSpacing),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.settingsPrivacySecurity,
            icon: Icons.lock_outline,
            color: AppColors.pastelMint,
            config: config,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
            ),
          ),
          SizedBox(height: config.cardSpacing),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.settingsAbout,
            icon: Icons.info_outline,
            color: AppColors.pastelLavender,
            config: config,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
          SizedBox(height: config.cardSpacing),
        ],
      ),
    );
  }

  Widget _buildTitleSection(SettingsScreenConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelMint, AppColors.pastelAqua],
          ).createShader(bounds),
          child: Text(
            AppLocalizations.of(context)!.settingsTitle,
            style: config.titleStyle?.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          AppLocalizations.of(context)!.settingsSubtitle,
          style: config.subtitleStyle,
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
    required SettingsScreenConfig config,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(config.cardPadding),
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
              width: config.iconContainerSize,
              height: config.iconContainerSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                icon,
                size: config.iconSize,
                color: color,
              ),
            ),
            SizedBox(width: config.cardSpacing),
            Expanded(
              child: Text(
                title,
                style: config.cardTitleStyle?.copyWith(
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: config.arrowSize,
              color: color.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
