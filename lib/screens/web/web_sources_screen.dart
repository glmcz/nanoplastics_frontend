import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/pdf_source.dart';
import '../../services/logger_service.dart';
import '../../services/settings_manager.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';
import '../../widgets/nanosolve_logo.dart';

enum _SourceType { webLinks, videoLinks }

class WebSourcesScreen extends StatefulWidget {
  const WebSourcesScreen({super.key});

  @override
  State<WebSourcesScreen> createState() => _WebSourcesScreenState();
}

class _WebSourcesScreenState extends State<WebSourcesScreen> {
  _SourceType _selectedTab = _SourceType.videoLinks;

  @override
  void initState() {
    super.initState();
    LoggerService().logScreenNavigation('WebSourcesScreen');
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      LoggerService().logError('WebSourcesScreen: could not launch URL', url);
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
              AppColors.pastelAqua
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
              _Header(),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _TabBar(
                  selectedTab: _selectedTab,
                  onTabChanged: (tab) => setState(() => _selectedTab = tab),
                ),
              ),
              Expanded(
                child: _selectedTab == _SourceType.webLinks
                    ? _WebLinksContent(openLink: _openLink)
                    : _VideoLinksContent(openLink: _openLink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Back',
            child: InkWell(
              borderRadius: BorderRadius.circular(sizing.radiusMd),
              onTap: () => Navigator.maybePop(context),
              child: Padding(
                padding: EdgeInsets.all(spacing.xs),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.neonCyan,
                  size: sizing.iconMd,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing.sm),
          const NanosolveLogo(height: 28),
          SizedBox(width: spacing.sm),
          Text(
            'Sources',
            style: typography.title.copyWith(color: AppColors.neonCyan),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final _SourceType selectedTab;
  final Function(_SourceType) onTabChanged;

  const _TabBar({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final colors = AppThemeColors.of(context);

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabButton(
            label: l10n.sourcesTabWeb,
            isSelected: selectedTab == _SourceType.webLinks,
            onTap: () => onTabChanged(_SourceType.webLinks),
            spacing: spacing,
            typography: typography,
            colors: colors,
          ),
          SizedBox(width: spacing.md),
          _TabButton(
            label: l10n.sourcesTabVideo,
            isSelected: selectedTab == _SourceType.videoLinks,
            onTap: () => onTabChanged(_SourceType.videoLinks),
            spacing: spacing,
            typography: typography,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppSpacing spacing;
  final AppTypography typography;
  final AppThemeColors colors;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.spacing,
    required this.typography,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
          child: Column(
            children: [
              Text(
                label,
                style: typography.body.copyWith(
                  color: isSelected ? AppColors.neonCyan : colors.textMuted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected)
                Container(
                  margin: EdgeInsets.only(top: spacing.xs),
                  height: 2,
                  width: 40,
                  color: AppColors.neonCyan,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebLinksContent extends StatelessWidget {
  final Function(String) openLink;

  const _WebLinksContent({required this.openLink});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final colors = AppThemeColors.of(context);
    final userLang = SettingsManager().userLanguage;

    final sections = [
      (
        title: l10n.sourcesSectionHumanHealth,
        icon: Icons.favorite_outline,
        sources:
            humanHealthSources.where((s) => s.language == userLang).toList(),
      ),
      (
        title: l10n.sourcesSectionEarthPollution,
        icon: Icons.terrain_outlined,
        sources:
            earthPollutionSources.where((s) => s.language == userLang).toList(),
      ),
      (
        title: l10n.sourcesSectionWaterAbilities,
        icon: Icons.water_drop_outlined,
        sources:
            waterAbilitiesSources.where((s) => s.language == userLang).toList(),
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final section in sections) ...[
            Padding(
              padding: EdgeInsets.only(bottom: spacing.sm),
              child: Text(
                section.title,
                style: typography.title.copyWith(color: AppColors.neonCyan),
              ),
            ),
            ...section.sources.where((s) => s.url != null).map(
                  (source) => _WebLinkCard(
                    source: source,
                    onTap: () => openLink(source.url!),
                    spacing: spacing,
                    sizing: sizing,
                    typography: typography,
                    colors: colors,
                  ),
                ),
            SizedBox(height: spacing.md),
          ],
        ],
      ),
    );
  }
}

class _WebLinkCard extends StatelessWidget {
  final PDFSource source;
  final VoidCallback onTap;
  final AppSpacing spacing;
  final AppSizing sizing;
  final AppTypography typography;
  final AppThemeColors colors;

  const _WebLinkCard({
    required this.source,
    required this.onTap,
    required this.spacing,
    required this.sizing,
    required this.typography,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: source.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(sizing.radiusMd),
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: spacing.sm),
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colors.cardBackground.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(sizing.radiusMd),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
              width: sizing.borderThin,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: AppColors.neonCyan,
                size: sizing.iconMd,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      source.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.copyWith(
                        color: colors.textMain,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (source.description.isNotEmpty) ...[
                      SizedBox(height: spacing.xs),
                      Text(
                        source.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.bodySm.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                color: colors.textMuted,
                size: sizing.iconSm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoLinksContent extends StatelessWidget {
  final Function(String) openLink;

  const _VideoLinksContent({required this.openLink});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final colors = AppThemeColors.of(context);
    final userLang = SettingsManager().userLanguage;

    final videos = allVideoSources[userLang] ?? videoSourcesEn;
    final videoList = videos.where((v) => !v.isReport).toList();

    return ListView.separated(
      padding: EdgeInsets.all(spacing.md),
      itemCount: videoList.length,
      separatorBuilder: (_, __) => SizedBox(height: spacing.sm),
      itemBuilder: (context, index) => _VideoCard(
        video: videoList[index],
        number: index + 1,
        onTap: () => openLink(videoList[index].url),
        spacing: spacing,
        sizing: sizing,
        typography: typography,
        colors: colors,
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoSource video;
  final int number;
  final VoidCallback onTap;
  final AppSpacing spacing;
  final AppSizing sizing;
  final AppTypography typography;
  final AppThemeColors colors;

  const _VideoCard({
    required this.video,
    required this.number,
    required this.onTap,
    required this.spacing,
    required this.sizing,
    required this.typography,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: video.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(sizing.radiusMd),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colors.cardBackground.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(sizing.radiusMd),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
              width: sizing.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(sizing.radiusMd),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: typography.body.copyWith(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: typography.body.copyWith(
                        color: colors.textMain,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pastelMint.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(sizing.radiusSm),
                      ),
                      child: Text(
                        'Documentary',
                        style: typography.labelSm.copyWith(
                          color: AppColors.neonBio,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_outline,
                color: AppColors.neonCyan,
                size: sizing.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
