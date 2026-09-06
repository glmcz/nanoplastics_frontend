import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/service_locator.dart';
import '../utils/app_sizing.dart';
import '../utils/app_spacing.dart';
import '../utils/app_theme_colors.dart';
import '../utils/app_typography.dart';
import '../widgets/shared/screen_header.dart';
import 'footprint/footprint_story_screen.dart';

/// Lists the tools that show the problem in a student's own day.
///
/// Reached from the centre of the hub, and shown once automatically after
/// onboarding so a new install finds the tools rather than having to go
/// looking for them.
class ExploreScreen extends StatefulWidget {
  /// True when this is the automatic first-run visit, which offers a way out.
  final bool firstRun;

  const ExploreScreen({super.key, this.firstRun = false});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    ServiceLocator()
        .eventService
        .log('explore_opened', props: {'first_run': widget.firstRun});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.contentPaddingH,
                  vertical: spacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.exploreTitle, style: typography.title),
                    SizedBox(height: spacing.xs),
                    Text(l10n.exploreSubtitle, style: typography.bodySm),
                    SizedBox(height: spacing.lg),
                    _ToolCard(
                      cardKey: const Key('explore-card-footprint'),
                      title: l10n.exploreFootprintTitle,
                      hook: l10n.exploreFootprintHook,
                      icon: Icons.water_drop_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FootprintStoryScreen(),
                        ),
                      ),
                    ),
                    if (widget.firstRun) ...[
                      SizedBox(height: spacing.lg),
                      Center(
                        child: TextButton(
                          key: const Key('explore-skip'),
                          onPressed: () => Navigator.maybePop(context),
                          child: Text(l10n.exploreSkip),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final Key cardKey;
  final String title;
  final String hook;
  final IconData icon;
  final VoidCallback onTap;

  const _ToolCard({
    required this.cardKey,
    required this.title,
    required this.hook,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final colors = AppThemeColors.of(context);

    return Semantics(
      key: cardKey,
      button: true,
      label: '$title. $hook',
      child: Material(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(sizing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(sizing.radiusMd),
          child: Padding(
            padding: EdgeInsets.all(spacing.cardPadding),
            child: Row(
              children: [
                Icon(icon, size: sizing.iconMd, color: AppColors.neonOcean),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: typography.subtitle),
                      SizedBox(height: spacing.xs),
                      Text(hook, style: typography.bodySm),
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
}
