import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/responsive_config.dart';
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
                  Icons.person,
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
          const SizedBox(height: AppConstants.space30),
          _buildAvatarSection(config),
          const SizedBox(height: AppConstants.space30),
          _buildSectionTitle(AppLocalizations.of(context)!.profilePersonalInfo,
              AppColors.pastelMint, config),
          const SizedBox(height: AppConstants.space16),
          _buildTextField(
            controller: _displayNameController,
            label: AppLocalizations.of(context)!.profileDisplayName,
            hint: AppLocalizations.of(context)!.profileDisplayNameHint,
            icon: Icons.person_outline,
            config: config,
          ),
          const SizedBox(height: AppConstants.space16),
          _buildTextField(
            controller: _emailController,
            label: AppLocalizations.of(context)!.profileEmail,
            hint: AppLocalizations.of(context)!.profileEmailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            config: config,
          ),
          const SizedBox(height: AppConstants.space16),
          _buildTextField(
            controller: _bioController,
            label: AppLocalizations.of(context)!.profileBio,
            hint: AppLocalizations.of(context)!.profileBioHint,
            icon: Icons.description_outlined,
            maxLines: 3,
            config: config,
          ),
          const SizedBox(height: AppConstants.space30),
          _buildSectionTitle(AppLocalizations.of(context)!.profileAppearance,
              AppColors.pastelLavender, config),
          const SizedBox(height: AppConstants.space16),
          _buildToggleItem(
            title: AppLocalizations.of(context)!.profileDarkMode,
            subtitle: AppLocalizations.of(context)!.profileDarkModeDesc,
            icon: Icons.dark_mode_outlined,
            value: _darkModeEnabled,
            color: AppColors.pastelLavender,
            config: config,
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
              AppColors.pastelAqua, config),
          const SizedBox(height: AppConstants.space16),
          _buildToggleItem(
            title: AppLocalizations.of(context)!.profilePushNotifications,
            subtitle:
                AppLocalizations.of(context)!.profilePushNotificationsDesc,
            icon: Icons.notifications_outlined,
            value: _pushNotificationsEnabled,
            color: AppColors.pastelAqua,
            config: config,
            onChanged: (value) {
              setState(() {
                _pushNotificationsEnabled = value;
                _hasChanges = true;
              });
              _scheduleAutoSave();
            },
          ),
          const SizedBox(height: AppConstants.space16),
          _buildDangerZone(config),
          const SizedBox(height: AppConstants.space40),
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
            AppLocalizations.of(context)!.profileTitle,
            style: config.titleStyle?.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          AppLocalizations.of(context)!.profileSubtitle,
          style: config.subtitleStyle?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(SettingsScreenConfig config) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Avatar selection logic
            },
            child: Container(
              width: config.avatarSize,
              height: config.avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF141928),
                border: Border.all(
                  color: AppColors.pastelMint.withValues(alpha: 0.5),
                  width: config.avatarBorderWidth!,
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
                size: config.avatarSize! * 0.5,
                color: AppColors.pastelMint.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.space12),
          Text(
            AppLocalizations.of(context)!.profileChangeAvatar,
            style: config.avatarHintStyle?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, Color color, SettingsScreenConfig config) {
    return Row(
      children: [
        Container(
          width: config.sectionBarWidth,
          height: config.sectionBarHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppConstants.space8),
        Text(
          title,
          style: config.sectionTitleStyle?.copyWith(
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
    required SettingsScreenConfig config,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.all(config.fieldPadding ?? 0),
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
              Icon(icon,
                  size: AppConstants.iconSmall, color: AppColors.pastelMint),
              const SizedBox(width: AppConstants.space8),
              Text(
                label,
                style: config.fieldLabelStyle?.copyWith(
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
            style: config.fieldInputStyle?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: config.fieldInputStyle?.copyWith(
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
    required SettingsScreenConfig config,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(config.fieldPadding ?? 0),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: config.toggleIconContainer,
            height: config.toggleIconContainer,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(icon, size: config.toggleIconSize, color: color),
          ),
          const SizedBox(width: AppConstants.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: config.toggleTitleStyle?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  subtitle,
                  style: config.toggleSubStyle?.copyWith(
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

  Widget _buildDangerZone(SettingsScreenConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Danger Zone', AppColors.neonCrimson, config),
        const SizedBox(height: AppConstants.space16),
        Container(
          padding: EdgeInsets.all(config.dangerPadding ?? 0),
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
                config: config,
                onTap: _showResetConfirmation,
              ),
              const SizedBox(height: AppConstants.space16),
              _buildDangerButton(
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                icon: Icons.delete_forever,
                config: config,
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
    required SettingsScreenConfig config,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(config.dangerButtonPadding ?? 0),
        decoration: BoxDecoration(
          color: AppColors.neonCrimson.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border:
              Border.all(color: AppColors.neonCrimson.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: config.dangerIconSize, color: AppColors.neonCrimson),
            const SizedBox(width: AppConstants.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: config.dangerTitleStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neonCrimson,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space4),
                  Text(
                    subtitle,
                    style: config.dangerSubStyle?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: config.dangerArrowSize,
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
