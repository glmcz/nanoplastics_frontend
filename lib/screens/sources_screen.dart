import 'dart:io';

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/app_typography.dart';
import '../widgets/glowing_header_separator.dart';
import '../l10n/app_localizations.dart';
import '../models/category_detail_data.dart';
import '../models/pdf_source.dart';
import '../models/sources.dart';
import '../services/logger_service.dart';
import '../services/settings_manager.dart';
import '../services/service_locator.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../services/web_link_cache_service.dart';
import '../utils/app_theme_colors.dart';
import '../utils/platform_adaptive.dart';
import '../widgets/shared/screen_header.dart';
import '../widgets/sources/evidence_study_card.dart';
import '../widgets/sources/pdf_source_card.dart';
import '../widgets/sources/video_source_card.dart';
import '../utils/pdf_utils.dart';
import 'pdf_viewer_screen.dart';
import 'web_view_screen.dart';

enum SourceType { webLinks, reportLinks, videoLinks }

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

enum WebLinkSection { humanHealth, earthPollution, waterAbilities }

enum VideoSection { videos, reports }

class _SourcesScreenState extends State<SourcesScreen> {
  SourceType _selectedTab = SourceType.reportLinks;
  WebLinkSection _selectedSection = WebLinkSection.humanHealth;
  VideoSection _selectedVideoSection = VideoSection.videos;
  String _webLinksSearchQuery = '';
  final TextEditingController _webLinksSearchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    LoggerService().logScreenNavigation('SourcesScreen');
    LoggerService().logFeatureUsage('sources_screen_opened', metadata: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _webLinksSearchController.dispose();
    super.dispose();
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
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: PlatformAdaptive.contentMaxWidth(context),
                  ),
                  child: const ScreenHeader(),
                ),
              ),
            ),
            _SourcesScreenTabs(
              selectedTab: _selectedTab,
              onTabChanged: (tab) => setState(() => _selectedTab = tab),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: PlatformAdaptive.contentMaxWidth(context),
                  ),
                  child: switch (_selectedTab) {
                    SourceType.webLinks => _buildWebLinksTab(),
                    SourceType.reportLinks => _buildReportTab(),
                    SourceType.videoLinks => _buildVideoLinksTab(),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTab() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final userLang = SettingsManager().userLanguage;
    final reportLang = userLang == 'ar' ? 'en' : userLang;

    List<PDFSource> sortSources(List<PDFSource> sources) {
      final newItems = sources.where((s) => s.isNew).toList();
      final oldItems = sources.where((s) => !s.isNew).toList();
      return [...newItems, ...oldItems];
    }

    final sections = [
      (
        section: WebLinkSection.humanHealth,
        title: l10n.sourcesSectionHumanHealth,
        icon: Icons.favorite_outline,
        sources: sortSources(
            humanHealthSources.where((s) => s.language == reportLang).toList()),
      ),
      (
        section: WebLinkSection.earthPollution,
        title: l10n.sourcesSectionEarthPollution,
        icon: Icons.public,
        sources: sortSources(earthPollutionSources
            .where((s) => s.language == reportLang)
            .toList()),
      ),
      (
        section: WebLinkSection.waterAbilities,
        title: l10n.sourcesSectionWaterAbilities,
        icon: Icons.water_drop_outlined,
        sources: sortSources(waterAbilitiesSources
            .where((s) => s.language == reportLang)
            .toList()),
      ),
    ];

    final selectedData =
        sections.firstWhere((s) => s.section == _selectedSection);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              spacing.contentPaddingH, spacing.md, spacing.contentPaddingH, 0),
          child: Column(
            children: [
              for (final s in sections) ...[
                _buildSectionHeader(
                  title: s.title,
                  icon: s.icon,
                  sourceCount: s.sources.length,
                  isSelected: s.section == _selectedSection,
                  accentColorOverride: AppColors.pastelLavender,
                  spacing: spacing,
                  sizing: sizing,
                  typography: typography,
                  onTap: () => setState(() => _selectedSection = s.section),
                ),
                SizedBox(height: spacing.xs),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.sm),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
                horizontal: spacing.contentPaddingH,
                vertical: spacing.contentPaddingV),
            itemCount: selectedData.sources.length,
            itemBuilder: (ctx, i) => PdfSourceCard(
              number: i + 1,
              source: selectedData.sources[i],
              onTap: () => _openPdfSource(selectedData.sources[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebLinksTab() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    final isMobilePlatform =
        !PlatformAdaptive.isWeb && (Platform.isAndroid || Platform.isIOS);
    if (isMobilePlatform) {
      return _buildMobileEvidenceWebLinksTab(
        l10n: l10n,
        spacing: spacing,
        sizing: sizing,
        typography: typography,
      );
    }

    final userLang = SettingsManager().userLanguage;

    final sections = [
      (
        section: WebLinkSection.humanHealth,
        title: l10n.sourcesSectionHumanHealth,
        icon: Icons.favorite_outline,
        sources:
            humanHealthSources.where((s) => s.language == userLang).toList(),
      ),
      (
        section: WebLinkSection.earthPollution,
        title: l10n.sourcesSectionEarthPollution,
        icon: Icons.public,
        sources:
            earthPollutionSources.where((s) => s.language == userLang).toList(),
      ),
      (
        section: WebLinkSection.waterAbilities,
        title: l10n.sourcesSectionWaterAbilities,
        icon: Icons.water_drop_outlined,
        sources:
            waterAbilitiesSources.where((s) => s.language == userLang).toList(),
      ),
    ];

    final selectedData =
        sections.firstWhere((s) => s.section == _selectedSection);

    return Column(
      children: [
        // ── Navigation: all 3 slim section headers ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.contentPaddingH),
          child: Column(
            children: [
              for (final s in sections) ...[
                _buildSectionHeader(
                  title: s.title,
                  icon: s.icon,
                  sourceCount: s.sources.length,
                  isSelected: s.section == _selectedSection,
                  spacing: spacing,
                  sizing: sizing,
                  typography: typography,
                  onTap: () => setState(() => _selectedSection = s.section),
                ),
                SizedBox(height: spacing.xs),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.sm),
        // ── Content: selected section's items ──
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
                horizontal: spacing.contentPaddingH,
                vertical: spacing.contentPaddingV),
            itemCount: selectedData.sources.length,
            itemBuilder: (ctx, i) => PdfSourceCard(
              number: i + 1,
              source: selectedData.sources[i],
              onTap: () => _openPdfSource(selectedData.sources[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileEvidenceWebLinksTab({
    required AppLocalizations l10n,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
  }) {
    final groups = _buildGroupedEvidenceLinks(l10n, _webLinksSearchQuery);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.contentPaddingH,
            spacing.md,
            spacing.contentPaddingH,
            spacing.sm,
          ),
          child: TextField(
            controller: _webLinksSearchController,
            onChanged: (value) => setState(() => _webLinksSearchQuery = value),
            style: typography.body,
            decoration: InputDecoration(
              hintText: l10n.sourcesWebTabSearchbar,
              hintStyle: typography.bodySm.copyWith(
                color: AppThemeColors.of(context).textMuted,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: sizing.iconSm,
                color: AppThemeColors.of(context).textMuted,
              ),
              suffixIcon: _webLinksSearchQuery.trim().isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.close,
                        size: sizing.iconSm,
                        color: AppThemeColors.of(context).textMuted,
                      ),
                      onPressed: () {
                        _webLinksSearchController.clear();
                        setState(() => _webLinksSearchQuery = '');
                      },
                    ),
              filled: true,
              fillColor: AppThemeColors.of(context)
                  .cardBackground
                  .withValues(alpha: 0.85),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide: BorderSide(
                  color: AppColors.pastelAqua.withValues(alpha: 0.55),
                ),
              ),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: groups.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: spacing.contentPaddingH),
                    child: Text(
                      'No links found.',
                      textAlign: TextAlign.center,
                      style: typography.bodySm.copyWith(
                        color: AppThemeColors.of(context).textMuted,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.contentPaddingH,
                    vertical: spacing.contentPaddingV,
                  ),
                  itemCount: groups.length,
                  itemBuilder: (ctx, groupIndex) {
                    final group = groups[groupIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.categoryTitle.toUpperCase(),
                          style: typography.title.copyWith(
                            color: group.categoryColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: spacing.sm),
                        ...group.studies.asMap().entries.map((entry) {
                          return EvidenceStudyCard(
                            study: entry.value,
                            number: entry.key + 1,
                            onTap: () => _openEvidenceStudyFromSources(
                              group.categoryKey,
                              entry.value,
                            ),
                          );
                        }),
                        SizedBox(height: spacing.lg),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<MobileEvidenceGroup> _buildGroupedEvidenceLinks(
    AppLocalizations l10n,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    final categories = CategoryDetailDataFactory.all(l10n);

    final groups = categories
        .map((category) {
          final seen = <String>{};
          final studies = category.evidenceSections
              .expand((section) => section.studies)
              .where((study) {
            if (normalizedQuery.isEmpty) return true;
            final haystack = [
              category.title,
              study.title,
              study.authorsShort,
              study.journal,
              study.url,
            ].join(' ').toLowerCase();
            return haystack.contains(normalizedQuery);
          }).where((study) {
            final key = '${study.title}|${study.url}';
            return seen.add(key);
          }).toList();

          studies.sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

          return MobileEvidenceGroup(
            categoryKey: category.categoryKey,
            categoryTitle: category.title,
            categoryColor: category.themeColor,
            studies: studies,
          );
        })
        .where((group) => group.studies.isNotEmpty)
        .toList();

    groups.sort((a, b) =>
        a.categoryTitle.toLowerCase().compareTo(b.categoryTitle.toLowerCase()));
    return groups;
  }

  Future<void> _openPdfSource(PDFSource source) async {
    LoggerService().logUserAction('pdf_source_clicked', params: {
      'source': source.title,
      'startPage': source.startPage,
      'endPage': source.endPage,
    });

    if (source.isWebLink && !source.url!.contains('.pdf')) {
      final navigator = Navigator.of(context);
      await WebLinkCacheService().markVisited(source.url!);
      navigator.push(MaterialPageRoute(
        builder: (_) => WebViewScreen(url: source.url!, title: source.title),
      ));
      return;
    }

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final themeColors = AppThemeColors.of(context);
    final dialogBg = themeColors.dialogBackground;
    final toolbarColor = themeColors.cardBackground;

    if (source.pdfAssetPath != null && source.pdfAssetPath!.isNotEmpty) {
      final bundled = await assetExists(source.pdfAssetPath!);
      if (!context.mounted) return;
      if (!bundled) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('PDF not available in this build'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      navigator.push(MaterialPageRoute(
        builder: (_) => PDFViewerScreen(
          title: source.title,
          pdfAssetPath: source.pdfAssetPath,
          startPage: source.startPage,
          endPage: source.endPage,
          description: source.description,
        ),
      ));
      return;
    }

    final lang = ServiceLocator().settingsManager.userLanguage;
    final cached =
        await ServiceLocator().settingsManager.getPdfForLanguage(lang);
    final needsDownload = cached == null || !await cached.exists();

    if (needsDownload && context.mounted) {
      showDialog(
        context: context, // ignore: use_build_context_synchronously
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: dialogBg,
          title: const Text('Downloading PDF…',
              style: TextStyle(color: AppColors.pastelAqua)),
          content: const LinearProgressIndicator(
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pastelAqua),
          ),
        ),
      );
    }

    File? pdf;
    try {
      pdf = await ServiceLocator().pdfService.resolvePdf(language: lang);
    } catch (e, st) {
      LoggerService().logError('ResolvePdfFailed', e.toString(), st);
    }

    if (needsDownload && context.mounted) await navigator.maybePop();
    if (!context.mounted) return;

    if (pdf != null) {
      navigator.push(MaterialPageRoute(
        builder: (_) => PDFViewerScreen(
          title: source.title,
          pdfPath: pdf!.path,
          startPage: source.startPage,
          endPage: source.endPage,
          description: source.description,
        ),
      ));
    } else if (source.isWebLink) {
      await WebLinkCacheService().markVisited(source.url!);
      try {
        await launchUrl(
          Uri.parse(source.url!),
          customTabsOptions: CustomTabsOptions(
            colorSchemes:
                CustomTabsColorSchemes.defaults(toolbarColor: toolbarColor),
            shareState: CustomTabsShareState.on,
            urlBarHidingEnabled: true,
            showTitle: true,
          ),
          safariVCOptions: const SafariViewControllerOptions(
            preferredBarTintColor: AppColors.pastelLavender,
            preferredControlTintColor: Colors.white,
            barCollapsingEnabled: true,
            dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
          ),
        );
      } catch (e) {
        LoggerService().logError('PdfFallbackLaunchFailed', e.toString());
      }
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Failed to load PDF')),
      );
    }
  }

  Future<void> _openEvidenceStudyFromSources(
    String categoryKey,
    EvidenceStudy study,
  ) async {
    LoggerService().logUserAction('sources_evidence_study_opened', params: {
      'category': categoryKey,
      'title': study.title,
      'journal': study.journal,
      'year': study.year,
    });

    try {
      final url =
          '${study.url}${study.url.contains('?') ? '&' : '?'}utm_source=nanoplastics_app';

      if (PlatformAdaptive.isWeb) {
        await PlatformAdaptive.launchExternalUrl(url);
        return;
      }

      await launchUrl(
        Uri.parse(url),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: const Color(0xFF141928),
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          browser: const CustomTabsBrowserConfiguration(
            fallbackCustomTabs: [
              'org.mozilla.firefox',
              'org.mozilla.firefox_beta',
              'com.microsoft.emmx',
            ],
          ),
        ),
        safariVCOptions: const SafariViewControllerOptions(
          preferredBarTintColor: Color(0xFF141928),
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e, st) {
      LoggerService().logError(
        'SourcesEvidenceStudyOpenFailed',
        '${study.url}: $e',
        st,
      );
    }
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required int sourceCount,
    required bool isSelected,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
    required VoidCallback onTap,
    Color? accentColorOverride,
  }) {
    final accentColor = isSelected
        ? (accentColorOverride ?? AppColors.pastelAqua)
        : AppColors.textMuted;
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (accentColorOverride ?? AppColors.pastelAqua)
                    .withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: isSelected
                  ? (accentColorOverride ?? AppColors.pastelAqua)
                      .withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: sizing.iconXss, color: accentColor),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: typography.label.copyWith(
                    color: isSelected
                        ? AppThemeColors.of(context).textMain
                        : AppThemeColors.of(context).textMuted,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$sourceCount',
                  style: typography.labelXs.copyWith(color: accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLinksTab() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final userLanguage = SettingsManager().userLanguage;

    // Get videos for user's language, fallback to English if not available
    final allVideos = allVideoSources[userLanguage] ?? videoSourcesEn;

    final sections = [
      (
        section: VideoSection.videos,
        title: l10n.sourcesVideoSectionDocumentaries,
        icon: Icons.play_circle_outline,
        sources: allVideos.where((v) => !v.isReport).toList(),
      ),
      // Not needed for now.
      // (
      //   section: VideoSection.reports,
      //   title: l10n.sourcesVideoSectionReports,
      //   icon: Icons.picture_as_pdf_outlined,
      //   sources: allVideos.where((v) => v.isReport).toList(),
      // ),
    ];

    final selectedData =
        sections.firstWhere((s) => s.section == _selectedVideoSection);

    return Column(
      children: [
        // ── Navigation: 2 slim section headers ──
        Padding(
          padding: EdgeInsets.fromLTRB(
              spacing.contentPaddingH, spacing.md, spacing.contentPaddingH, 0),
          child: Column(
            children: [
              for (final s in sections) ...[
                _buildSectionHeader(
                  title: s.title,
                  icon: s.icon,
                  sourceCount: s.sources.length,
                  isSelected: s.section == _selectedVideoSection,
                  accentColorOverride: AppColors.pastelMint,
                  spacing: spacing,
                  sizing: sizing,
                  typography: typography,
                  onTap: () =>
                      setState(() => _selectedVideoSection = s.section),
                ),
                SizedBox(height: spacing.xs),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.sm),
        // ── Content: selected section's items ──
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
                horizontal: spacing.contentPaddingH,
                vertical: spacing.contentPaddingV),
            itemCount: selectedData.sources.length,
            itemBuilder: (ctx, i) => VideoSourceCard(
              number: i + 1,
              video: selectedData.sources[i],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tabs Navigation Widget - extracted to reduce main rebuild impact
// ─────────────────────────────────────────────────────────────────────────────
class _SourcesScreenTabs extends StatelessWidget {
  final SourceType selectedTab;
  final Function(SourceType) onTabChanged;

  const _SourcesScreenTabs({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.tabMarginH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Segmented tab bar: Web | R | Video (connected borders) ──
                Padding(
                  padding: EdgeInsets.only(
                    top: sizing.tabMarginV,
                    bottom: spacing.tabInnerPadding,
                  ),
                  child: _buildSegmentedTabs(context, spacing, typography),
                ),
              ],
            ),
          ),
          ...GlowingHeaderSeparator.build(
            glowColor: AppColors.energy,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs(
      BuildContext context, AppSpacing spacing, AppTypography typography) {
    final webActive = selectedTab == SourceType.webLinks;
    final reportActive = selectedTab == SourceType.reportLinks;
    final videoActive = selectedTab == SourceType.videoLinks;

    final dim = Colors.white.withValues(alpha: 0.12);
    const r = AppConstants.radiusMedium;
    final vPad = spacing.tabButtonPadding.clamp(8.0, double.infinity);
    final hPad = spacing.tabButtonPadding.clamp(12.0, double.infinity);

    BorderSide side(bool active, Color color) => BorderSide(
          color: active ? color.withValues(alpha: 0.4) : dim,
        );

    Widget segment({
      required String label,
      required bool isActive,
      required Color activeColor,
      required Border border,
      required BorderRadius borderRadius,
      required VoidCallback onTap,
      double? letterSpacing,
      EdgeInsetsGeometry? customPadding,
      bool concaveRight = false,
      bool concaveLeft = false,
    }) {
      final effectivePadding = customPadding ??
          EdgeInsets.symmetric(vertical: vPad, horizontal: hPad);
      final borderColor = isActive ? activeColor.withValues(alpha: 0.4) : dim;

      if (concaveRight || concaveLeft) {
        return Semantics(
          button: true,
          label: label,
          selected: isActive,
          child: InkWell(
            onTap: onTap,
            child: CustomPaint(
              painter: _ConcaveTabPainter(
                isActive: isActive,
                activeColor: activeColor,
                borderColor: borderColor,
                concaveRight: concaveRight,
                concaveLeft: concaveLeft,
                cornerRadius: r,
              ),
              child: Padding(
                padding: effectivePadding,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: typography.tab.copyWith(
                    color: isActive ? activeColor : AppColors.textMuted,
                    letterSpacing: letterSpacing ?? 0.5,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return Semantics(
        button: true,
        label: label,
        selected: isActive,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: borderRadius,
              border: border,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.18),
                        blurRadius: 12,
                      )
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: typography.tab.copyWith(
                color: isActive ? activeColor : AppColors.textMuted,
                letterSpacing: letterSpacing ?? 0.5,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Web — left rounded, concave right border
        segment(
          label: AppLocalizations.of(context)!.sourcesTabWeb,
          isActive: webActive,
          activeColor: AppColors.pastelAqua,
          border: Border(
            top: side(webActive, AppColors.pastelAqua),
            left: side(webActive, AppColors.pastelAqua),
            bottom: side(webActive, AppColors.pastelAqua),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(r),
            bottomLeft: Radius.circular(r),
          ),
          concaveRight: true,
          onTap: () {
            onTabChanged(SourceType.webLinks);
            LoggerService()
                .logUserAction('sources_tab_switched', params: {'tab': 'web'});
          },
        ),
        // R — circle joystick
        segment(
          label: AppLocalizations.of(context)!.sourcesTabReport,
          isActive: reportActive,
          activeColor: AppColors.pastelLavender,
          border: Border.all(
            color: reportActive
                ? AppColors.pastelLavender.withValues(alpha: 0.4)
                : dim,
          ),
          borderRadius: BorderRadius.circular(999),
          letterSpacing: 1.0,
          customPadding: EdgeInsets.all(vPad),
          onTap: () {
            onTabChanged(SourceType.reportLinks);
            LoggerService().logUserAction('sources_tab_switched',
                params: {'tab': 'report'});
          },
        ),
        // Video — right rounded, concave left border
        segment(
          label: AppLocalizations.of(context)!.sourcesTabVideo,
          isActive: videoActive,
          activeColor: AppColors.pastelAqua,
          border: Border(
            top: side(videoActive, AppColors.pastelAqua),
            right: side(videoActive, AppColors.pastelAqua),
            bottom: side(videoActive, AppColors.pastelAqua),
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(r),
            bottomRight: Radius.circular(r),
          ),
          concaveLeft: true,
          concaveRight: false,
          onTap: () {
            onTabChanged(SourceType.videoLinks);
            LoggerService().logUserAction('sources_tab_switched',
                params: {'tab': 'video'});
          },
        ),
      ],
    );
  }
}

class _ConcaveTabPainter extends CustomPainter {
  const _ConcaveTabPainter({
    required this.isActive,
    required this.activeColor,
    required this.borderColor,
    required this.concaveRight,
    required this.concaveLeft,
    required this.cornerRadius,
  });

  final bool isActive;
  final Color activeColor;
  final Color borderColor;
  final bool concaveRight;
  final bool concaveLeft;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    if (isActive) {
      canvas.drawPath(
        path,
        Paint()
          ..color = activeColor.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  Path _buildPath(Size size) {
    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    // Full-height arc that always touches the top/bottom corners.
    // Depth = r pixels (same scale as corner rounding).
    // R is derived so that the arc bows inward by exactly r at its midpoint.
    final half = h / 1.8;
    final R = (r * r + half * half) / (2 * r);
    final path = Path();

    if (concaveRight) {
      // Left-rounded corners, full-height concave arc on right side
      path.moveTo(r, 0);
      path.lineTo(w, 0);
      path.arcToPoint(Offset(w, h),
          radius: Radius.circular(R), clockwise: false);
      path.lineTo(r, h);
      path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
      path.lineTo(0, r);
      path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    } else {
      // Right-rounded corners, full-height concave arc on left side
      path.moveTo(0, 0);
      path.lineTo(w - r, 0);
      path.arcToPoint(Offset(w, r), radius: Radius.circular(r));
      path.lineTo(w, h - r);
      path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
      path.lineTo(0, h);
      path.arcToPoint(Offset.zero,
          radius: Radius.circular(R), clockwise: false);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_ConcaveTabPainter old) =>
      old.isActive != isActive ||
      old.borderColor != borderColor ||
      old.activeColor != activeColor;
}
