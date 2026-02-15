import 'dart:ui';

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
import 'sources_screen.dart';
import 'results_screen.dart';
import 'user_settings/user_settings_screen.dart';
import '../services/logger_service.dart';
import '../services/settings_manager.dart';

enum ImpactType { human, planet }

enum _HubButtonPosition { topLeft, topRight, bottomLeft, bottomRight }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ImpactType _selectedTab = ImpactType.human;

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizing.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              _selectedTab == ImpactType.human
                  ? 'assets/images/bg_human.jpg'
                  : 'assets/images/bg_planet.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay - lighter for planet tab to show Earth image
          Positioned.fill(
            child: Container(
              color: (_selectedTab == ImpactType.planet
                  ? const Color(0xFF0A0A14).withValues(alpha: 0.70)
                  : const Color(0xFF0A0A14).withValues(alpha: 0.92)),
            ),
          ),
          // Subtle radial gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    _selectedTab == ImpactType.human
                        ? AppColors.neonCyan.withValues(alpha: 0.08)
                        : AppColors.neonOcean.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: sizing.hubContainerHeight),
                    child: _buildCategoryGrid(),
                  ),
                ),
              ],
            ),
          ),
          // Control Hub overlay at bottom
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
          NanosolveLogo(height: sizing.logoHeight),
          const SizedBox(height: AppConstants.space4),
          Text(
            _selectedTab == ImpactType.human ? l10n.tabHuman : l10n.tabPlanet,
            style: typography.display.copyWith(
                color: Colors.white, fontSize: typography.display.fontSize),
          ),
          const SizedBox(height: AppConstants.space4),
          Text(
            l10n.appSubtitle,
            style: typography.label.copyWith(
                color: AppColors.textMuted,
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

    final rows = <Widget>[];
    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      if (rowIndex > 0) {
        rows.add(SizedBox(height: spacing.gridRowSpacing));
      }
      final first = rowIndex * 2;
      final second = first + 1;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CategoryCard(
                  category: categories[first],
                  iconContainerSize: sizing.categoryIconContainer,
                  iconSize: sizing.categoryIconSize,
                  padding: sizing.categoryPadding,
                  titleStyle: typography.title,
                  descStyle: typography.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
                  onTap: () => _navigateToCategoryDetail(categories[first]),
                ),
              ),
              SizedBox(width: spacing.gridSpacing),
              if (second < categories.length)
                Expanded(
                  child: _CategoryCard(
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
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: spacing.md * 1.5,
        right: spacing.md * 1.5,

        /// TODO refactor me.
        top: spacing.md * 2.0,
        bottom: spacing.md,
      ),
      child: Column(children: rows),
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
                            children: [
                              Expanded(
                                child: _HubButton(
                                  label: l10n.tabHuman,
                                  icon: Icons.person_outline,
                                  position: _HubButtonPosition.topLeft,
                                  isActive: _selectedTab == ImpactType.human,
                                  activeColor: AppColors.neonCyan,
                                  textStyle: typography.hubLabel,
                                  iconSize: sizing.hubButtonIconSize,
                                  activeGlowBlur: sizing.hubActiveGlowBlur,
                                  internalGap: spacing.hubButtonGap,
                                  onTap: () {
                                    setState(
                                        () => _selectedTab = ImpactType.human);
                                    LoggerService().logUserAction(
                                        'tab_switched',
                                        params: {'tab': 'human'});
                                  },
                                ),
                              ),
                              SizedBox(width: spacing.hubGridGap),
                              Expanded(
                                child: _HubButton(
                                  label: l10n.tabPlanet,
                                  icon: Icons.public_outlined,
                                  position: _HubButtonPosition.topRight,
                                  isActive: _selectedTab == ImpactType.planet,
                                  activeColor: AppColors.neonOcean,
                                  textStyle: typography.hubLabel,
                                  iconSize: sizing.hubButtonIconSize,
                                  activeGlowBlur: sizing.hubActiveGlowBlur,
                                  internalGap: spacing.hubButtonGap,
                                  onTap: () {
                                    setState(
                                        () => _selectedTab = ImpactType.planet);
                                    LoggerService().logUserAction(
                                        'tab_switched',
                                        params: {'tab': 'planet'});
                                  },
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
                                child: _HubButton(
                                  label: l10n.navSources,
                                  icon: Icons.menu_book_outlined,
                                  position: _HubButtonPosition.bottomLeft,
                                  isActive: false,
                                  activeColor: AppColors.pastelAqua,
                                  textStyle: typography.hubLabel,
                                  iconSize: sizing.hubButtonIconSize,
                                  activeGlowBlur: sizing.hubActiveGlowBlur,
                                  internalGap: spacing.hubButtonGap,
                                  onTap: () => _navigateToResources(null),
                                ),
                              ),
                              SizedBox(width: spacing.hubGridGap),
                              Expanded(
                                child: _HubButton(
                                  label: l10n.navResults,
                                  icon: Icons.auto_graph_outlined,
                                  position: _HubButtonPosition.bottomRight,
                                  isActive: false,
                                  activeColor: AppColors.pastelMint,
                                  textStyle: typography.hubLabel,
                                  iconSize: sizing.hubButtonIconSize,
                                  activeGlowBlur: sizing.hubActiveGlowBlur,
                                  internalGap: spacing.hubButtonGap,
                                  onTap: () => _navigateToResults(),
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
          child: Icon(
            Icons.settings,
            size: sizing.hubKnobIconSize,
            color: Colors.white,
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
        builder: (_) => const SourcesScreen(),
      ),
    );
  }

  void _navigateToResults() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ResultsScreen(),
      ),
    );
  }
}

