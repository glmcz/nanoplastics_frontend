import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/app_typography.dart';
import '../widgets/nanosolve_logo.dart';
import '../widgets/brainstorm_box.dart';
import '../models/category_detail_data.dart';
import '../l10n/app_localizations.dart';
import 'pdf_viewer_screen.dart';
import '../services/logger_service.dart';
import '../services/api_service.dart';

class CategoryDetailNewScreen extends StatefulWidget {
  final CategoryDetailData categoryData;

  const CategoryDetailNewScreen({
    super.key,
    required this.categoryData,
  });

  @override
  State<CategoryDetailNewScreen> createState() =>
      _CategoryDetailNewScreenState();
}

class _CategoryDetailNewScreenState extends State<CategoryDetailNewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isSourcesExpanded = false;
  CustomTabsSession? _customTabsSession;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Warmup Custom Tabs for faster loading
    _warmupCustomTabs();

    // Log category view
    LoggerService().logScreenNavigation(
      'CategoryDetailScreen',
      params: {
        'category': widget.categoryData.title,
        'subtitle': widget.categoryData.subtitle,
      },
    );
    LoggerService().logFeatureUsage('category_detail_opened', metadata: {
      'category': widget.categoryData.title,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _warmupCustomTabs() async {
    try {
      _customTabsSession = await warmupCustomTabs();
    } catch (e) {
      debugPrint('Failed to warmup custom tabs: $e');
    }
  }

  Future<void> _preFetchUrls() async {
    if (_customTabsSession == null ||
        widget.categoryData.sourceLinks == null ||
        widget.categoryData.sourceLinks!.isEmpty) {
      return;
    }

    try {
      // Pre-fetch the first few URLs that are most likely to be opened
      final urlsToPrefetch = widget.categoryData.sourceLinks!
          .take(3)
          .map((link) => Uri.parse(link.url))
          .toList();

      for (final url in urlsToPrefetch) {
        await mayLaunchUrl(
          url,
          customTabsSession: _customTabsSession,
        );
      }
    } catch (e) {
      debugPrint('Failed to pre-fetch URLs: $e');
    }
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    // CustomTabsSession doesn't need explicit cleanup, just release reference
    _customTabsSession = null;
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
              widget.categoryData.themeColor.withValues(alpha: 0.08),
              const Color(0xFF080A10),
              const Color(0xFF0A0A14),
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
                    _buildScrollableContent(),
                    // Gradient fade at the top of scrollable area
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.categoryData.themeColor
                                  .withValues(alpha: 0.12),
                              widget.categoryData.themeColor
                                  .withValues(alpha: 0.03),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Thin glowing line separator
                    Positioned(
                      top: 0,
                      left: AppConstants.space40,
                      right: AppConstants.space40,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              widget.categoryData.themeColor
                                  .withValues(alpha: 0.75),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.categoryData.themeColor
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
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
      padding: EdgeInsets.all(spacing.contentPadding),
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
          NanosolveLogo(height: sizing.logoHeight),
        ],
      ),
    );
  }

  Widget _buildHeroIcon() {
    final sizing = AppSizing.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: sizing.heroPadding),
          child: Container(
            width: sizing.heroIconSize,
            height: sizing.heroIconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.categoryData.themeColor.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: widget.categoryData.glowColor,
                  blurRadius: 30 + (_animationController.value * 20),
                  spreadRadius: 5 + (_animationController.value * 5),
                ),
              ],
            ),
            child: Icon(
              widget.categoryData.icon,
              size: sizing.heroIconInnerSize,
              color: widget.categoryData.themeColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollableContent() {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.space20),
      child: Column(
        children: [
          SizedBox(height: spacing.headerSpacing),
          Text(
            widget.categoryData.title.toUpperCase(),
            style: typography.headline.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          _buildHeroIcon(),
          _buildInfoPanel(),
          const SizedBox(height: AppConstants.space30),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    final subtitleStyle = Theme.of(context).textTheme.headlineSmall;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F141E).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        border: Border.all(
          color: widget.categoryData.themeColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.categoryData.subtitle.toUpperCase(),
            style: subtitleStyle?.copyWith(
              color: widget.categoryData.themeColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
                top: AppConstants.space8, bottom: AppConstants.space20),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.categoryData.themeColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          ...widget.categoryData.entries.map((entry) => _buildEntry(entry)),
          if (widget.categoryData.sourceLinks != null &&
              widget.categoryData.sourceLinks!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.space20),
            _buildDivider(),
            const SizedBox(height: AppConstants.space20),
            _buildSourcesSection(),
          ],
          const SizedBox(height: AppConstants.space20),
          _buildDivider(),
          const SizedBox(height: AppConstants.space20),
          BrainstormBox(
            title: AppLocalizations.of(context)!.categoryDetailBrainstormTitle,
            username:
                AppLocalizations.of(context)!.categoryDetailBrainstormUser,
            placeholder: AppLocalizations.of(context)!
                .categoryDetailBrainstormPlaceholder,
            category: widget.categoryData.title,
            onSubmit: (text) async {
              // Log the submission attempt
              LoggerService().logIdeaSubmission(
                category: widget.categoryData.title,
                title: text,
                contentLength: text.length,
              );

              // Submit to backend
              final result = await ApiService.submitIdea(
                description: text,
                category: widget.categoryData.title,
              );

              if (!result['success']) {
                // Log error if submission failed
                LoggerService().logError(
                  'idea_submission_failed_in_ui',
                  result['message'],
                );
                throw Exception(result['message']);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isSourcesExpanded = !_isSourcesExpanded;
            });
            // Pre-fetch URLs when sources are expanded
            if (_isSourcesExpanded) {
              _preFetchUrls();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.space16),
            decoration: BoxDecoration(
              color: const Color(0xFF141928).withValues(alpha: 0.85),
              border: Border.all(
                color: AppColors.pastelAqua.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.space12),
                  decoration: BoxDecoration(
                    color: AppColors.pastelAqua.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    size: AppConstants.iconMedium,
                    color: AppColors.pastelAqua,
                  ),
                ),
                const SizedBox(width: AppConstants.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.categoryDetailSourcesTitle.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: AppConstants.space4),
                      Text(
                        '${widget.categoryData.sourceLinks!.length} ${l10n.categoryDetailSourcesCount}',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isSourcesExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.pastelAqua,
                  size: AppConstants.iconMedium,
                ),
              ],
            ),
          ),
        ),
        if (_isSourcesExpanded) ...[
          const SizedBox(height: AppConstants.space12),
          ...widget.categoryData.sourceLinks!.asMap().entries.map((entry) {
            return _buildSourceLinkCard(
              number: entry.key + 1,
              sourceLink: entry.value,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSourceLinkCard({
    required int number,
    required SourceLink sourceLink,
  }) {
    return GestureDetector(
      onTap: () => _handleSourceLink(sourceLink),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppConstants.space12),
        padding: const EdgeInsets.all(AppConstants.space16),
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
                    sourceLink.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: AppConstants.space4),
                  Text(
                    sourceLink.source,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.pastelLavender,
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                ),
                const SizedBox(height: AppConstants.space20),
                Icon(
                  Icons.open_in_new,
                  size: AppConstants.iconSmall,
                  color: AppColors.pastelAqua.withValues(alpha: 0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSourceLink(SourceLink sourceLink) async {
    // Check if this is a PDF asset link
    if (sourceLink.pdfAssetPath != null) {
      _launchPdfAsset(sourceLink);
    } else {
      // Otherwise launch as web URL
      _launchUrl(sourceLink.url);
    }
  }

  void _launchPdfAsset(SourceLink sourceLink) {
    debugPrint('📄 [PDF] Opening PDF asset: ${sourceLink.pdfAssetPath}');
    final startPage = sourceLink.pdfStartPage ?? 1;
    final endPage = sourceLink.pdfEndPage ?? 999;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          title: sourceLink.title,
          startPage: startPage,
          endPage: endPage,
          description: sourceLink.source,
          pdfAssetPath: sourceLink.pdfAssetPath!,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    debugPrint('🔗 [CustomTabs] Launching URL: $url');
    try {
      final uri = Uri.parse(url);
      debugPrint('🔗 [CustomTabs] Parsed URI: $uri');
      debugPrint('🔗 [CustomTabs] Using Firefox with Custom Tabs');

      // Add referrer to make the request look more legitimate
      final urlWithReferrer =
          '$url${url.contains('?') ? '&' : '?'}utm_source=nanoplastics_app';

      await launchUrl(
        Uri.parse(urlWithReferrer),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: const Color(0xFF0F141E),
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: false,
          showTitle: true,
          // Explicitly use Firefox to avoid detection
          browser: const CustomTabsBrowserConfiguration(
            fallbackCustomTabs: [
              'org.mozilla.firefox',
              'org.mozilla.firefox_beta',
              'com.microsoft.emmx',
            ],
          ),
        ),
        safariVCOptions: const SafariViewControllerOptions(
          preferredBarTintColor: Color(0xFF0F141E),
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
      debugPrint('🔗 [CustomTabs] URL launched successfully in Firefox');
    } catch (e) {
      debugPrint('❌ [CustomTabs] Error launching $url: $e');
    }
  }

  Widget _buildEntry(DetailEntry entry) {
    const bulletSize = 6.0;
    final highlightStyle = Theme.of(context).textTheme.titleSmall;
    final descStyle = Theme.of(context).textTheme.headlineMedium;
    const pdfIconSize = AppConstants.iconSmall;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate to PDF viewer if PDF page info is available
              if (entry.pdfStartPage != null && entry.pdfEndPage != null) {
                LoggerService().logUserAction(
                  'pdf_entry_clicked',
                  params: {
                    'category': widget.categoryData.title,
                    'entry': entry.highlight,
                    'startPage': entry.pdfStartPage,
                    'endPage': entry.pdfEndPage,
                  },
                );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PDFViewerScreen(
                      title: entry.highlight,
                      startPage: entry.pdfStartPage!,
                      endPage: entry.pdfEndPage!,
                      description:
                          entry.pdfCategory ?? widget.categoryData.title,
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.space8,
                  vertical: AppConstants.space4),
              decoration: BoxDecoration(
                color: widget.categoryData.themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(
                  color: widget.categoryData.themeColor.withValues(alpha: 0.4),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        entry.highlight.toUpperCase(),
                        style: highlightStyle?.copyWith(
                          color: widget.categoryData.themeColor,
                        ),
                      ),
                    ),
                    if (entry.pdfStartPage != null &&
                        entry.pdfEndPage != null) ...[
                      const SizedBox(width: AppConstants.space4),
                      Icon(
                        Icons.picture_as_pdf,
                        size: pdfIconSize,
                        color: widget.categoryData.themeColor
                            .withValues(alpha: 0.7),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.space8),
          Text(
            entry.description,
            style: descStyle?.copyWith(
              color: const Color(0xFFE0E0E0),
              fontWeight: FontWeight.normal,
            ),
          ),
          if (entry.bulletPoints != null && entry.bulletPoints!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.space8),
            ...entry.bulletPoints!.map((point) => Padding(
                  padding: const EdgeInsets.only(
                      left: AppConstants.space16, bottom: AppConstants.space4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            top: AppConstants.space8,
                            right: AppConstants.space8),
                        width: bulletSize,
                        height: bulletSize,
                        decoration: BoxDecoration(
                          color: widget.categoryData.themeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.categoryData.glowColor,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFFB0B0B0),
                                  ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.pastelAqua.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
