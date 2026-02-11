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

enum ImpactType { human, planet }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ImpactType _selectedTab = ImpactType.human;

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
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
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: spacing.md),
                    child: _buildCategoryGrid(),
                  ),
                ),
                _buildTopNavigation(),
                _buildBottomNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    return Container(
      margin: EdgeInsets.only(
        left: spacing.tabMarginH,
        right: spacing.tabMarginH,
        top: spacing.tabMarginH,
        bottom: sizing.tabMarginV,
      ),
      padding: EdgeInsets.all(spacing.tabInnerPadding),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: l10n.tabHuman,
              isActive: _selectedTab == ImpactType.human,
              activeColor: AppColors.neonCyan,
              textStyle: typography.tab,
              padding: spacing.tabButtonPadding,
              onTap: () {
                setState(() => _selectedTab = ImpactType.human);
                LoggerService()
                    .logUserAction('tab_switched', params: {'tab': 'human'});
              },
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: l10n.tabPlanet,
              isActive: _selectedTab == ImpactType.planet,
              activeColor: const Color(0xFF48CAE4),
              textStyle: typography.tab,
              padding: spacing.tabButtonPadding,
              onTap: () {
                setState(() => _selectedTab = ImpactType.planet);
                LoggerService()
                    .logUserAction('tab_switched', params: {'tab': 'planet'});
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
    required Color activeColor,
    required VoidCallback onTap,
    required TextStyle textStyle,
    required double padding,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            border: isActive ? Border.all(color: activeColor) : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: activeColor.withValues(alpha: 0.3),
                        blurRadius: 12)
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textStyle.copyWith(
              color: isActive ? activeColor : AppColors.textMuted,
            ),
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
          horizontal: spacing.contentPadding, vertical: spacing.headerPadding),
      child: Column(
        children: [
          NanosolveLogo(height: sizing.logoHeight),
          const SizedBox(height: AppConstants.space4),
          Text(
            _selectedTab == ImpactType.human ? l10n.tabHuman : l10n.tabPlanet,
            style: typography.display.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppConstants.space4),
          Text(
            l10n.appSubtitle,
            style: typography.label.copyWith(
              color: AppColors.textMuted,
            ),
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

    // Build pairs of cards in rows so each row sizes to its content
    final rowCount = (categories.length / 2).ceil();

    final rows = <Widget>[];
    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      if (rowIndex > 0) {
        rows.add(SizedBox(height: spacing.gridSpacing));
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
                  spacing: spacing.cardSpacing,
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
                    spacing: spacing.cardSpacing,
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
        left: spacing.contentPadding,
        right: spacing.contentPadding,
        top: spacing.md,
        bottom: spacing.gridBottomPadding,
      ),
      child: Column(children: rows),
    );
  }

  Widget _buildSettingsJoystick() {
    final accentColor = _selectedTab == ImpactType.human
        ? AppColors.neonCyan
        : const Color(0xFF48CAE4);
    final sizing = AppSizing.of(context);

    return Transform.translate(
      offset: const Offset(0, 0),
      child: Center(
        child: Semantics(
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
            borderRadius: BorderRadius.circular(sizing.joystickSize / 2),
            child: Container(
              width: sizing.joystickSize,
              height: sizing.joystickSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF141928),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.5),
                  width: sizing.joystickBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: sizing.joystickShadowBlur,
                    spreadRadius: sizing.joystickShadowSpread,
                  ),
                ],
              ),
              child: Icon(
                Icons.settings,
                size: sizing.joystickIconSize,
                color: accentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.bottomNavPaddingH, vertical: spacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF0A0A14).withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBottomButton(
              label: l10n.navSources,
              icon: Icons.menu_book_outlined,
              color: AppColors.pastelAqua,
              onTap: () => _navigateToResources(null),
              typography: typography,
            ),
          ),
          SizedBox(width: spacing.bottomNavSpacing * 0.5),
          _buildSettingsJoystick(),
          SizedBox(width: spacing.bottomNavSpacing * 0.5),
          Expanded(
            child: _buildBottomButton(
              label: l10n.navResults,
              icon: Icons.auto_graph_outlined,
              color: AppColors.pastelMint,
              onTap: () => _navigateToResults(),
              typography: typography,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required AppTypography typography,
  }) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: sizing.bottomButtonPaddingV,
              horizontal: spacing.bottomButtonPaddingH),
          decoration: BoxDecoration(
            color: const Color(0xFF141928).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, size: sizing.bottomButtonIconSize, color: color),
              SizedBox(width: spacing.bottomButtonSpacing),
              Expanded(
                child: Text(
                  label,
                  style: typography.label.copyWith(
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategoryDetail(CategoryData category) {
    final l10n = AppLocalizations.of(context)!;
    CategoryDetailData? detailData;

    // Map category to detail data
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
      final data = detailData; // Shadow to non-nullable for use in closure
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

class _CategoryCard extends StatelessWidget {
  final CategoryData category;
  final VoidCallback onTap;
  final double iconContainerSize;
  final double iconSize;
  final double padding;
  final double spacing;
  final TextStyle titleStyle;
  final TextStyle descStyle;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.iconContainerSize,
    required this.iconSize,
    required this.padding,
    required this.spacing,
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
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(
                  category.icon,
                  size: iconSize,
                  color: category.color,
                ),
              ),
              SizedBox(height: spacing),
              Text(
                category.title,
                style: titleStyle.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppConstants.space4),
              Text(
                category.description,
                style: descStyle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
