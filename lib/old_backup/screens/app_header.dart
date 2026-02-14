import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../services/localization_service.dart';
import '../settings_screen.dart';

class AppHeader extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppHeader({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.headerPadding,
        vertical: AppConstants.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.panelBackground.withOpacity(0.95),
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: onBackPressed,
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (showBackButton) const SizedBox(width: 12),
          Expanded(child: _buildLogo()),
          _buildSettings(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
        children: [
          TextSpan(
            text: 'NANO',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'HIVE',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          'assets/icons/icon-settings.jpg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
