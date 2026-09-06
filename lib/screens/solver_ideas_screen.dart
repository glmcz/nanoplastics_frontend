import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/app_typography.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/app_theme_colors.dart';
import '../widgets/nanosolve_logo.dart';
import '../services/service_locator.dart';
import '../models/solver_idea.dart';
import 'solver_idea_detail_screen.dart';

class SolverIdeasScreen extends StatefulWidget {
  final String solverName;
  final int rank;

  const SolverIdeasScreen({
    super.key,
    required this.solverName,
    required this.rank,
  });

  @override
  State<SolverIdeasScreen> createState() => _SolverIdeasScreenState();
}

class _SolverIdeasScreenState extends State<SolverIdeasScreen> {
  Future<List<SolverIdea>>? _ideasFuture;

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  void _loadIdeas() {
    setState(() {
      _ideasFuture =
          ServiceLocator().apiService.getSolverIdeas(widget.solverName);
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
      if (widget.rank == 1) return const Color(0xFFFFD700);
      if (widget.rank == 2) return const Color(0xFFC0C0C0);
      if (widget.rank == 3) return const Color(0xFFCD7F32);
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
                        widget.solverName,
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
                        '#${widget.rank}',
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
    return RefreshIndicator(
      color: AppColors.pastelMint,
      backgroundColor: AppThemeColors.of(context).dialogBackground,
      onRefresh: () async {
        _loadIdeas();
        await _ideasFuture;
      },
      child: FutureBuilder<List<SolverIdea>>(
        future: _ideasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.pastelMint),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.space24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off,
                        size: AppConstants.iconLarge,
                        color: AppColors.pastelMint.withValues(alpha: 0.5)),
                    const SizedBox(height: AppConstants.space16),
                    Text(
                      '${snapshot.error}',
                      style:
                          TextStyle(color: AppThemeColors.of(context).textMain),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.space24),
                    ElevatedButton.icon(
                      onPressed: _loadIdeas,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pastelMint,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final ideas = snapshot.data ?? [];

          if (ideas.isEmpty) {
            return Center(
              child: Text(
                'No ideas found.',
                style: TextStyle(color: AppThemeColors.of(context).textMuted),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  ideas.map((idea) => _buildIdeaCard(context, idea)).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIdeaCard(BuildContext context, SolverIdea idea) {
    final hasDetail = idea.description.isNotEmpty;
    final cardRadius = BorderRadius.circular(AppConstants.radiusLarge);

    final card = Container(
      margin: const EdgeInsets.only(bottom: AppConstants.space12),
      padding: const EdgeInsets.all(AppConstants.space16),
      decoration: BoxDecoration(
        color: AppThemeColors.of(context).cardBackground.withValues(alpha: 0.8),
        borderRadius: cardRadius,
        border: Border.all(
          color: hasDetail
              ? AppColors.pastelMint.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            idea.abstractText,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppThemeColors.of(context).textMain,
                  height: 1.5,
                ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.space10),
          Row(
            children: [
              if (idea.category != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.space8,
                      vertical: AppConstants.space2),
                  decoration: BoxDecoration(
                    color: AppColors.pastelMint.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSmall),
                    border: Border.all(
                        color: AppColors.pastelMint.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    idea.category!,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: AppColors.pastelMint,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: AppConstants.space8),
              ],
              Expanded(
                child: Text(
                  idea.createdAt,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: AppThemeColors.of(context).textMuted,
                      ),
                ),
              ),
              if (hasDetail)
                Icon(
                  Icons.chevron_right,
                  size: AppConstants.iconSmall,
                  color: AppColors.pastelMint.withValues(alpha: 0.7),
                ),
            ],
          ),
        ],
      ),
    );

    if (!hasDetail) return card;

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: cardRadius,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SolverIdeaDetailScreen(
              idea: idea,
              solverName: widget.solverName,
              rank: widget.rank,
            ),
          )),
          child: card,
        ),
      ),
    );
  }
}
