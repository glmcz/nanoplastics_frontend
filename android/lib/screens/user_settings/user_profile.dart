import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../services/settings_manager.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../widgets/header_back_button.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _settingsManager = SettingsManager();

  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  bool _darkModeEnabled = true;
  bool _dataCollectionEnabled = false;
  bool _analyticsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _pushNotificationsEnabled = true;

  bool _hasChanges = false;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _displayNameController =
        TextEditingController(text: _settingsManager.displayName);
    _emailController = TextEditingController(text: _settingsManager.email);
    _bioController = TextEditingController(text: _settingsManager.bio);

    _darkModeEnabled = _settingsManager.darkModeEnabled;
    _dataCollectionEnabled = _settingsManager.dataCollectionEnabled;
    _analyticsEnabled = _settingsManager.analyticsEnabled;
    _emailNotificationsEnabled = _settingsManager.emailNotificationsEnabled;
    _pushNotificationsEnabled = _settingsManager.pushNotificationsEnabled;

    _displayNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) _saveSettings();
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    if (_hasChanges) {
      _saveSettingsSync();
    }
    _displayNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveSettingsSync() {
    _settingsManager.setDisplayName(_displayNameController.text);
    _settingsManager.setEmail(_emailController.text);
    _settingsManager.setBio(_bioController.text);
    _settingsManager.setDarkModeEnabled(_darkModeEnabled);
    _settingsManager.setDataCollectionEnabled(_dataCollectionEnabled);
    _settingsManager.setAnalyticsEnabled(_analyticsEnabled);
    _settingsManager.setEmailNotificationsEnabled(_emailNotificationsEnabled);
    _settingsManager.setPushNotificationsEnabled(_pushNotificationsEnabled);
  }

  Future<void> _saveSettings() async {
    if (!_hasChanges) return;

    await _settingsManager.setDisplayName(_displayNameController.text);
    await _settingsManager.setEmail(_emailController.text);
    await _settingsManager.setBio(_bioController.text);
    await _settingsManager.setDarkModeEnabled(_darkModeEnabled);
    await _settingsManager.setDataCollectionEnabled(_dataCollectionEnabled);
    await _settingsManager.setAnalyticsEnabled(_analyticsEnabled);
    await _settingsManager
        .setEmailNotificationsEnabled(_emailNotificationsEnabled);
    await _settingsManager
        .setPushNotificationsEnabled(_pushNotificationsEnabled);

    if (mounted) {
      setState(() => _hasChanges = false);
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
                  Icons.person,
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
          const SizedBox(height: AppConstants.space30),
          _buildAvatarSection(sizing, typography),
          const SizedBox(height: AppConstants.space30),
          _buildSectionTitle(AppLocalizations.of(context)!.profilePersonalInfo,
              AppColors.pastelMint, spacing, typography),
          const SizedBox(height: AppConstants.space16),
          _buildTextField(
            controller: _displayNameController,
            label: AppLocalizations.of(context)!.profileDisplayName,
            hint: AppLocalizations.of(context)!.profileDisplayNameHint,
            icon: Icons.person_outline,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
          ),
          const SizedBox(height: AppConstants.space16),
          _buildTextField(
            controller: _emailController,
            label: AppLocalizations.of(context)!.profileEmail,
            hint: AppLocalizations.of(context)!.profileEmailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
          ),
          const SizedBox(height: AppConstants.space16),
          _buildTextField(
            controller: _bioController,
            label: AppLocalizations.of(context)!.profileBio,
            hint: AppLocalizations.of(context)!.profileBioHint,
            icon: Icons.description_outlined,
            maxLines: 3,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
          ),
          const SizedBox(height: AppConstants.space30),
          _buildSectionTitle(AppLocalizations.of(context)!.profileAppearance,
              AppColors.pastelLavender, spacing, typography),
          const SizedBox(height: AppConstants.space16),
          _buildToggleItem(
            title: AppLocalizations.of(context)!.profileDarkMode,
            subtitle: AppLocalizations.of(context)!.profileDarkModeDesc,
            icon: Icons.dark_mode_outlined,
            value: _darkModeEnabled,
            color: AppColors.pastelLavender,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
                _hasChanges = true;
              });
              _scheduleAutoSave();
            },
          ),
          const SizedBox(height: AppConstants.space30),
          _buildSectionTitle(AppLocalizations.of(context)!.profileNotifications,
              AppColors.pastelAqua, spacing, typography),
          const SizedBox(height: AppConstants.space16),
          _buildToggleItem(
            title: AppLocalizations.of(context)!.profilePushNotifications,
            subtitle:
                AppLocalizations.of(context)!.profilePushNotificationsDesc,
            icon: Icons.notifications_outlined,
            value: _pushNotificationsEnabled,
            color: AppColors.pastelAqua,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onChanged: (value) {
              setState(() {
                _pushNotificationsEnabled = value;
                _hasChanges = true;
              });
              _scheduleAutoSave();
            },
          ),
          const SizedBox(height: AppConstants.space16),
          _buildDangerZone(spacing, sizing, typography),
          const SizedBox(height: AppConstants.space40),
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
            AppLocalizations.of(context)!.profileTitle,
            style: typography.display.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          AppLocalizations.of(context)!.profileSubtitle,
          style: typography.subtitle.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(AppSizing sizing, AppTypography typography) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Avatar selection logic
            },
            child: Container(
              width: sizing.avatarMd,
              height: sizing.avatarMd,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF141928),
                border: Border.all(
                  color: AppColors.pastelMint.withValues(alpha: 0.5),
                  width: sizing.borderMedium,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pastelMint.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: sizing.avatarIconSize,
                color: AppColors.pastelMint.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.space12),
          Text(
            AppLocalizations.of(context)!.profileChangeAvatar,
            style: typography.label.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, Color color, AppSpacing spacing, AppTypography typography) {
    return Row(
      children: [
        Container(
          width: spacing.xs,
          height: spacing.xl,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppConstants.space8),
        Text(
          title,
          style: typography.title.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.pastelMint.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: sizing.iconSm, color: AppColors.pastelMint),
              const SizedBox(width: AppConstants.space8),
              Text(
                label,
                style: typography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space12),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: typography.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: typography.body.copyWith(
                color: AppColors.textDark,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0A12).withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.space16,
                  vertical: AppConstants.space12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Color color,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(spacing.sm),
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
            child: Icon(icon, size: sizing.iconSm, color: color),
          ),
          const SizedBox(width: AppConstants.space16),
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
                const SizedBox(height: AppConstants.space4),
                Text(
                  subtitle,
                  style: typography.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
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

  Widget _buildDangerZone(
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Danger Zone',
          AppColors.neonCrimson,
          spacing,
          typography,
        ),
        const SizedBox(height: AppConstants.space16),
        Container(
          padding: EdgeInsets.all(spacing.cardPadding),
          decoration: BoxDecoration(
            color: const Color(0xFF141928).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            border:
                Border.all(color: AppColors.neonCrimson.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _buildDangerButton(
                title: 'Reset Settings',
                subtitle: 'Reset all settings to default values',
                icon: Icons.refresh,
                spacing: spacing,
                sizing: sizing,
                typography: typography,
                onTap: _showResetConfirmation,
              ),
              const SizedBox(height: AppConstants.space16),
              _buildDangerButton(
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                icon: Icons.delete_forever,
                spacing: spacing,
                sizing: sizing,
                typography: typography,
                onTap: _showDeleteConfirmation,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: AppColors.neonCrimson.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border:
              Border.all(color: AppColors.neonCrimson.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: sizing.iconSm, color: AppColors.neonCrimson),
            const SizedBox(width: AppConstants.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.title.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neonCrimson,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space4),
                  Text(
                    subtitle,
                    style: typography.bodySm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: sizing.arrowSize,
              color: AppColors.neonCrimson.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141928),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL)),
        title: const Text(
          'Reset Settings?',
          style: TextStyle(
              color: AppColors.neonCrimson, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will reset all settings to their default values. This action cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              await _settingsManager.resetToDefaults();
              if (mounted) {
                Navigator.pop(context);
                _loadSettings();
                setState(() {});
              }
            },
            child: const Text('Reset',
                style: TextStyle(color: AppColors.neonCrimson)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141928),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL)),
        title: const Text(
          'Delete Account?',
          style: TextStyle(
              color: AppColors.neonCrimson, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete account logic would go here
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.neonCrimson)),
          ),
        ],
      ),
    );
  }
}