// ── Hub Button ──

class _HubButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final _HubButtonPosition position;
  final bool isActive;
  final Color activeColor;
  final TextStyle textStyle;
  final double iconSize;
  final double activeGlowBlur;
  final double internalGap;
  final VoidCallback onTap;

  const _HubButton({
    required this.label,
    required this.icon,
    required this.position,
    required this.isActive,
    required this.activeColor,
    required this.textStyle,
    required this.iconSize,
    required this.activeGlowBlur,
    required this.internalGap,
    required this.onTap,
  });

  BorderRadius get _borderRadius {
    const sharp = Radius.circular(AppConstants.radiusSharp);
    const inner = Radius.circular(AppConstants.radiusHubInner);
    switch (position) {
      case _HubButtonPosition.topLeft:
        return const BorderRadius.only(
          topLeft: sharp,
          topRight: sharp,
          bottomLeft: sharp,
          bottomRight: inner,
        );
      case _HubButtonPosition.topRight:
        return const BorderRadius.only(
          topLeft: sharp,
          topRight: sharp,
          bottomLeft: inner,
          bottomRight: sharp,
        );
      case _HubButtonPosition.bottomLeft:
        return const BorderRadius.only(
          topLeft: sharp,
          topRight: inner,
          bottomLeft: sharp,
          bottomRight: sharp,
        );
      case _HubButtonPosition.bottomRight:
        return const BorderRadius.only(
          topLeft: inner,
          topRight: sharp,
          bottomLeft: sharp,
          bottomRight: sharp,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = _borderRadius;

    return Semantics(
      button: true,
      label: label,
      selected: isActive,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withValues(alpha: 0.15)
                    : AppColors.hubButtonBg.withValues(alpha: 0.7),
                borderRadius: borderRadius,
                border: Border.all(
                  color: isActive
                      ? activeColor
                      : Colors.white.withValues(alpha: 0.08),
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.15),
                          blurRadius: activeGlowBlur,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isActive
                      ? Icon(icon, size: iconSize, color: activeColor)
                      : Opacity(
                          opacity: 0.6,
                          child: Icon(
                            icon,
                            size: iconSize,
                            color: AppColors.hubTextInactive,
                          ),
                        ),
                  SizedBox(height: internalGap),
                  Text(
                    label.toUpperCase(),
                    style: textStyle.copyWith(
                      color:
                          isActive ? Colors.white : AppColors.hubTextInactive,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Category Card ──

class _CategoryCard extends StatelessWidget {
  final CategoryData category;
  final VoidCallback onTap;
  final double iconContainerSize;
  final double iconSize;
  final double padding;
  final TextStyle titleStyle;
  final TextStyle descStyle;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.iconContainerSize,
    required this.iconSize,
    required this.padding,
    required this.titleStyle,
    required this.descStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: category.title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: AppColors.cardBgGlass.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Icon(
                      category.icon,
                      size: iconSize,
                      color: category.color,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space4),
                  Text(
                    category.title,
                    style: titleStyle.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.space4),
                  Text(
                    category.description,
                    style: descStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
