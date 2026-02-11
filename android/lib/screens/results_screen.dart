import 'package:flutter/material.dart';
import 'dart:ui';
import '../l10n/app_localizations.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/app_typography.dart';
import '../widgets/nanosolve_logo.dart';
import '../widgets/header_back_button.dart';
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
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);

    return Container(
      padding: EdgeInsets.all(spacing.headerPadding),
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
                  label: l10n.resultsBackButton,
                  color: AppColors.pastelMint,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.auto_graph_outlined,
                      size: sizing.iconMd,
                      color: AppColors.pastelMint,
                    ),
                    SizedBox(width: spacing.headerSpacing),
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
                        size: sizing.iconMd,
                        color: AppColors.pastelMint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: spacing.headerSpacing),
            NanosolveLogo(height: sizing.logoHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPadding, vertical: spacing.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTitleSection(l10n, spacing, typography),
          SizedBox(height: spacing.sectionSpacing),
          _buildStatsCard(
            title: l10n.resultsStatsTotalIdeas,
            value: '7',
            icon: Icons.lightbulb_outline,
            color: AppColors.pastelLavender,
            spacing: spacing,
            sizing: sizing,
            typography: typography,
          ),
          SizedBox(height: spacing.cardSpacing),
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
              spacing: spacing,
              sizing: sizing,
              typography: typography,
            ),
          ),
          SizedBox(height: spacing.sectionSpacing),
          _buildInfoPanel(l10n, spacing, sizing, typography),
        ],
      ),
    );
  }

  Widget _buildTitleSection(
    AppLocalizations l10n,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelMint, AppColors.pastelAqua],
          ).createShader(bounds),
          child: Text(
            l10n.resultsTitle,
            style: typography.display.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          l10n.resultsSubtitle,
          style: typography.subtitle.copyWith(
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
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPadding * 0.8,
          vertical: spacing.contentPadding * 0.8),
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
            width: sizing.iconContainer,
            height: sizing.iconContainer,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(
              icon,
              size: sizing.iconMd,
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
                  style: typography.label.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  value,
                  style: typography.stat.copyWith(
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

  Widget _buildInfoPanel(
    AppLocalizations l10n,
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPadding * 0.8,
          vertical: spacing.contentPadding * 0.8),
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
                size: sizing.iconSm,
                color: AppColors.pastelMint,
              ),
              const SizedBox(width: AppConstants.space12),
              Expanded(
                child: Text(
                  l10n.resultsEvaluationSystemTitle,
                  style: typography.title.copyWith(
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
            style: typography.body.copyWith(
              color: Colors.white70,
              height: 1.6,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.space16),
          Text(
            l10n.resultsEvaluationSystemDesc2,
            style: typography.body.copyWith(
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
