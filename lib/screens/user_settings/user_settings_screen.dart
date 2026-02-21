import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../widgets/glowing_header_separator.dart';
import '../../utils/app_theme_colors.dart';
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

class _UserSettingsScreenState extends State<UserSettingsScreen>
    with WidgetsBindingObserver {
  late SettingsManager _settingsManager;
  bool _waitingForInstall = false;

  @override
  void initState() {
    super.initState();
    _settingsManager = ServiceLocator().settingsManager;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForInstall) {
      _checkInstallationResult();
    }
  }

  Future<void> _checkInstallationResult() async {
    final updateService = UpdateService();
    final installed = await updateService.checkInstallationComplete();

    if (!mounted) return;

    _waitingForInstall = false;

    if (installed) {
      _showInstallationSuccessDialog();
    } else {
      _showInstallationCancelledDialog();
    }
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
                          color: AppThemeColors.of(context).textMain,
                          size: sizing.backIcon,
                        ),
                        const SizedBox(width: AppConstants.space4),
                        Flexible(
                          child: Text(
                            l10n.categoryDetailBackToOverview,
                            style: typography.back.copyWith(
                                color: AppThemeColors.of(context).textMain),
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
                      color: AppThemeColors.of(context).textMain,
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
          color:
              AppThemeColors.of(context).cardBackground.withValues(alpha: 0.8),
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
                    style: typography.title
                        .copyWith(color: AppThemeColors.of(context).textMain),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle,
                        style: typography.bodySm.copyWith(
                          color: AppThemeColors.of(context).textDark,
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
          backgroundColor: AppThemeColors.of(context).dialogBackground,
          content: Row(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.updateCheckingForUpdates,
                  style: AppTypography.of(
                    context,
                  ).body.copyWith(color: AppThemeColors.of(context).textMain),
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
        } else if (updateService.currentState == UpdateState.failed) {
          // Network error or GitHub API unreachable — not "up to date"
          _showErrorDialog(
            AppLocalizations.of(context)!.updateFailedToCheck,
          );
        } else {
          _showAppIsCurrentDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorDialog(
          '${AppLocalizations.of(context)!.updateFailedToCheck}: $e',
        );
      }
    }
  }

  void _showAppIsCurrentDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeColors.of(context).dialogBackground,
        title: Text(
          AppLocalizations.of(context)!.updateAppUpToDateTitle,
          style: AppTypography.of(context)
              .title
              .copyWith(color: AppThemeColors.of(context).textMain),
        ),
        content: Text(
          AppLocalizations.of(context)!.updateAppUpToDateMsg,
          style: AppTypography.of(
            context,
          ).body.copyWith(
              color:
                  AppThemeColors.of(context).textMain.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.updateButtonOk),
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
        backgroundColor: AppThemeColors.of(context).dialogBackground,
        title: Text(
          AppLocalizations.of(context)!.updateAvailableTitle,
          style: AppTypography.of(context)
              .title
              .copyWith(color: AppThemeColors.of(context).textMain),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.updateAvailableMsg}\n($latestVersion)',
              style: AppTypography.of(
                context,
              ).body.copyWith(
                  color: AppThemeColors.of(context)
                      .textMain
                      .withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.updateDownloadInstructions,
              style: AppTypography.of(context).body.copyWith(
                    color: AppThemeColors.of(context).textMuted,
                    fontSize: 13,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.updateButtonLater,
              style: TextStyle(color: AppThemeColors.of(context).textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: _startUpdateProcess,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCrimson,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.updateButtonUpdateNow),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeColors.of(context).dialogBackground,
        title: Text(
          AppLocalizations.of(context)!.updateError,
          style: AppTypography.of(context)
              .title
              .copyWith(color: AppThemeColors.of(context).textMain),
        ),
        content: Text(
          message,
          style: AppTypography.of(
            context,
          ).body.copyWith(
              color:
                  AppThemeColors.of(context).textMain.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.updateButtonOk),
          ),
        ],
      ),
    );
  }

  void _showInstallationSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeColors.of(context).dialogBackground,
        title: Text(
          AppLocalizations.of(context)!.updateInstallationSuccessTitle,
          style: AppTypography.of(context).title.copyWith(
                color: AppThemeColors.of(context).textMain,
              ),
        ),
        content: Text(
          AppLocalizations.of(context)!.updateInstallationSuccessMsg,
          style: AppTypography.of(context).body.copyWith(
                color:
                    AppThemeColors.of(context).textMain.withValues(alpha: 0.8),
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.updateButtonOk),
          ),
        ],
      ),
    );
  }

  void _showInstallationCancelledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeColors.of(context).dialogBackground,
        title: Text(
          AppLocalizations.of(context)!.updateInstallationCancelledTitle,
          style: AppTypography.of(context).title.copyWith(
                color: AppThemeColors.of(context).textMain,
              ),
        ),
        content: Text(
          AppLocalizations.of(context)!.updateInstallationCancelledMsg,
          style: AppTypography.of(context).body.copyWith(
                color:
                    AppThemeColors.of(context).textMain.withValues(alpha: 0.8),
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.updateButtonLater),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retryInstallation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.updateButtonRetryInstall),
          ),
        ],
      ),
    );
  }

  Future<void> _retryInstallation() async {
    final updateService = UpdateService();
    final success = await updateService.retryInstallation();

    if (!mounted) return;

    if (success) {
      _waitingForInstall = true;
    } else {
      _showErrorDialog(
        'No downloaded APK found. Please download the update again.',
      );
    }
  }

  Future<void> _startUpdateProcess() async {
    Navigator.of(context).pop();
    final updateService = UpdateService();
    Function(UpdateState, double)? stateListener;

    // Show download progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          // Remove listener when dialog is dismissed
          if (stateListener != null) {
            updateService.removeStateListener(stateListener!);
          }
        },
        child: StatefulBuilder(
          builder: (context, setState) {
            // Add listener only once
            if (stateListener == null) {
              stateListener = (state, progress) {
                if (mounted) {
                  setState(() {});
                }
              };
              updateService.addStateListener(stateListener!);
            }

            String statusText = 'Starting update...';
            if (updateService.currentState.name == 'downloading') {
              final percent =
                  (updateService.downloadProgress * 100).toStringAsFixed(1);
              statusText = 'Downloading APK... $percent%';
            } else if (updateService.currentState.name == 'downloaded') {
              statusText = 'Launching installer...';
            } else if (updateService.currentState.name == 'installing') {
              statusText = 'Opening installer...';
            }

            return AlertDialog(
              backgroundColor: AppThemeColors.of(context).dialogBackground,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusText,
                    style: AppTypography.of(context)
                        .body
                        .copyWith(color: AppThemeColors.of(context).textMain),
                  ),
                  const SizedBox(height: 8),
                  if (updateService.currentState.name == 'downloading')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: updateService.downloadProgress,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.neonCyan,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  if (updateService.currentState.name == 'downloading')
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              if (updateService.isPaused) {
                                updateService.resumeDownload();
                              } else {
                                updateService.pauseDownload();
                              }
                              setState(() {});
                            },
                            icon: Icon(updateService.isPaused
                                ? Icons.play_arrow
                                : Icons.pause),
                            label: Text(
                              updateService.isPaused ? 'Resume' : 'Pause',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              updateService.cancelDownload();
                              if (stateListener != null) {
                                updateService
                                    .removeStateListener(stateListener!);
                              }
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonCrimson,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );

    try {
      final success = await updateService.startUpdate();

      if (mounted) {
        Navigator.of(context).pop();

        if (!success) {
          _showErrorDialog(
            'Failed to start the update process. Please try again later or download manually.',
          );
        } else {
          _waitingForInstall = true;
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
