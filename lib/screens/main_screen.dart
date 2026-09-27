import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/app_typography.dart';
import '../widgets/nanosolve_logo.dart';
import '../l10n/app_localizations.dart';
import '../models/category_data.dart';
import '../models/category_detail_data.dart';
import 'category_detail_new_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'sources_screen.dart';
import 'web/web_sources_screen.dart';
import 'solvers_leaderboard_screen.dart';
import 'user_settings/user_settings_screen.dart';
import '../services/logger_service.dart';
import '../services/extended_tour_service.dart';
import '../services/service_locator.dart';
import '../services/settings_manager.dart';
import '../services/update_service.dart';
import '../utils/app_theme_colors.dart';
import '../utils/platform_adaptive.dart';
import '../utils/responsive_config.dart';
import '../widgets/hub/category_card.dart';
import '../widgets/hub/desktop_action_button.dart';
import '../widgets/hub/desktop_nav_tile.dart';
import '../widgets/hub/hub_button.dart';

enum ImpactType { human, planet }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ImpactType _selectedTab = ImpactType.human;

  // Update service listener — refreshes badge when update state changes
  late final Function(UpdateState, double) _updateStateListener;

  // Tour GlobalKeys — each key is attached to the widget that the tour spotlights
  final GlobalKey _tourLogoKey = GlobalKey(debugLabel: 'tour_logo');
  final GlobalKey _tourCategoryGridKey =
      GlobalKey(debugLabel: 'tour_category_grid');
  final GlobalKey _tourHumanButtonKey = GlobalKey(debugLabel: 'tour_human');
  final GlobalKey _tourPlanetButtonKey = GlobalKey(debugLabel: 'tour_planet');
  final GlobalKey _tourHumanPlanetRowKey =
      GlobalKey(debugLabel: 'tour_human_planet_row');
  final GlobalKey _tourSourcesButtonKey = GlobalKey(debugLabel: 'tour_sources');
  final GlobalKey _tourResultsButtonKey = GlobalKey(debugLabel: 'tour_results');
  final GlobalKey _tourCenterKnobKey = GlobalKey(debugLabel: 'tour_knob');

  @override
  void initState() {
    super.initState();
    _updateStateListener = (_, __) {
      if (mounted) setState(() {});
    };
    // Store builds inject NoOpUpdateService — no state changes to listen for.
    if (ServiceLocator().updateService.isEnabled) {
      ServiceLocator().updateService.addStateListener(_updateStateListener);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLaunchTour());
  }

  @override
  void dispose() {
    if (ServiceLocator().updateService.isEnabled) {
      ServiceLocator().updateService.removeStateListener(_updateStateListener);
    }
    super.dispose();
  }

  Future<void> _maybeLaunchTour() async {
    if (!mounted) return;
    // Use extended tour service for multi-screen guided tour
    await ExtendedTourService.showIfNeeded(
      context,
      ExtendedTourKeys(
        logoKey: _tourLogoKey,
        categoryGridKey: _tourCategoryGridKey,
        humanButtonKey: _tourHumanButtonKey,
        planetButtonKey: _tourPlanetButtonKey,
        humanPlanetRowKey: _tourHumanPlanetRowKey,
        sourcesButtonKey: _tourSourcesButtonKey,
        resultsButtonKey: _tourResultsButtonKey,
        centerKnobKey: _tourCenterKnobKey,
      ),
      onSwitchToHuman: () => _switchTab(ImpactType.human),
    );
  }

  /// Switch between Human and Planet tabs during tour
  void _switchTab(ImpactType tab) {
    if (mounted) {
      setState(() {
        _selectedTab = tab;
      });
    }
  }

  bool _isUpdateAvailable() {
    try {
      final updateService = ServiceLocator().updateService;
      // Store builds: self-update disabled entirely, never show the badge.
      if (!updateService.isEnabled) return false;
      final settingsManager = SettingsManager();
      // Check runtime state OR persisted flag (survives app restarts)
      final hasUpdate = updateService.currentState == UpdateState.available ||
          settingsManager.updateAvailable;
      return hasUpdate && settingsManager.pushNotificationsEnabled;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizing.of(context);
    final responsive = ResponsiveConfig.fromContext(context);
    final isDesktop = PlatformAdaptive.isDesktop(context);

    // Responsive background offset and scale
    final humanOffset = responsive.isBig ? -80.0 : -120.0;
    final humanScale = responsive.isBig ? 1.0 : 1.1;
    final planetOffset = responsive.isBig ? -30.0 : -50.0;
    final planetScale = responsive.isBig ? 0.9 : 1.0;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: _selectedTab == ImpactType.human
                ? Transform.translate(
                    offset: Offset(0, humanOffset),
                    child: Transform.scale(
                      scale: humanScale,
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'assets/images/bg_human.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Transform.translate(
                    offset: Offset(0, planetOffset),
                    child: Transform.scale(
                      scale: planetScale,
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'assets/images/bg_planet.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          // Overlay - varies by tab
          Positioned.fill(
            child: _selectedTab == ImpactType.human
                ? Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.3,
                        colors: [
                          AppThemeColors.of(context).pageBackground.withValues(
                              alpha: AppThemeColors.of(context)
                                      .backgroundOverlayAlpha *
                                  0.7),
                          AppThemeColors.of(context).pageBackground.withValues(
                              alpha: AppThemeColors.of(context)
                                  .backgroundOverlayAlpha),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  )
                : Container(
                    color: AppThemeColors.of(context).pageBackground.withValues(
                        alpha:
                            AppThemeColors.of(context).backgroundOverlayAlpha),
                  ),
          ),
          // Main content
          if (isDesktop)
            _buildDesktopShell()
          else
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: sizing.hubContainerHeight,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: (constraints.maxHeight -
                                      sizing.hubContainerHeight)
                                  .clamp(0, double.infinity),
                            ),
                            child: _buildCategoryGrid(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!isDesktop)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildControlHub(),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopShell() {
    final spacing = AppSpacing.of(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: PlatformAdaptive.contentMaxWidth(context),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.xl2,
              vertical: spacing.lg,
            ),
            child: Column(
              children: [
                _buildDesktopHeader(),
                SizedBox(height: spacing.lg),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 300,
                        child: _buildDesktopSidebar(),
                      ),
                      SizedBox(width: spacing.lg),
                      Expanded(
                        child: _buildDesktopWorkspace(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final themeColors = AppThemeColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBgGlass.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const NanosolveLogo(height: 56),
          SizedBox(width: spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTab == ImpactType.human
                      ? l10n.tabHuman
                      : l10n.tabPlanet,
                  style: typography.display.copyWith(
                    color: themeColors.textMain,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  l10n.appSubtitle,
                  style: typography.body.copyWith(
                    color: themeColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          DesktopActionButton(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isHighlighted: _isUpdateAvailable(),
            onTap: () {
              LoggerService().logUserAction('settings_tapped');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UserSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final themeColors = AppThemeColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBgGlass.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: typography.label.copyWith(
              color: themeColors.textMuted,
            ),
          ),
          SizedBox(height: spacing.sm),
          DesktopNavTile(
            label: l10n.tabHuman,
            icon: Icons.person_outline,
            color: AppColors.neonCyan,
            isActive: _selectedTab == ImpactType.human,
            onTap: () => _switchTab(ImpactType.human),
          ),
          SizedBox(height: spacing.sm),
          DesktopNavTile(
            label: l10n.tabPlanet,
            icon: Icons.public_outlined,
            color: AppColors.neonOcean,
            isActive: _selectedTab == ImpactType.planet,
            onTap: () => _switchTab(ImpactType.planet),
          ),
          SizedBox(height: spacing.lg),
          Text(
            'Workspace',
            style: typography.label.copyWith(
              color: themeColors.textMuted,
            ),
          ),
          SizedBox(height: spacing.sm),
          DesktopNavTile(
            label: l10n.navSources,
            icon: Icons.menu_book_outlined,
            color: AppColors.pastelAqua,
            isActive: false,
            onTap: () => _navigateToResources(null),
          ),
          SizedBox(height: spacing.sm),
          DesktopNavTile(
            label: l10n.navResults,
            icon: Icons.auto_graph_outlined,
            color: AppColors.pastelMint,
            isActive: false,
            onTap: _navigateToResults,
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desktop web mode',
                  style: typography.title.copyWith(
                    color: themeColors.textMain,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'Links open in a new browser tab and the main workspace stays focused on research flow.',
                  style: typography.bodySm.copyWith(
                    color: themeColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopWorkspace() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final themeColors = AppThemeColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBgGlass.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(spacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (_selectedTab == ImpactType.human
                            ? AppColors.neonCyan
                            : AppColors.neonOcean)
                        .withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTab == ImpactType.human
                              ? l10n.tabHuman
                              : l10n.tabPlanet,
                          style: typography.display.copyWith(
                            color: themeColors.textMain,
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          'Choose a domain and jump straight into evidence, sources, and idea generation from a desktop-friendly workspace.',
                          style: typography.body.copyWith(
                            color: themeColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.lg),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLarge),
                    ),
                    child: Text(
                      '${(_selectedTab == ImpactType.human ? _getHumanCategories(l10n) : _getPlanetCategories(l10n)).length} research paths',
                      style: typography.label.copyWith(
                        color: themeColors.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.lg),
            _buildCategoryGrid(),
          ],
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
        children: [
          NanosolveLogo(key: _tourLogoKey, height: sizing.logoHeightLg),
          const SizedBox(height: AppConstants.space4),
          Text(
            _selectedTab == ImpactType.human ? l10n.tabHuman : l10n.tabPlanet,
            style: typography.display.copyWith(
                color: AppThemeColors.of(context).textMain,
                fontSize: typography.display.fontSize),
          ),
          const SizedBox(height: AppConstants.space4),
          Text(
            l10n.appSubtitle,
            style: typography.label.copyWith(
                color: AppThemeColors.of(context).textMuted,
                fontSize: typography.label.fontSize),
          ),
        ],
      ),
    );
  }

  List<CategoryData> _getHumanCategories(AppLocalizations l10n) {
    return [
      CategoryData(
        id: 'human_central',
        title: l10n.humanCategoryCentralSystems,
        description: l10n.humanCategoryCentralSystemsDesc,
        icon: Icons.psychology_outlined,
        color: AppColors.neonCyan,
      ),
      CategoryData(
        id: 'human_detox',
        title: l10n.humanCategoryFiltrationDetox,
        description: l10n.humanCategoryFiltrationDetoxDesc,
        icon: Icons.water_drop_outlined,
        color: AppColors.neonLime,
      ),
      CategoryData(
        id: 'human_vitality',
        title: l10n.humanCategoryVitalityTissue,
        description: l10n.humanCategoryVitalityTissueDesc,
        icon: Icons.favorite_outline,
        color: AppColors.neonCrimson,
      ),
      CategoryData(
        id: 'human_reproduction',
        title: l10n.humanCategoryReproduction,
        description: l10n.humanCategoryReproductionDesc,
        icon: Icons.child_care_outlined,
        color: AppColors.neonViolet,
      ),
      CategoryData(
        id: 'human_entry',
        title: l10n.humanCategoryEntryGates,
        description: l10n.humanCategoryEntryGatesDesc,
        icon: Icons.air_outlined,
        color: AppColors.neonOrange,
      ),
      CategoryData(
        id: 'human_ways_of_destruction',
        title: l10n.humanCategoryWaysOfDesctruction,
        description: l10n.humanCategoryWaysOfDesctructionDesc,
        icon: Icons.science_outlined,
        color: AppColors.neonWhite,
      ),
    ];
  }

  List<CategoryData> _getPlanetCategories(AppLocalizations l10n) {
    return [
      CategoryData(
        id: 'planet_ocean',
        title: l10n.planetCategoryWorldOcean,
        description: l10n.planetCategoryWorldOceanDesc,
        icon: Icons.waves_outlined,
        color: AppColors.neonOcean,
      ),
      CategoryData(
        id: 'planet_atmosphere',
        title: l10n.planetCategoryAtmosphere,
        description: l10n.planetCategoryAtmosphereDesc,
        icon: Icons.cloud_outlined,
        color: AppColors.neonAtmos,
      ),
      CategoryData(
        id: 'planet_bio',
        title: l10n.planetCategoryFloraFauna,
        description: l10n.planetCategoryFloraFaunaDesc,
        icon: Icons.nature_outlined,
        color: AppColors.neonBio,
      ),
      CategoryData(
        id: 'planet_magnetic',
        title: l10n.planetCategoryMagneticField,
        description: l10n.planetCategoryMagneticFieldDesc,
        icon: Icons.explore_outlined,
        color: AppColors.neonMagma,
      ),
      CategoryData(
        id: 'planet_entry',
        title: l10n.planetCategoryEntryGates,
        description: l10n.planetCategoryEntryGatesDesc,
        icon: Icons.delete_outline,
        color: AppColors.neonSource,
      ),
      CategoryData(
        id: 'planet_physical',
        title: l10n.planetCategoryPhysicalProperties,
        description: l10n.planetCategoryPhysicalPropertiesDesc,
        icon: Icons.hub_outlined,
        color: AppColors.neonPhysics,
      ),
    ];
  }

  Widget _buildCategoryGrid() {
    final l10n = AppLocalizations.of(context)!;
    final categories = _selectedTab == ImpactType.human
        ? _getHumanCategories(l10n)
        : _getPlanetCategories(l10n);
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    final rowCount = (categories.length / 2).ceil();
    const rowGap = 8.0;

    Widget buildRows(double? rowHeight) {
      final rows = <Widget>[];
      for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
        if (rowIndex > 0) {
          rows.add(const SizedBox(height: rowGap));
        }
        final first = rowIndex * 2;
        final second = first + 1;
        Widget row = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CategoryCard(
                category: categories[first],
                iconContainerSize: sizing.categoryIconContainer,
                iconSize: sizing.categoryIconSize,
                padding: sizing.categoryPadding,
                titleStyle: typography.title,
                descStyle: typography.bodySm.copyWith(
                  color: AppThemeColors.of(context).textMuted,
                ),
                onTap: () => _navigateToCategoryDetail(categories[first]),
              ),
            ),
            SizedBox(width: spacing.gridSpacing),
            if (second < categories.length)
              Expanded(
                child: CategoryCard(
                  category: categories[second],
                  iconContainerSize: sizing.categoryIconContainer,
                  iconSize: sizing.categoryIconSize,
                  padding: sizing.categoryPadding,
                  titleStyle: typography.title,
                  descStyle: typography.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
                  onTap: () => _navigateToCategoryDetail(categories[second]),
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        );
        rows.add(
          rowHeight != null
              ? SizedBox(height: rowHeight, child: row)
              : IntrinsicHeight(child: row),
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      );
    }

    final responsive = ResponsiveConfig.fromContext(context);
    if (PlatformAdaptive.isDesktop(context)) {
      return _buildDesktopCategoryGrid(categories);
    }
    final topPadding =
        responsive.isCompact ? spacing.md * 0.8 : spacing.md * 2.0;
    return Padding(
      key: _tourCategoryGridKey,
      padding: EdgeInsets.only(
        left: spacing.md,
        right: spacing.md,
        top: topPadding,
        bottom: spacing.md * 0.7,
      ),
      child: LayoutBuilder(
        builder: (context, lc) {
          final available = lc.minHeight;
          if (available > 0) {
            final totalGaps = (rowCount - 1) * rowGap;
            final rowHeight = ((available - totalGaps) / rowCount)
                .clamp(AppConstants.categoryCardMinHeight, double.infinity);
            return buildRows(rowHeight);
          }
          // Fallback for tests where minHeight is not propagated.
          return buildRows(null);
        },
      ),
    );
  }

  Widget _buildDesktopCategoryGrid(List<CategoryData> categories) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1240 ? 3 : 2;
        final gap = spacing.md;
        final cardWidth = (width - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: categories
              .map(
                (category) => SizedBox(
                  width: cardWidth,
                  child: CategoryCard(
                    category: category,
                    iconContainerSize: sizing.categoryIconContainer * 1.3,
                    iconSize: sizing.categoryIconSize * 1.2,
                    padding: sizing.categoryPadding * 2.2,
                    titleStyle: typography.title.copyWith(
                      fontSize: (typography.title.fontSize ?? 17) * 1.08,
                    ),
                    descStyle: typography.body.copyWith(
                      color: AppThemeColors.of(context).textMuted,
                    ),
                    onTap: () => _navigateToCategoryDetail(category),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  // ── Control Hub ──

  Widget _buildControlHub() {
    final sizing = AppSizing.of(context);
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: sizing.hubContainerHeight,
      child: Stack(
        children: [
          // Gradient background - passes touches through
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.hubBackground.withValues(alpha: 0.95),
                      AppColors.hubBackground,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Interactive button grid
          Positioned(
            left: 0,
            right: 0,
            bottom: sizing.hubBottomPadding,
            child: Center(
              child: SizedBox(
                width: sizing.hubGridWidth,
                height: sizing.hubGridHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 2x2 button grid
                    Column(
                      children: [
                        // Top row: Human | Planet
                        Expanded(
                          child: Row(
                            key: _tourHumanPlanetRowKey,
                            children: [
                              Expanded(
                                child: KeyedSubtree(
                                  key: _tourHumanButtonKey,
                                  child: HubButton(
                                    buttonKey:
                                        const ValueKey('hub-button-human'),
                                    label: l10n.tabHuman,
                                    icon: Icons.person_outline,
                                    position: HubButtonPosition.topLeft,
                                    isActive: _selectedTab == ImpactType.human,
                                    activeColor: AppColors.neonCyan,
                                    textStyle: typography.hubLabel,
                                    iconSize: sizing.hubButtonIconSize,
                                    activeGlowBlur: sizing.hubActiveGlowBlur,
                                    internalGap: spacing.hubButtonGap,
                                    onTap: () {
                                      setState(() =>
                                          _selectedTab = ImpactType.human);
                                      LoggerService().logUserAction(
                                          'tab_switched',
                                          params: {'tab': 'human'});
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: spacing.hubGridGap),
                              Expanded(
                                child: KeyedSubtree(
                                  key: _tourPlanetButtonKey,
                                  child: HubButton(
                                    buttonKey:
                                        const ValueKey('hub-button-planet'),
                                    label: l10n.tabPlanet,
                                    icon: Icons.public_outlined,
                                    position: HubButtonPosition.topRight,
                                    isActive: _selectedTab == ImpactType.planet,
                                    activeColor: AppColors.neonOcean,
                                    textStyle: typography.hubLabel,
                                    iconSize: sizing.hubButtonIconSize,
                                    activeGlowBlur: sizing.hubActiveGlowBlur,
                                    internalGap: spacing.hubButtonGap,
                                    onTap: () {
                                      setState(() =>
                                          _selectedTab = ImpactType.planet);
                                      LoggerService().logUserAction(
                                          'tab_switched',
                                          params: {'tab': 'planet'});
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: spacing.hubGridGap),
                        // Bottom row: Sources | Results
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: KeyedSubtree(
                                  key: _tourSourcesButtonKey,
                                  child: HubButton(
                                    buttonKey:
                                        const ValueKey('hub-button-sources'),
                                    label: l10n.navSources,
                                    icon: Icons.menu_book_outlined,
                                    position: HubButtonPosition.bottomLeft,
                                    isActive: false,
                                    activeColor: AppColors.pastelAqua,
                                    textStyle: typography.hubLabel,
                                    iconSize: sizing.hubButtonIconSize,
                                    activeGlowBlur: sizing.hubActiveGlowBlur,
                                    internalGap: spacing.hubButtonGap,
                                    onTap: () => _navigateToResources(null),
                                  ),
                                ),
                              ),
                              SizedBox(width: spacing.hubGridGap),
                              Expanded(
                                child: KeyedSubtree(
                                  key: _tourResultsButtonKey,
                                  child: HubButton(
                                    buttonKey:
                                        const ValueKey('hub-button-results'),
                                    label: l10n.navResults,
                                    icon: Icons.auto_graph_outlined,
                                    position: HubButtonPosition.bottomRight,
                                    isActive: false,
                                    activeColor: AppColors.pastelMint,
                                    textStyle: typography.hubLabel,
                                    iconSize: sizing.hubButtonIconSize,
                                    activeGlowBlur: sizing.hubActiveGlowBlur,
                                    internalGap: spacing.hubButtonGap,
                                    onTap: () => _navigateToResults(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Center settings knob
                    Positioned.fill(
                      child: Center(
                        child: _buildCenterKnob(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterKnob() {
    final sizing = AppSizing.of(context);

    return Semantics(
      key: _tourCenterKnobKey,
      button: true,
      label: 'Settings',
      child: InkWell(
        onTap: () {
          LoggerService().logUserAction('settings_tapped');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const UserSettingsScreen(),
            ),
          );
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: sizing.hubKnobSize,
          height: sizing.hubKnobSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.hubKnobBg,
            border: Border.all(
              color: AppColors.hubBackground,
              width: sizing.hubKnobBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 0,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.settings,
                size: sizing.hubKnobIconSize,
                color: Colors.white,
              ),
              // Update available badge
              if (_isUpdateAvailable())
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: sizing.iconSm,
                    height: sizing.iconSm,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navigation ──

  void _navigateToCategoryDetail(CategoryData category) {
    final l10n = AppLocalizations.of(context)!;
    CategoryDetailData? detailData;

    switch (category.id) {
      case 'human_central':
        detailData = CategoryDetailDataFactory.centralSystems(l10n);
        break;
      case 'human_detox':
        detailData = CategoryDetailDataFactory.filtrationDetox(l10n);
        break;
      case 'human_vitality':
        detailData = CategoryDetailDataFactory.vitalityTissues(l10n);
        break;
      case 'human_reproduction':
        detailData = CategoryDetailDataFactory.reproduction(l10n);
        break;
      case 'human_entry':
        detailData = CategoryDetailDataFactory.entryGates(l10n);
        break;
      case 'human_ways_of_destruction':
        detailData = CategoryDetailDataFactory.physicalAttack(l10n);
        break;
      case 'planet_ocean':
        detailData = CategoryDetailDataFactory.worldOcean(l10n);
        break;
      case 'planet_atmosphere':
        detailData = CategoryDetailDataFactory.atmosphere(l10n);
        break;
      case 'planet_bio':
        detailData = CategoryDetailDataFactory.florFauna(l10n);
        break;
      case 'planet_magnetic':
        detailData = CategoryDetailDataFactory.magneticField(l10n);
        break;
      case 'planet_entry':
        detailData = CategoryDetailDataFactory.planetEntryGates(l10n);
        break;
      case 'planet_physical':
        detailData = CategoryDetailDataFactory.physicalProperties(l10n);
        break;
    }

    if (detailData != null) {
      final data = detailData;
      LoggerService().logUserAction('category_card_tapped', params: {
        'category': category.title,
        'subtitle': data.subtitle,
      });
      LoggerService().logScreenNavigation('CategoryDetailScreen', params: {
        'category': data.title,
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategoryDetailNewScreen(categoryData: data),
        ),
      );
    }
  }

  void _navigateToResources(CategoryData? category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            kIsWeb ? const WebSourcesScreen() : const SourcesScreen(),
      ),
    );
  }

  void _navigateToResults() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SolversLeaderboardScreen(),
      ),
    );
  }
}
