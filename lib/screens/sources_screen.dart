import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/app_typography.dart';
import '../widgets/nanosolve_logo.dart';
import '../widgets/glowing_header_separator.dart';
import '../l10n/app_localizations.dart';
import '../models/pdf_source.dart';
import '../services/logger_service.dart';
import '../services/settings_manager.dart';
import '../services/service_locator.dart';

enum SourceType { webLinks, videoLinks }

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

enum WebLinkSection { humanHealth, earthPollution, waterAbilities }

class _SourcesScreenState extends State<SourcesScreen> {
  SourceType _selectedTab = SourceType.webLinks;
  WebLinkSection?
      _expandedSection; // Only one section can be expanded at a time

  @override
  void initState() {
    super.initState();
    LoggerService().logScreenNavigation('SourcesScreen');
    LoggerService().logFeatureUsage('sources_screen_opened', metadata: {
      'timestamp': DateTime.now().toIso8601String(),
    });
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
              Stack(
                children: [
                  Column(
                    children: [
                      _buildMainReportCard(),
                      _buildTabsNavigation(),
                    ],
                  ),
                  ...GlowingHeaderSeparator.build(
                    glowColor: AppColors.energy,
                  ),
                ],
              ),
              Expanded(
                child: _selectedTab == SourceType.webLinks
                    ? _buildWebLinksTab()
                    : _buildVideoLinksTab(),
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
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,
          vertical: spacing.contentPaddingV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: sizing.backIcon),
                  const SizedBox(width: AppConstants.space4),
                  Flexible(
                    child: Text(
                      l10n.categoryDetailBackToOverview,
                      style: typography.back.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing.headerSpacing),
          NanosolveLogo(height: sizing.logoHeightLg),
        ],
      ),
    );
  }

  Widget _buildMainReportCard() {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return GestureDetector(
      onTap: () {
        LoggerService().logUserAction('main_report_opened', params: {
          'report': 'nanoplastics_main_report',
        });

        ServiceLocator().pdfService.openPdf(
              context: context,
              title: 'Nanoplastics: Global Report',
              description:
                  'The comprehensive global report on nanoplastics pollution and its effects',
              startPage: 1,
              endPage: 198,
            );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,

          /// TODO: refactor me
          vertical: spacing.md,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.cardPadding,
          vertical: spacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.pastelAqua.withValues(alpha: 0.1),
              AppColors.pastelMint.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(color: AppColors.pastelAqua.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.pastelAqua.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.sourcesMainReportLabel,
                  style: typography.label.copyWith(
                    color: AppColors.pastelAqua,
                    letterSpacing: 1,
                  ),
                ),
                Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.pastelAqua.withValues(alpha: 0.8),
                  size: sizing.iconMd,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.space4),
            Text(
              AppLocalizations.of(context)!.sourcesMainReportTitle,
              style: typography.title.copyWith(
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsNavigation() {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: spacing.tabMarginH, vertical: sizing.tabMarginV),
      padding: EdgeInsets.all(spacing.tabInnerPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: AppLocalizations.of(context)!.sourcesTabWeb,
              isActive: _selectedTab == SourceType.webLinks,
              textStyle: typography.tab,
              padding: spacing.tabButtonPadding,
              onTap: () {
                setState(() => _selectedTab = SourceType.webLinks);
                LoggerService().logUserAction('sources_tab_switched',
                    params: {'tab': 'web'});
              },
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: AppLocalizations.of(context)!.sourcesTabVideo,
              isActive: _selectedTab == SourceType.videoLinks,
              textStyle: typography.tab,
              padding: spacing.tabButtonPadding,
              onTap: () {
                setState(() => _selectedTab = SourceType.videoLinks);
                LoggerService().logUserAction('sources_tab_switched',
                    params: {'tab': 'video'});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required TextStyle textStyle,
    required double padding,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.pastelAqua.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: isActive
              ? Border.all(color: AppColors.pastelAqua.withValues(alpha: 0.3))
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.pastelAqua.withValues(alpha: 0.1),
                    blurRadius: 15,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: textStyle.copyWith(
            color: isActive ? AppColors.pastelAqua : AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildWebLinksTab() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    // Filter all sources based on user's language setting
    final userLang = SettingsManager().userLanguage;

    final filteredHumanHealthSources = humanHealthSources
        .where((source) => source.language == userLang)
        .toList();

    final filteredEarthPollutionSources = earthPollutionSources
        .where((source) => source.language == userLang)
        .toList();

    final filteredWaterSources = waterAbilitiesSources
        .where((source) => source.language == userLang)
        .toList();

    // Define all sections data
    final sections = [
      (
        section: WebLinkSection.humanHealth,
        title: l10n.sourcesSectionHumanHealth,
        icon: Icons.favorite_outline,
        sources: filteredHumanHealthSources,
      ),
      (
        section: WebLinkSection.earthPollution,
        title: l10n.sourcesSectionEarthPollution,
        icon: Icons.public,
        sources: filteredEarthPollutionSources,
      ),
      (
        section: WebLinkSection.waterAbilities,
        title: l10n.sourcesSectionWaterAbilities,
        icon: Icons.water_drop_outlined,
        sources: filteredWaterSources,
      ),
    ];

    // If no section is expanded, show all collapsed sections in a scrollable list
    if (_expandedSection == null) {
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: spacing.contentPaddingH,
            vertical: spacing.contentPaddingV),
        child: Column(
          children: [
            for (final s in sections) ...[
              _buildSectionHeader(
                title: s.title,
                icon: s.icon,
                sourceCount: s.sources.length,
                isExpanded: false,
                spacing: spacing,
                sizing: sizing,
                typography: typography,
                onTap: () => setState(() => _expandedSection = s.section),
              ),
              SizedBox(height: spacing.cardSpacing),
            ],
          ],
        ),
      );
    }

    // Find expanded section data
    final expandedData =
        sections.firstWhere((s) => s.section == _expandedSection);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,
          vertical: spacing.contentPaddingV),
      child: Column(
        children: [
          // Sticky header for expanded section
          _buildSectionHeader(
            title: expandedData.title,
            icon: expandedData.icon,
            sourceCount: expandedData.sources.length,
            isExpanded: true,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
            onTap: () => setState(() => _expandedSection = null),
          ),
          SizedBox(height: spacing.cardSpacing),
          // Scrollable content for expanded section
          Expanded(
            child: ListView.builder(
              itemCount: expandedData.sources.length,
              itemBuilder: (context, index) {
                return _buildPDFLinkCard(
                  number: index + 1,
                  source: expandedData.sources[index],
                  spacing: spacing,
                  sizing: sizing,
                  typography: typography,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required int sourceCount,
    required bool isExpanded,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141928).withValues(alpha: 0.85),
          border: Border.all(
            color: isExpanded
                ? AppColors.pastelAqua.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        padding: EdgeInsets.all(spacing.cardPadding),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                color: AppColors.pastelMint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                icon,
                size: sizing.iconMd,
                color: AppColors.pastelMint,
              ),
            ),
            SizedBox(width: spacing.cardSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.title.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space4),
                  Text(
                    '$sourceCount resources',
                    style: typography.bodySm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.pastelAqua,
                size: sizing.iconSm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLinksTab() {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final settingsManager = SettingsManager();
    final userLanguage = settingsManager.userLanguage;

    // Get videos for user's language, fallback to English if not available
    final videos = allVideoSources[userLanguage] ?? videoSourcesEn;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,
          vertical: spacing.contentPaddingV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video list
          ...videos.asMap().entries.map((entry) {
            return _buildVideoCard(
              number: entry.key + 1,
              video: entry.value,
              spacing: spacing,
              sizing: sizing,
              typography: typography,
            );
          }),
          SizedBox(height: spacing.md),
        ],
      ),
    );
  }

  Widget _buildVideoCard({
    required int number,
    required VideoSource video,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
  }) {
    return GestureDetector(
      onTap: () async {
        LoggerService().logUserAction('video_source_clicked', params: {
          'title': video.title,
          'url': video.url,
          'language': video.language,
          'isReport': video.isReport,
        });

        // Open URL in custom tab (in-app browser)
        try {
          await launchUrl(
            Uri.parse(video.url),
            customTabsOptions: CustomTabsOptions(
              colorSchemes: CustomTabsColorSchemes.defaults(
                toolbarColor: const Color(0xFF141928),
              ),
              shareState: CustomTabsShareState.on,
              urlBarHidingEnabled: true,
              showTitle: true,
            ),
            safariVCOptions: const SafariViewControllerOptions(
              preferredBarTintColor: Color(0xFF141928),
              preferredControlTintColor: AppColors.pastelAqua,
              barCollapsingEnabled: true,
            ),
          );
        } catch (e) {
          LoggerService().logError('VideoOpenFailed', e);
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: spacing.cardSpacing),
        padding: EdgeInsets.all(spacing.cardPadding),
        decoration: BoxDecoration(
          color: const Color(0xFF141928).withValues(alpha: 0.85),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail/Icon
            Container(
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                color: video.isReport
                    ? AppColors.pastelAqua.withValues(alpha: 0.15)
                    : AppColors.pastelMint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                video.isReport
                    ? Icons.picture_as_pdf
                    : Icons.play_circle_filled,
                size: sizing.iconMd,
                color: video.isReport
                    ? AppColors.pastelAqua
                    : AppColors.pastelMint,
              ),
            ),
            SizedBox(width: spacing.cardSpacing),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: typography.title.copyWith(
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.space8,
                      vertical: AppConstants.space4,
                    ),
                    decoration: BoxDecoration(
                      color: video.isReport
                          ? AppColors.pastelAqua.withValues(alpha: 0.1)
                          : AppColors.pastelMint.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSmall),
                      border: Border.all(
                        color: video.isReport
                            ? AppColors.pastelAqua.withValues(alpha: 0.3)
                            : AppColors.pastelMint.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      video.isReport ? 'PDF Report' : 'YouTube',
                      style: typography.labelSm.copyWith(
                        color: video.isReport
                            ? AppColors.pastelAqua
                            : AppColors.pastelMint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Number
            Text(
              '#$number',
              style: typography.label.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPDFLinkCard({
    required int number,
    required PDFSource source,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
  }) {
    return GestureDetector(
      onTap: () {
        LoggerService().logUserAction('pdf_source_clicked', params: {
          'source': source.title,
          'startPage': source.startPage,
          'endPage': source.endPage,
        });

        // Use openPdfFromAsset if custom asset path is provided (for water PDFs, etc.)
        if (source.pdfAssetPath != null && source.pdfAssetPath!.isNotEmpty) {
          ServiceLocator().pdfService.openPdfFromAsset(
                context: context,
                assetPath: source.pdfAssetPath!,
                title: source.title,
                description: source.description,
                startPage: source.startPage,
                endPage: source.endPage,
              );
        } else {
          // Use openPdf for standard language-based reports
          ServiceLocator().pdfService.openPdf(
                context: context,
                title: source.title,
                description: source.description,
                startPage: source.startPage,
                endPage: source.endPage,
              );
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: spacing.cardSpacing),
        padding: EdgeInsets.all(spacing.cardPadding),
        decoration: BoxDecoration(
          color: const Color(0xFF141928).withValues(alpha: 0.85),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.title,
                    style: typography.title.copyWith(
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space4),
                  Text(
                    source.description,
                    style: typography.bodySm.copyWith(
                      color: AppColors.pastelLavender,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.space8,
                      vertical: AppConstants.space4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pastelAqua.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSmall),
                      border: Border.all(
                        color: AppColors.pastelAqua.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Pages ${source.startPage}-${source.endPage}',
                      style: typography.labelSm.copyWith(
                        color: AppColors.pastelAqua,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.space8),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '#$number',
                  style: typography.label.copyWith(
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: spacing.md),
                Icon(
                  Icons.picture_as_pdf,
                  size: sizing.iconMd,
                  color: AppColors.pastelAqua.withValues(alpha: 0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
