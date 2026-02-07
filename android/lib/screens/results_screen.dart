import 'package:flutter/material.dart';
import 'dart:ui';
import '../l10n/app_localizations.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/responsive_config.dart';
import '../widgets/nanosolve_logo.dart';
import 'solvers_leaderboard_screen.dart';
import 'user_settings/user_settings_screen.dart';
import '../services/logger_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    LoggerService().logScreenNavigation('ResultsScreen');
    LoggerService().logFeatureUsage('results_screen_opened', metadata: {
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
              AppColors.pastelMint.withValues(alpha: 0.05),
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
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.resultsBackButton,
                    style: header.backStyle?.copyWith(
                      color: AppColors.pastelMint,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.auto_graph_outlined,
                      size: header.iconSize,
                      color: AppColors.pastelMint,
                    ),
                    SizedBox(width: header.spacing),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const UserSettingsScreen(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.settings,
                        size: header.iconSize,
                        color: AppColors.pastelMint,
                      ),
                    ),
                  ],
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

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getResultsScreenConfig();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: config.contentHorizontalPadding,
          vertical: config.contentVerticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTitleSection(l10n, config),
          SizedBox(height: config.sectionSpacing),
          _buildStatsCard(
            title: l10n.resultsStatsTotalIdeas,
            value: '7',
            icon: Icons.lightbulb_outline,
            color: AppColors.pastelLavender,
            config: config,
          ),
          SizedBox(height: config.cardSpacing),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SolversLeaderboardScreen(),
                ),
              );
            },
            child: _buildStatsCard(
              title: l10n.resultsStatsActiveSolvers,
              value: '22',
              icon: Icons.people_outline,
              color: AppColors.pastelMint,
              config: config,
            ),
          ),
          SizedBox(height: config.sectionSpacing),
          _buildInfoPanel(l10n, config),
        ],
      ),
    );
  }

  Widget _buildTitleSection(AppLocalizations l10n, ResultsScreenConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelMint, AppColors.pastelAqua],
          ).createShader(bounds),
          child: Text(
            l10n.resultsTitle,
            style: config.titleStyle?.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: config.titleSpacing),
        Text(
          l10n.resultsSubtitle,
          style: config.subtitleStyle?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ResultsScreenConfig config,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: config.contentHorizontalPadding * 0.8,
          vertical: config.contentVerticalPadding * 0.8),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: config.statsIconContainer,
            height: config.statsIconContainer,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(
              icon,
              size: config.statsIconSize,
              color: color,
            ),
          ),
          const SizedBox(width: AppConstants.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: config.statsTitleStyle?.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  value,
                  style: config.statsValueStyle?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(AppLocalizations l10n, ResultsScreenConfig config) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: config.contentHorizontalPadding * 0.8,
          vertical: config.contentVerticalPadding * 0.8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pastelMint.withValues(alpha: 0.08),
            AppColors.pastelAqua.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: AppColors.pastelMint.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: config.infoIconSize,
                color: AppColors.pastelMint,
              ),
              const SizedBox(width: AppConstants.space12),
              Expanded(
                child: Text(
                  l10n.resultsEvaluationSystemTitle,
                  style: config.infoTitleStyle?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.pastelMint,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space16),
          Text(
            l10n.resultsEvaluationSystemDesc1,
            style: config.infoBodyStyle?.copyWith(
              color: Colors.white70,
              height: 1.6,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.space16),
          Text(
            l10n.resultsEvaluationSystemDesc2,
            style: config.infoBodyStyle?.copyWith(
              color: Colors.white70,
              height: 1.6,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
