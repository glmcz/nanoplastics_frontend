import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/app_typography.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/app_theme_colors.dart';
import '../widgets/nanosolve_logo.dart';
import '../models/solver_idea.dart';

class SolverIdeaDetailScreen extends StatelessWidget {
  final SolverIdea idea;
  final String solverName;
  final int rank;

  const SolverIdeaDetailScreen({
    super.key,
    required this.idea,
    required this.solverName,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelMint.withValues(alpha: 0.08),
              AppColors.pastelLavender.withValues(alpha: 0.05),
              AppThemeColors.of(context).gradientEnd,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    Color rankColor() {
      if (rank == 1) return const Color(0xFFFFD700);
      if (rank == 2) return const Color(0xFFC0C0C0);
      if (rank == 3) return const Color(0xFFCD7F32);
      return AppColors.pastelMint;
    }

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.headerPadding * 15,
          vertical: spacing.headerPadding * 8),
      decoration: BoxDecoration(
        color: AppThemeColors.of(context).cardBackground.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios,
                        color: AppThemeColors.of(context).textMain,
                        size: sizing.backIcon),
                    const SizedBox(width: AppConstants.space4),
                    Flexible(
                      child: Text(
                        solverName,
                        style: typography.back.copyWith(
                          color: AppThemeColors.of(context).textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppConstants.space8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.space8,
                          vertical: AppConstants.space2),
                      decoration: BoxDecoration(
                        color: rankColor().withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusSmall),
                        border: Border.all(
                            color: rankColor().withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '#$rank',
                        style:
                            Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: rankColor(),
                                  fontWeight: FontWeight.w900,
                                ),
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
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (idea.category != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.space8,
                  vertical: AppConstants.space4),
              decoration: BoxDecoration(
                color: AppColors.pastelAqua.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(
                    color: AppColors.pastelAqua.withValues(alpha: 0.4)),
              ),
              child: Text(
                idea.category!,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.pastelAqua,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: AppConstants.space16),
          ],
          // Name of work (description as title)
          if (idea.description.isNotEmpty) ...[
            Text(
              'Work Description',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: AppThemeColors.of(context).textMuted,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: AppConstants.space8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.space16),
              decoration: BoxDecoration(
                color: AppThemeColors.of(context)
                    .cardBackground
                    .withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(
                    color: AppColors.pastelMint.withValues(alpha: 0.2)),
              ),
              child: Text(
                idea.description,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppThemeColors.of(context).textMain,
                      height: 1.6,
                    ),
              ),
            ),
            const SizedBox(height: AppConstants.space24),
          ],
          // Abstract section
          if (idea.abstractText.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.auto_awesome,
                    size: AppConstants.iconSmall, color: AppColors.pastelMint),
                const SizedBox(width: AppConstants.space8),
                Text(
                  'Abstract',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppThemeColors.of(context).textMuted,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.space8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.space16),
              decoration: BoxDecoration(
                color: AppColors.pastelMint.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(
                    color: AppColors.pastelMint.withValues(alpha: 0.3)),
              ),
              child: Text(
                idea.abstractText,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppThemeColors.of(context).textMain,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.space16),
          Text(
            idea.createdAt,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: AppThemeColors.of(context).textMuted,
                ),
          ),
          const SizedBox(height: AppConstants.space24),
        ],
      ),
    );
  }
}
