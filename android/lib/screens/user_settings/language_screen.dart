import 'package:flutter/material.dart';
import 'dart:ui';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/responsive_config.dart';
import '../../services/settings_manager.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../widgets/header_back_button.dart';
import '../../main.dart';

class LanguageScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;

  const LanguageScreen({super.key, this.onLanguageChanged});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final _settingsManager = SettingsManager();
  late String _selectedLanguage;

  final List<LanguageOption> _languages = [
    const LanguageOption(
        code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    const LanguageOption(
        code: 'cs', name: 'Czech', nativeName: 'Čeština', flag: '🇨🇿'),
    const LanguageOption(
        code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    const LanguageOption(
        code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    const LanguageOption(
        code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _settingsManager.userLanguage;
  }

  Future<void> _selectLanguage(String code) async {
    if (_selectedLanguage == code) return;

    setState(() => _selectedLanguage = code);
    await _settingsManager.setUserLanguage(code);

    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!(Locale(code));
    }

    // Restart the app to apply the new language
    if (mounted) {
      RestartableApp.restartApp(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Language changed to ${_languages.firstWhere((l) => l.code == code).name}'),
          backgroundColor: AppColors.pastelAqua.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        ),
      );
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
              AppColors.pastelAqua.withValues(alpha: 0.05),
              AppColors.pastelMint.withValues(alpha: 0.05),
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
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final header = responsive.getSecondaryHeaderConfig();

    return Container(
      padding: EdgeInsets.all(header.padding),
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
                ),
                Icon(Icons.language,
                    size: header.iconSize, color: AppColors.pastelAqua),
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
          ..._languages.map((lang) => Padding(
                padding: EdgeInsets.only(bottom: config.cardSpacing),
                child: _buildLanguageItem(lang, config),
              )),
          SizedBox(height: config.cardSpacing),
          _buildInfoCard(config),
          SizedBox(height: config.cardSpacing * 2),
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
            colors: [AppColors.pastelAqua, AppColors.pastelMint],
          ).createShader(bounds),
          child: Text(
            AppLocalizations.of(context)!.languageTitle,
            style: config.titleStyle?.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          AppLocalizations.of(context)!.languageSubtitle,
          style: config.subtitleStyle?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLanguageItem(
      LanguageOption language, SettingsScreenConfig config) {
    final isSelected = _selectedLanguage == language.code;

    return GestureDetector(
      onTap: () => _selectLanguage(language.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(config.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pastelAqua.withValues(alpha: 0.15)
              : const Color(0xFF141928).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: isSelected
                ? AppColors.pastelAqua.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pastelAqua.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              language.flag,
              style: TextStyle(fontSize: config.iconSize + 6),
            ),
            SizedBox(width: config.cardSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: config.cardTitleStyle?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.pastelAqua : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language.nativeName,
                    style: config.subtitleStyle?.copyWith(
                      color: isSelected
                          ? AppColors.pastelAqua.withValues(alpha: 0.7)
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: config.iconSize,
              height: config.iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.pastelAqua : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.pastelAqua : AppColors.textDark,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check,
                      size: config.iconSize * 0.65,
                      color: const Color(0xFF0A0A12))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(SettingsScreenConfig config) {
    return Container(
      padding: EdgeInsets.all(config.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.pastelAqua.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.pastelAqua.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: config.iconSize,
            color: AppColors.pastelAqua,
          ),
          SizedBox(width: config.cardSpacing),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.languageInfoMessage,
              style: config.subtitleStyle?.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}
