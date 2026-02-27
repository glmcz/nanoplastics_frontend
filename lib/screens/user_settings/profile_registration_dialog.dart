import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_theme_colors.dart';
import '../../services/settings_manager.dart';
import '../../services/service_locator.dart';

class ProfileRegistrationDialog extends StatefulWidget {
  final VoidCallback? onProfileShared;

  const ProfileRegistrationDialog({super.key, this.onProfileShared});

  @override
  State<ProfileRegistrationDialog> createState() =>
      _ProfileRegistrationDialogState();
}

class _ProfileRegistrationDialogState extends State<ProfileRegistrationDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _specialtyController;
  late SettingsManager _settingsManager;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _settingsManager = ServiceLocator().settingsManager;
    _nameController = TextEditingController(
      text: _settingsManager.displayName,
    );
    _emailController = TextEditingController(
      text: _settingsManager.email,
    );
    _specialtyController = TextEditingController(
      text: _settingsManager.bio,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final trimmedName = _nameController.text.trim();
    final trimmedEmail = _emailController.text.trim();

    // Validation
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (trimmedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Email validation
    if (!_isValidEmail(trimmedEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _settingsManager.setDisplayName(trimmedName);
      await _settingsManager.setEmail(trimmedEmail);
      await _settingsManager.setBio(_specialtyController.text.trim());
      await _settingsManager.setProfileRegistered(true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onProfileShared?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppConstants.space20),
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeColors.of(context).cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.space24),
          border: Border.all(
            color: AppColors.pastelMint.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.pastelMint.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppConstants.space24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with shine effect
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.pastelMint, AppColors.pastelAqua],
                ).createShader(bounds),
                child: Text(
                  'Join the Community',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppConstants.space8),
              Text(
                'Share your profile to get recognized on the leaderboard',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppThemeColors.of(context).textMuted,
                      height: 1.4,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.space24),

              // Name Field
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: AppConstants.space16),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: AppConstants.space16),

              // Specialty Field
              _buildTextField(
                controller: _specialtyController,
                label: 'Specialty (Optional)',
                hint: 'e.g., Environmental Science',
                icon: Icons.science_outlined,
              ),
              const SizedBox(height: AppConstants.space24),

              // Info Box
              Container(
                padding: const EdgeInsets.all(AppConstants.space12),
                decoration: BoxDecoration(
                  color: AppColors.pastelMint.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: AppColors.pastelMint.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: AppConstants.iconSmall,
                      color: AppColors.pastelMint,
                    ),
                    const SizedBox(width: AppConstants.space8),
                    Expanded(
                      child: Text(
                        'Your data is secure and will only be used for the leaderboard',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppThemeColors.of(context).textMuted,
                                  height: 1.3,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.space24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.space12),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppThemeColors.of(context).textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.space12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pastelMint,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.space12,
                            horizontal: AppConstants.space8),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMedium),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0A0A12),
                                ),
                              ),
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(
                                color: Color(0xFF0A0A12),
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppThemeColors.of(context).textMain,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppConstants.space8),
        TextField(
          controller: controller,
          enabled: !_isLoading,
          style: TextStyle(color: AppThemeColors.of(context).textMain),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppThemeColors.of(context).textMuted,
            ),
            prefixIcon: Icon(
              icon,
              size: AppConstants.iconSmall,
              color: AppColors.pastelMint.withValues(alpha: 0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: AppColors.pastelMint.withValues(alpha: 0.5),
              ),
            ),
            filled: true,
            fillColor:
                AppThemeColors.of(context).surfaceMid.withValues(alpha: 0.6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.space16,
              vertical: AppConstants.space12,
            ),
          ),
        ),
      ],
    );
  }
}
