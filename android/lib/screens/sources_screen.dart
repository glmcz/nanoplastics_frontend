import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/responsive_config.dart';
import '../widgets/nanosolve_logo.dart';
import '../widgets/header_back_button.dart';
import '../l10n/app_localizations.dart';
import '../models/pdf_source.dart';
import 'pdf_viewer_screen.dart';
import '../services/logger_service.dart';
import '../services/settings_manager.dart';

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
              _buildMainReportCard(),
              _buildTabsNavigation(),
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
                  label: AppLocalizations.of(context)!.sourcesBack,
                ),
                Icon(
                  Icons.menu_book_outlined,
                  size: header.iconSize,
                  color: AppColors.pastelAqua,
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

  Widget _buildMainReportCard() {
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getSourcesScreenConfig();

    return GestureDetector(
      onTap: () {
        LoggerService().logUserAction('main_report_opened', params: {
          'report': 'nanoplastics_main_report',
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PDFViewerScreen(
              title: 'Nanoplastics: Global Report',
              startPage: 1,
              endPage: 198,
              description:
                  'The comprehensive global report on nanoplastics pollution and its effects',
              pdfAssetPath:
                  'assets/docs/Nanoplastics_in_the_Biosphere_Report.pdf',
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: config.reportMarginH,
          vertical: config.reportMarginV,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: config.reportPaddingH,
          vertical: config.reportPaddingV,
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
          border: Border.all(color: AppColors.pastelAqua),
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
                  style: config.reportLabelStyle?.copyWith(
                    color: AppColors.pastelAqua,
                    letterSpacing: 1,
                  ),
                ),
                Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.pastelAqua.withValues(alpha: 0.8),
                  size: config.pdfIconSize,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.space4),
            Text(
              AppLocalizations.of(context)!.sourcesMainReportTitle,
              style: config.reportTitleStyle?.copyWith(
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
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getSourcesScreenConfig();

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: config.tabMarginH, vertical: config.tabMarginV),
      padding: EdgeInsets.all(config.tabPadding),
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
              config: config,
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
              config: config,
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
    required SourcesScreenConfig config,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: config.tabButtonPaddingV,
            horizontal: AppConstants.space4),
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
          style: config.tabStyle?.copyWith(
            color: isActive ? AppColors.pastelAqua : AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildWebLinksTab() {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getSourcesScreenConfig();

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
        padding: EdgeInsets.symmetric(horizontal: config.contentPaddingH),
        child: Column(
          children: [
            for (final s in sections) ...[
              _buildSectionHeader(
                title: s.title,
                icon: s.icon,
                sourceCount: s.sources.length,
                isExpanded: false,
                config: config,
                onTap: () => setState(() => _expandedSection = s.section),
              ),
              SizedBox(height: config.cardSpacing),
            ],
          ],
        ),
      );
    }

    // Find expanded section data
    final expandedData =
        sections.firstWhere((s) => s.section == _expandedSection);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: config.contentPaddingH),
      child: Column(
        children: [
          // Sticky header for expanded section
          _buildSectionHeader(
            title: expandedData.title,
            icon: expandedData.icon,
            sourceCount: expandedData.sources.length,
            isExpanded: true,
            config: config,
            onTap: () => setState(() => _expandedSection = null),
          ),
          SizedBox(height: config.cardSpacing),
          // Scrollable content for expanded section
          Expanded(
            child: ListView.builder(
              itemCount: expandedData.sources.length,
              itemBuilder: (context, index) {
                return _buildPDFLinkCard(
                  number: index + 1,
                  source: expandedData.sources[index],
                  config: config,
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
    required SourcesScreenConfig config,
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
        padding: EdgeInsets.all(config.sectionPadding),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(config.sectionIconPadding),
              decoration: BoxDecoration(
                color: AppColors.pastelMint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                icon,
                size: config.sectionIconSize,
                color: AppColors.pastelMint,
              ),
            ),
            SizedBox(width: config.cardSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: config.sectionTitleStyle?.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space4),
                  Text(
                    '$sourceCount resources',
                    style: config.sectionCountStyle?.copyWith(
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
                size: config.sectionArrowSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLinksTab() {
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getSourcesScreenConfig();
    final settingsManager = SettingsManager();
    final userLanguage = settingsManager.userLanguage;

    // Get videos for user's language, fallback to English if not available
    final videos = allVideoSources[userLanguage] ?? videoSourcesEn;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: config.contentPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video list
          ...videos.asMap().entries.map((entry) {
            return _buildVideoCard(
              number: entry.key + 1,
              video: entry.value,
              config: config,
            );
          }),
          SizedBox(height: config.reportPaddingV),
        ],
      ),
    );
  }

  Widget _buildVideoCard({
    required int number,
    required VideoSource video,
    required SourcesScreenConfig config,
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
        margin: EdgeInsets.only(bottom: config.cardSpacing),
        padding: EdgeInsets.all(config.cardPadding),
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
              padding: EdgeInsets.all(config.sectionIconPadding),
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
                size: config.sectionIconSize,
                color: video.isReport
                    ? AppColors.pastelAqua
                    : AppColors.pastelMint,
              ),
            ),
            SizedBox(width: config.cardSpacing),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: config.cardTitleStyle?.copyWith(
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
                      style: config.badgeStyle?.copyWith(
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
              style: config.numberStyle?.copyWith(
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
    required SourcesScreenConfig config,
  }) {
    return GestureDetector(
      onTap: () {
        LoggerService().logUserAction('pdf_source_clicked', params: {
          'source': source.title,
          'startPage': source.startPage,
          'endPage': source.endPage,
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PDFViewerScreen(
              title: source.title,
              startPage: source.startPage,
              endPage: source.endPage,
              description: source.description,
              pdfAssetPath: source.pdfAssetPath,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: config.cardSpacing),
        padding: EdgeInsets.all(config.cardPadding),
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
                    style: config.cardTitleStyle?.copyWith(
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space4),
                  Text(
                    source.description,
                    style: config.cardDescStyle?.copyWith(
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
                      style: config.badgeStyle?.copyWith(
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
                  style: config.numberStyle?.copyWith(
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: config.reportPaddingV),
                Icon(
                  Icons.picture_as_pdf,
                  size: config.pdfIconSize,
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
