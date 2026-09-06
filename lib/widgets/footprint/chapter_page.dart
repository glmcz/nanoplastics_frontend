import 'package:flutter/material.dart';

import '../../features/footprint/chapters.dart';
import '../../features/footprint/footprint_model.dart';
import '../../features/footprint/footprint_types.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';

/// Looks up a chapter string by the key stored in [kChapters].
///
/// The chapter list is data, so its strings are named rather than called. One
/// table maps those names to the generated getters; a missing entry shows the
/// key itself, which is loud enough to catch in review.
String tr(AppLocalizations l, String key) {
  final map = <String, String>{
    'footprintSceneWater': l.footprintSceneWater,
    'footprintSceneLunch': l.footprintSceneLunch,
    'footprintSceneTea': l.footprintSceneTea,
    'footprintSceneCups': l.footprintSceneCups,
    'footprintSceneHome': l.footprintSceneHome,
    'footprintSceneDinner': l.footprintSceneDinner,
    'footprintSceneOutside': l.footprintSceneOutside,
    'footprintWhyWater': l.footprintWhyWater,
    'footprintWhyLunch': l.footprintWhyLunch,
    'footprintWhyTea': l.footprintWhyTea,
    'footprintWhyCups': l.footprintWhyCups,
    'footprintWhyHome': l.footprintWhyHome,
    'footprintWhyDinner': l.footprintWhyDinner,
    'footprintWhyOutside': l.footprintWhyOutside,
    'footprintQWaterSource': l.footprintQWaterSource,
    'footprintQWaterAmount': l.footprintQWaterAmount,
    'footprintQBottleStorage': l.footprintQBottleStorage,
    'footprintQContainerMeals': l.footprintQContainerMeals,
    'footprintQMicrowaveMeals': l.footprintQMicrowaveMeals,
    'footprintQTeaBagType': l.footprintQTeaBagType,
    'footprintQTeaCups': l.footprintQTeaCups,
    'footprintQTakeawayCups': l.footprintQTakeawayCups,
    'footprintQSynthetic': l.footprintQSynthetic,
    'footprintQIndoorHours': l.footprintQIndoorHours,
    'footprintQSeafood': l.footprintQSeafood,
    'footprintQSeafoodForm': l.footprintQSeafoodForm,
    'footprintQCuttingBoard': l.footprintQCuttingBoard,
    'footprintQDustyHours': l.footprintQDustyHours,
    'footprintOptSmallBottles': l.footprintOptSmallBottles,
    'footprintOptCoolerJug': l.footprintOptCoolerJug,
    'footprintOptTapOrFilter': l.footprintOptTapOrFilter,
    'footprintOptFridge': l.footprintOptFridge,
    'footprintOptRoom': l.footprintOptRoom,
    'footprintOptCarOrSun': l.footprintOptCarOrSun,
    'footprintOptPaperBag': l.footprintOptPaperBag,
    'footprintOptPyramidBag': l.footprintOptPyramidBag,
    'footprintOptLooseLeaf': l.footprintOptLooseLeaf,
    'footprintOptLittle': l.footprintOptLittle,
    'footprintOptSome': l.footprintOptSome,
    'footprintOptMost': l.footprintOptMost,
    'footprintOptAll': l.footprintOptAll,
    'footprintOptFillet': l.footprintOptFillet,
    'footprintOptWhole': l.footprintOptWhole,
    'footprintOptBoardPlastic': l.footprintOptBoardPlastic,
    'footprintOptBoardWood': l.footprintOptBoardWood,
    'footprintOptBoardUnknown': l.footprintOptBoardUnknown,
    'footprintUnitBottles': l.footprintUnitBottles,
    'footprintUnitMealsWeek': l.footprintUnitMealsWeek,
    'footprintUnitCupsDay': l.footprintUnitCupsDay,
    'footprintUnitCupsWeek': l.footprintUnitCupsWeek,
    'footprintUnitHoursDay': l.footprintUnitHoursDay,
    'footprintUnitHoursWeek': l.footprintUnitHoursWeek,
    'footprintSwapSteelBottle': l.footprintSwapSteelBottle,
    'footprintSwapKeepBottleCool': l.footprintSwapKeepBottleCool,
    'footprintSwapGlassDish': l.footprintSwapGlassDish,
    'footprintSwapOwnCup': l.footprintSwapOwnCup,
    'footprintSwapPaperTeaBag': l.footprintSwapPaperTeaBag,
    'footprintSwapWoodenBoard': l.footprintSwapWoodenBoard,
    'footprintHabitBottledWater': l.footprintHabitBottledWater,
    'footprintHabitBottleStorage': l.footprintHabitBottleStorage,
    'footprintHabitMicrowaveMeals': l.footprintHabitMicrowaveMeals,
    'footprintHabitTakeawayCupsSubMicron':
        l.footprintHabitTakeawayCupsSubMicron,
    'footprintHabitTeaBags': l.footprintHabitTeaBags,
    'footprintHabitTakeawayCupsMicron': l.footprintHabitTakeawayCupsMicron,
    'footprintHabitSeafood': l.footprintHabitSeafood,
    'footprintHabitCuttingBoard': l.footprintHabitCuttingBoard,
    'footprintHabitSyntheticIndoor': l.footprintHabitSyntheticIndoor,
    'footprintHabitDustDays': l.footprintHabitDustDays,
  };
  return map[key] ?? key;
}

String habitLabel(AppLocalizations l, Habit h) =>
    tr(l, 'footprintHabit${h.name[0].toUpperCase()}${h.name.substring(1)}');

