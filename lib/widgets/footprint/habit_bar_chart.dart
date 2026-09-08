import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/footprint/footprint_coefficients.dart';
import '../../features/footprint/footprint_format.dart';
import '../../features/footprint/footprint_model.dart';
import '../../features/footprint/footprint_strings_l10n.dart';
import '../../features/footprint/footprint_types.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';
import 'chapter_page.dart' show habitLabel;

enum BarMode { count, weight }

/// The breakdown panel.
///
/// Bars are drawn on a log scale. Habit values span nine orders of magnitude,
/// so a linear axis renders every bar but one as a hairline.
///
/// Count and weight disagree about which habit leads, and the toggle makes
/// that disagreement the lesson rather than a footnote.
class HabitBarChart extends StatefulWidget {
  final FootprintResult result;
  final BarMode mode;
  final ValueChanged<BarMode> onModeChanged;

  const HabitBarChart({
    super.key,
    required this.result,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  State<HabitBarChart> createState() => HabitBarChartState();
}

class HabitBarChartState extends State<HabitBarChart> {
  List<HabitEstimate> get rows => widget.mode == BarMode.count
      ? [
          for (final family in Family.values) ...widget.result.byFamily(family),
        ].where((h) => h.particlesPerYear > 0).toList()
      : widget.result.habitsWithMass;

  List<Habit> get orderedHabits => rows.map((r) => r.habit).toList();

  List<double> get debugBarLengths => rows.map(_lengthOf).toList();

  double _valueOf(HabitEstimate h) => widget.mode == BarMode.count
      ? h.particlesPerYear
      : (h.massMgPerYear ?? 0);

  /// Log10 of the value, normalised to the largest. A linear scale would put
  /// the smallest bar at roughly one billionth of the longest.
  double _lengthOf(HabitEstimate h) {
    final v = _valueOf(h);
    if (v <= 0) return 0;
    final maxV = rows.map(_valueOf).fold<double>(0, math.max);
    if (maxV <= 0) return 0;
    final logV = math.log(v) / math.ln10;
    final logMax = math.log(maxV) / math.ln10;
    // Floor at nine decades below the largest so nothing is invisible.
    const decades = 9.0;
    return ((logV - (logMax - decades)) / decades).clamp(0.05, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _modeButton(BarMode.count, l10n.footprintByCount, 'bar-mode-count'),
            SizedBox(width: spacing.sm),
            _modeButton(
                BarMode.weight, l10n.footprintByWeight, 'bar-mode-weight'),
          ],
        ),
        SizedBox(height: spacing.sm),
        Text(l10n.footprintMethodCaption, style: typography.labelSm),
        SizedBox(height: spacing.md),
        for (final row in rows) _buildRow(context, row),
      ],
    );
  }

  Widget _modeButton(BarMode mode, String label, String key) {
    final selected = widget.mode == mode;
    return Semantics(
      button: true,
      selected: selected,
      child: ChoiceChip(
        key: Key(key),
        label: Text(label),
        selected: selected,
        onSelected: (_) => widget.onModeChanged(mode),
      ),
    );
  }

  Widget _buildRow(BuildContext context, HabitEstimate h) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final colors = AppThemeColors.of(context);
    final strings = L10nFootprintStrings(l10n);

    final value = widget.mode == BarMode.count
        ? formatParticles(h.particlesPerYear, strings)
        : formatMassMg(h.massMgPerYear ?? 0, strings);

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.md),
      child: InkWell(
        onTap: () => _showSource(context, h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // An icon and a label, so the bar is never identified by
                // colour alone.
                Icon(
                  key: Key('bar-icon-${h.habit.name}'),
                  _iconFor(h.habit),
                  size: sizing.iconSm,
                  color: colors.textMuted,
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    habitLabel(l10n, h.habit),
                    key: Key('bar-label-${h.habit.name}'),
                    style: typography.bodySm,
                  ),
                ),
                Text(value, style: typography.labelSm),
              ],
            ),
            SizedBox(height: spacing.xs),
            LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(
                    height: spacing.sm,
                    decoration: BoxDecoration(
                      color: colors.surfaceMid,
                      borderRadius: BorderRadius.circular(spacing.xs),
                    ),
                  ),
                  Container(
                    key: Key('bar-fill-${h.habit.name}'),
                    height: spacing.sm,
                    width: constraints.maxWidth * _lengthOf(h),
                    decoration: BoxDecoration(
                      color: colors.textMain,
                      borderRadius: BorderRadius.circular(spacing.xs),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              _tagLine(l10n, h),
              key: Key('bar-tag-${h.habit.name}'),
              style: typography.labelXs,
            ),
          ],
        ),
      ),
    );
  }

  String _tagLine(AppLocalizations l10n, HabitEstimate h) {
    final floor = h.sizeFloorNm >= 1000
        ? '${(h.sizeFloorNm / 1000).round()} µm'
        : '${h.sizeFloorNm.round()} nm';
    final tags = h.tags.map((t) => _tagLabel(l10n, t, h.habit)).join(', ');
    return '$floor · $tags';
  }

  String _tagLabel(AppLocalizations l10n, Tag t, Habit habit) => switch (t) {
        Tag.measured => l10n.footprintTagMeasured,
        Tag.countedNotIdentified => l10n.footprintTagCountedNotIdentified,
        Tag.extrapolated => l10n.footprintTagExtrapolated,
        Tag.disputed => l10n.footprintTagChallenged(_challenger(l10n, habit)),
        Tag.unknown => l10n.footprintTagUnknown,
      };

  /// Names the specific published challenge. A collective phrasing would
  /// suggest several independent groups measured this and got different
  /// answers; in practice one paper was challenged once.
  String _challenger(AppLocalizations l10n, Habit habit) =>
      switch (coefficientFor(habit).challengedByKey) {
        'footprintChallengerPnasLetter' => l10n.footprintChallengerPnasLetter,
        'footprintChallengerEstComment' => l10n.footprintChallengerEstComment,
        'footprintChallengerBfr' => l10n.footprintChallengerBfr,
        _ => '',
      };

  IconData _iconFor(Habit h) => switch (h) {
        Habit.bottledWater => Icons.water_drop_outlined,
        Habit.bottleStorage => Icons.wb_sunny_outlined,
        Habit.microwaveMeals => Icons.microwave_outlined,
        Habit.takeawayCupsSubMicron => Icons.local_cafe_outlined,
        Habit.teaBags => Icons.emoji_food_beverage_outlined,
        Habit.takeawayCupsMicron => Icons.coffee_outlined,
        Habit.seafood => Icons.set_meal_outlined,
        Habit.cuttingBoard => Icons.restaurant_outlined,
        Habit.syntheticIndoor => Icons.weekend_outlined,
        Habit.dustDays => Icons.air_outlined,
      };

  void _showSource(BuildContext context, HabitEstimate h) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(habitLabel(l10n, h.habit),
                style: AppTypography.of(context).subtitle),
            SizedBox(height: spacing.sm),
            Text(h.source, style: AppTypography.of(context).bodySm),
          ],
        ),
      ),
    );
  }
}
