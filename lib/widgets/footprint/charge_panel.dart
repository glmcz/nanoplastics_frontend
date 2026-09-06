import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';

/// Carries the project's thesis in three stages: friction charges plastic, a
/// charged particle behaves differently, and that charge is what lets it cross
/// into blood and tissue.
///
/// Advances on a control rather than a timer, so it works with reduce-motion
/// and so a student can sit on a stage as long as they like.
class ChargePanel extends StatefulWidget {
  const ChargePanel({super.key});

  @override
  State<ChargePanel> createState() => ChargePanelState();
}

class ChargePanelState extends State<ChargePanel> {
  int stage = 0;
  int get stageCount => 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final colors = AppThemeColors.of(context);

    final stages = [
      l10n.footprintChargeStage1,
      l10n.footprintChargeStage2,
      l10n.footprintChargeStage3,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.footprintChargeTitle, style: typography.subtitle),
        SizedBox(height: spacing.md),
        Semantics(
          liveRegion: true,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(spacing.sm),
            ),
            child: Text(stages[stage], style: typography.body),
          ),
        ),
        SizedBox(height: spacing.sm),
        Row(
          children: [
            for (var i = 0; i < stageCount; i++)
              Container(
                width: spacing.sm,
                height: spacing.sm,
                margin: EdgeInsets.only(right: spacing.xs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == stage ? colors.textMain : colors.textDark,
                ),
              ),
            const Spacer(),
            TextButton(
              key: const Key('charge-next'),
              onPressed: () => setState(() => stage = (stage + 1) % stageCount),
              child: Text(l10n.footprintChargeNext),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        Text(
          l10n.footprintChargeKnown,
          key: const Key('charge-known'),
          style: typography.bodySm,
        ),
        SizedBox(height: spacing.sm),
        Text(
          l10n.footprintChargeNotKnown,
          key: const Key('charge-not-known'),
          style: typography.bodySm,
        ),
      ],
    );
  }
}
