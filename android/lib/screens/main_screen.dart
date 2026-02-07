import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/responsive_config.dart';
import '../widgets/nanosolve_logo.dart';
import '../l10n/app_localizations.dart';
import '../models/category_data.dart';
import '../models/category_detail_data.dart';
import 'category_detail_new_screen.dart';
import 'sources_screen.dart';
import 'results_screen.dart';
import '../services/logger_service.dart';

enum ImpactType { human, planet }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ImpactType _selectedTab = ImpactType.human;
  late ResponsiveConfig responsive;

  @override
  Widget build(BuildContext context) {
    responsive = ResponsiveConfig.fromMediaQuery(context);
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
                _buildTopNavigation(),
                _buildHeader(),
                Expanded(
                  child: _buildCategoryGrid(),
                ),
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
    final config = responsive.getTabBarConfig();
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: config.marginH, vertical: config.marginV),
      padding: EdgeInsets.all(config.innerPadding),
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
              config: config,
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
              config: config,
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
    required TabBarConfig config,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: config.buttonPaddingV,
            horizontal: config.buttonPaddingH),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: isActive ? Border.all(color: activeColor) : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: activeColor.withValues(alpha: 0.3), blurRadius: 12)
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: config.textStyle?.copyWith(
                color: isActive ? activeColor : AppColors.textMuted,
              ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final config = responsive.getMainScreenHeaderConfig();

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: config.horizontalPadding,
          vertical: config.verticalPadding),
      child: Column(
        children: [
          NanosolveLogo(height: config.logoHeight),
          const SizedBox(height: AppConstants.space4),
          Text(
            _selectedTab == ImpactType.human ? l10n.tabHuman : l10n.tabPlanet,
            style: config.titleStyle?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppConstants.space4),
          Text(
            l10n.appSubtitle,
            style: config.subtitleStyle?.copyWith(
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

    // Build pairs of cards in rows so each row sizes to its content
    final rowCount = (categories.length / 2).ceil();
    final config = responsive.getCategoryCardConfig();

    return ListView.separated(
      padding: EdgeInsets.only(
          left: config.padding,
          right: config.padding,
          top: config.padding,
          bottom: config.gridBottomPadding),
      itemCount: rowCount,
      separatorBuilder: (_, __) => SizedBox(height: config.gridRowSpacing),
      itemBuilder: (context, rowIndex) {
        final first = rowIndex * 2;
        final second = first + 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CategoryCard(
                  category: categories[first],
                  onTap: () => _navigateToCategoryDetail(categories[first]),
                ),
              ),
              SizedBox(width: config.gridColumnSpacing),
              if (second < categories.length)
                Expanded(
                  child: _CategoryCard(
                    category: categories[second],
                    onTap: () => _navigateToCategoryDetail(categories[second]),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    final l10n = AppLocalizations.of(context)!;
    final config = responsive.bottomNavConfig;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: config.horizontalPadding, vertical: config.verticalPadding),
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
              responsive: responsive,
            ),
          ),
          SizedBox(width: config.spacing),
          Expanded(
            child: _buildBottomButton(
              label: l10n.navResults,
              icon: Icons.auto_graph_outlined,
              color: AppColors.pastelMint,
              onTap: () => _navigateToResults(),
              responsive: responsive,
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
    required ResponsiveConfig responsive,
  }) {
    final config = responsive.getBottomButtonConfig();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: config.verticalPadding,
            horizontal: config.horizontalPadding),
        decoration: BoxDecoration(
          color: const Color(0xFF141928).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, size: config.iconSize, color: color),
            SizedBox(width: config.spacing),
            Expanded(
              child: Text(
                label,
                style: config.textStyle?.copyWith(
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

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getCategoryCardConfig();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(config.padding),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: config.iconContainerSize,
              height: config.iconContainerSize,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Icon(
                category.icon,
                size: config.iconSize,
                color: category.color,
              ),
            ),
            SizedBox(height: config.spacing),
            Text(
              category.title,
              style: config.titleStyle?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppConstants.space4),
            Text(
              category.description,
              style: config.descStyle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
