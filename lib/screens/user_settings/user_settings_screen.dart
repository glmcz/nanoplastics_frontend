import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../widgets/glowing_header_separator.dart';
import '../../services/settings_manager.dart';
import '../../services/update_service.dart';
import '../../services/service_locator.dart';
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
  late SettingsManager _settingsManager;

  @override
  void initState() {
    super.initState();
    _settingsManager = ServiceLocator().settingsManager;
  }

  bool _checkProfileCompletion() {
    // Check if email and display name are filled
    try {
      final email = _settingsManager.email;
      final displayName = _settingsManager.displayName;
      final hasEmail = email.isNotEmpty;
      final hasDisplayName = displayName.isNotEmpty;
      return hasEmail && hasDisplayName;
    } catch (e) {
      return false;
    }
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
      padding: EdgeInsets.only(
        top: spacing.contentPaddingV,
        bottom: spacing.contentPaddingV,
        left: spacing.contentPaddingH,
        right: spacing.contentPaddingH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: sizing.backIcon,
                        ),
                        const SizedBox(width: AppConstants.space4),
                        Flexible(
                          child: Text(
                            l10n.categoryDetailBackToOverview,
                            style:
                                typography.back.copyWith(color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Settings wheel icon for version check
                InkWell(
                  onTap: _checkVersionAndShowDialog,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.hubKnobBg.withValues(alpha: 0.3),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: sizing.hubKnobIconSize,
                    ),
                  ),
                ),
              ],
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
        vertical: spacing.contentPaddingV * 7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(typography),
          SizedBox(height: spacing.cardSpacing),
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
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const LanguageScreen())),
          ),
          SizedBox(height: spacing.cardSpacing),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.settingsPrivacySecurity,
            icon: Icons.lock_outline,
            color: AppColors.pastelMint,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PrivacySecurityScreen(),
                ),
              );
            },
          ),
          SizedBox(height: spacing.cardSpacing),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.settingsAbout,
            icon: Icons.info_outline,
            color: AppColors.pastelLavender,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
          SizedBox(height: spacing.cardSpacing),
          _buildSettingItem(
            title: 'Multi language app switch',
            icon: Icons.build_circle,
            subtitle: '${_settingsManager.buildType} build',
            color: AppColors.pastelAqua,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () {
              // TODO: Implement build type switcher
              // This will allow users to switch between FULL and LITE builds
              // by changing their build type identifier and downloading/deleting PDFs accordingly
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Multi language switcher - Coming soon!'),
                  backgroundColor: AppColors.pastelAqua.withValues(alpha: 0.9),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                  ),
                ),
              );
            },
          ),
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
    String? subtitle,
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
              child: Icon(icon, size: sizing.iconMd, color: color),
            ),
            SizedBox(width: spacing.cardSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.title.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle,
                        style: typography.bodySm.copyWith(
                          color: Colors.white54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
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

  Future<void> _checkVersionAndShowDialog() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A24),
          content: Row(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Checking for updates...',
                  style: AppTypography.of(
                    context,
                  ).body.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final updateService = UpdateService();
      final updateAvailable = await updateService.checkForUpdates(force: true);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (updateAvailable) {
          _showUpdateAvailableDialog();
        } else {
          _showAppIsCurrentDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorDialog('Failed to check for updates: $e');
      }
    }
  }

  void _showAppIsCurrentDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        title: Text(
          'App is Up to Date',
          style: AppTypography.of(context).title.copyWith(color: Colors.white),
        ),
        content: Text(
          'You are using the latest version of NanoSolve Hive.',
          style: AppTypography.of(
            context,
          ).body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showUpdateAvailableDialog() {
    final latestVersion = _settingsManager.latestVersion ?? 'unknown';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        title: Text(
          'Update Available',
          style: AppTypography.of(context).title.copyWith(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version ($latestVersion) is available.',
              style: AppTypography.of(
                context,
              ).body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 16),
            Text(
              'Update now to get the latest features and improvements.',
              style: AppTypography.of(context).body.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Later',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: _startUpdateProcess,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCrimson,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        title: Text(
          'Error',
          style: AppTypography.of(context).title.copyWith(color: Colors.white),
        ),
        content: Text(
          message,
          style: AppTypography.of(
            context,
          ).body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _startUpdateProcess() async {
    Navigator.of(context).pop();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A24),
          content: Row(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Starting update...',
                  style: AppTypography.of(
                    context,
                  ).body.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final updateService = UpdateService();
      final success = await updateService.startUpdate();

      if (mounted) {
        Navigator.of(context).pop();

        if (!success) {
          _showErrorDialog(
            'Failed to start the update process. Please try again later or download manually.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorDialog('An unexpected error occurred: $e');
      }
    }
  }
}