/// One chapter of the story: a scene line, its questions, and the why.
class ChapterPage extends StatelessWidget {
  final Chapter chapter;
  final FootprintInput input;
  final ValueChanged<FootprintInput> onChanged;
  final VoidCallback onTouched;
  final bool showWhy;

  const ChapterPage({
    super.key,
    required this.chapter,
    required this.input,
    required this.onChanged,
    required this.onTouched,
    required this.showWhy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final colors = AppThemeColors.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: spacing.contentPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(l10n, chapter.sceneKey), style: typography.subtitle),
          SizedBox(height: spacing.lg),
          for (final control in chapter.controls) ...[
            _buildControl(context, control),
            SizedBox(height: spacing.lg),
          ],
          TextButton(
            key: Key('confirm-default-${chapter.key.name}'),
            onPressed: onTouched,
            child: Text(l10n.footprintConfirmDefault),
          ),
          if (showWhy) ...[
            SizedBox(height: spacing.md),
            Container(
              padding: EdgeInsets.all(spacing.md),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(spacing.sm),
              ),
              child: Text(tr(l10n, chapter.whyKey), style: typography.bodySm),
            ),
          ],
          SizedBox(height: spacing.xl),
        ],
      ),
    );
  }

  Widget _buildControl(BuildContext context, ControlSpec spec) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr(l10n, spec.questionKey), style: typography.body),
        SizedBox(height: spacing.sm),
        if (spec.kind == ControlKind.slider)
          _buildSlider(context, spec)
        else
          _buildChips(context, spec),
      ],
    );
  }

  Widget _buildSlider(BuildContext context, ControlSpec spec) {
    final l10n = AppLocalizations.of(context)!;
    final unit = spec.unitKey == null ? '' : tr(l10n, spec.unitKey!);
    final value = _intValue(spec.field).toDouble();

    return Slider(
      key: Key('slider-${spec.field}'),
      value: value.clamp(spec.min.toDouble(), spec.max.toDouble()),
      min: spec.min.toDouble(),
      max: spec.max.toDouble(),
      divisions: spec.max - spec.min,
      label: '${value.round()} $unit',
      // Without this a screen reader announces a percentage, which tells the
      // student nothing about bottles or meals.
      semanticFormatterCallback: (v) => '${v.round()} $unit',
      onChanged: (v) {
        onTouched();
        onChanged(_withInt(spec.field, v.round()));
      },
    );
  }

  Widget _buildChips(BuildContext context, ControlSpec spec) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final selected = _enumIndex(spec.field);

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: [
        for (var i = 0; i < spec.optionKeys.length; i++)
          Semantics(
            button: true,
            selected: selected == i,
            child: ChoiceChip(
              key: Key('chip-${spec.field}-$i'),
              label: Text(tr(l10n, spec.optionKeys[i])),
              selected: selected == i,
              onSelected: (_) {
                onTouched();
                onChanged(_withEnum(spec.field, i));
              },
            ),
          ),
      ],
    );
  }

  int _intValue(String field) => switch (field) {
        'waterBottlesPerDay' => input.waterBottlesPerDay,
        'plasticContainerMealsPerWeek' => input.plasticContainerMealsPerWeek,
        'microwaveMealsPerWeek' => input.microwaveMealsPerWeek,
        'teaCupsPerDay' => input.teaCupsPerDay,
        'takeawayCupsPerWeek' => input.takeawayCupsPerWeek,
        'indoorHoursPerDay' => input.indoorHoursPerDay,
        'seafoodMealsPerWeek' => input.seafoodMealsPerWeek,
        'dustyHoursPerWeek' => input.dustyHoursPerWeek,
        _ => 0,
      };

  FootprintInput _withInt(String field, int v) => switch (field) {
        'waterBottlesPerDay' => input.copyWith(waterBottlesPerDay: v),
        'plasticContainerMealsPerWeek' =>
          input.copyWith(plasticContainerMealsPerWeek: v),
        'microwaveMealsPerWeek' => input.copyWith(microwaveMealsPerWeek: v),
        'teaCupsPerDay' => input.copyWith(teaCupsPerDay: v),
        'takeawayCupsPerWeek' => input.copyWith(takeawayCupsPerWeek: v),
        'indoorHoursPerDay' => input.copyWith(indoorHoursPerDay: v),
        'seafoodMealsPerWeek' => input.copyWith(seafoodMealsPerWeek: v),
        'dustyHoursPerWeek' => input.copyWith(dustyHoursPerWeek: v),
        _ => input,
      };

  int _enumIndex(String field) => switch (field) {
        'waterSource' => input.waterSource.index,
        'bottleStorage' => input.bottleStorage.index,
        'teaBagType' => input.teaBagType.index,
        'syntheticIndoorShare' => input.syntheticIndoorShare.index,
        'seafoodForm' => input.seafoodForm.index,
        'cuttingBoard' => input.cuttingBoard.index,
        _ => 0,
      };

  FootprintInput _withEnum(String field, int i) => switch (field) {
        'waterSource' => input.copyWith(waterSource: WaterSource.values[i]),
        'bottleStorage' =>
          input.copyWith(bottleStorage: BottleStorage.values[i]),
        'teaBagType' => input.copyWith(teaBagType: TeaBagType.values[i]),
        'syntheticIndoorShare' =>
          input.copyWith(syntheticIndoorShare: SyntheticShare.values[i]),
        'seafoodForm' => input.copyWith(seafoodForm: SeafoodForm.values[i]),
        'cuttingBoard' => input.copyWith(cuttingBoard: CuttingBoard.values[i]),
        _ => input,
      };
}
