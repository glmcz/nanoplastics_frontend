import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/footprint/footprint_coefficients.dart';
import '../../features/footprint/footprint_format.dart';
import '../../features/footprint/footprint_model.dart';
import '../../features/footprint/footprint_strings_l10n.dart';
import '../../features/footprint/footprint_types.dart';
import '../../l10n/app_localizations.dart';
import '../../services/service_locator.dart';
import '../../services/settings_manager.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';
import '../../widgets/footprint/chapter_page.dart' show habitLabel, tr;
import '../../widgets/footprint/charge_panel.dart';
import '../../widgets/footprint/footprint_doors.dart';
import '../../widgets/footprint/habit_bar_chart.dart';
import '../../widgets/footprint/particle_cloud.dart';
import '../../widgets/shared/screen_header.dart';

/// The student's year, in panels.
///
/// There is deliberately no grand total and no percentage anywhere: rows
/// counted at different size floors are not comparable, and summing them
/// would rank habits by whose lab owned the better microscope.
class FootprintResultScreen extends StatefulWidget {
  final FootprintInput input;
  final bool returning;

  const FootprintResultScreen({
    super.key,
    required this.input,
    this.returning = false,
  });

  @override
  State<FootprintResultScreen> createState() => FootprintResultScreenState();
}

class FootprintResultScreenState extends State<FootprintResultScreen> {
  BarMode mode = BarMode.count;
  bool cloudPaused = false;
  Habit? _swapChoice;
  final TextEditingController _commitment = TextEditingController();
  final TextEditingController _explanation = TextEditingController();

  late final FootprintResult _result = estimate(widget.input);

  @override
  void initState() {
    super.initState();
    final saved = SettingsManager().footprintState;
    _commitment.text = (saved['commitment'] as String?) ?? '';
    _explanation.text = (saved['explanation'] as String?) ?? '';
    _persist();
  }

  @override
  void dispose() {
    _commitment.dispose();
    _explanation.dispose();
    super.dispose();
  }

  Future<void> _persist() async {
    final saved = Map<String, dynamic>.from(SettingsManager().footprintState);
    saved['input'] = widget.input.toJson();
    await SettingsManager().setFootprintState(saved);
  }

  /// Never contains a percentage or a raw answer.
  String get shareText {
    final l10n = AppLocalizations.of(context)!;
    return l10n.footprintShareText(_headlineSentence(l10n));
  }

  String _headlineSentence(AppLocalizations l10n) {
    final strings = L10nFootprintStrings(l10n);
    final byCount = _result.headlineHabit;
    final byMass = _result.habitsWithMass.isEmpty
        ? null
        : _result.habitsWithMass.first.habit;
    if (byCount == null || byMass == null) return l10n.footprintResultTitle;
    final count =
        _result.habits.firstWhere((h) => h.habit == byCount).particlesPerYear;
    return l10n.footprintHeadline(
      formatParticles(count, strings),
      habitLabel(l10n, byCount),
      habitLabel(l10n, byMass),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.contentPaddingH,
                  vertical: spacing.md,
                ),
                children: [
                  if (widget.returning) _buildRecount(l10n),
                  _buildHeadline(l10n),
                  SizedBox(height: spacing.xl),
                  _buildClouds(l10n),
                  SizedBox(height: spacing.xl),
                  HabitBarChart(
                    result: _result,
                    mode: mode,
                    onModeChanged: (m) {
                      setState(() => mode = m);
                      ServiceLocator()
                          .eventService
                          .log('footprint_view_toggled', props: {'to': m.name});
                    },
                  ),
                  SizedBox(height: spacing.xl),
                  _buildSwap(l10n),
                  SizedBox(height: spacing.xl),
                  const ChargePanel(),
                  SizedBox(height: spacing.xl),
                  _buildExplain(l10n),
                  SizedBox(height: spacing.xl),
                  FootprintDoors(result: _result),
                  SizedBox(height: spacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecount(AppLocalizations l10n) {
    final spacing = AppSpacing.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.md),
      child: OutlinedButton(
        key: const Key('result-recount'),
        onPressed: () => Navigator.maybePop(context),
        child: Text(l10n.footprintRecount),
      ),
    );
  }

  Widget _buildHeadline(AppLocalizations l10n) {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    final predicted = widget.input.prediction;
    final actual = _result.headlineHabit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _headlineSentence(l10n),
          key: const Key('result-headline'),
          style: typography.subtitle,
        ),
        SizedBox(height: spacing.sm),
        if (predicted != null && actual != null)
          Text(
            predicted == actual
                ? l10n.footprintPredictionRight
                : l10n.footprintPredictionWrong(
                    habitLabel(l10n, actual),
                    habitLabel(l10n, predicted),
                  ),
            key: const Key('result-prediction'),
            style: typography.bodySm,
          ),
        SizedBox(height: spacing.xs),
        Text(
          l10n.footprintTouchedCount(
            ChapterKey.values.length,
            _result.touchedCount,
          ),
          key: const Key('result-touched-count'),
          style: typography.labelSm,
        ),
        SizedBox(height: spacing.xs),
        Row(
          children: [
            Text(l10n.footprintEstimate, style: typography.labelXs),
            const Spacer(),
            TextButton(
              key: const Key('result-share'),
              onPressed: () {
                ServiceLocator().eventService.log('footprint_shared');
                Share.share(shareText);
              },
              child: Text(l10n.footprintShare),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClouds(AppLocalizations l10n) {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final strings = L10nFootprintStrings(l10n);

    Widget cloudFor(Family family, String floorLabel) {
      final habits = _result.byFamily(family);
      final total = habits.fold<double>(0, (a, h) => a + h.particlesPerYear);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParticleCloud(
            habits: habits,
            semanticLabel: formatParticles(total, strings),
            paused: cloudPaused,
            onTogglePause: () => setState(() => cloudPaused = !cloudPaused),
            height: (MediaQuery.of(context).size.height * 0.14).clamp(48, 120),
          ),
          Text(
            floorLabel,
            key: Key('floor-caption-${family.name}'),
            style: typography.labelXs,
          ),
          SizedBox(height: spacing.lg),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cloudFor(Family.swallowedSubMicron, l10n.footprintFloorSubMicron),
        cloudFor(Family.swallowedMicron, l10n.footprintFloorMicron),
        Text(
          l10n.footprintOpenQuestionAir,
          key: const Key('result-open-question'),
          style: typography.bodySm,
        ),
        SizedBox(height: spacing.md),
        cloudFor(Family.breathed, l10n.footprintFloorBreathed),
      ],
    );
  }

  Widget _buildSwap(AppLocalizations l10n) {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final strings = L10nFootprintStrings(l10n);

    final swappable = kCoefficients.where((c) => c.swaps.isNotEmpty).toList();
    final mine = swappable.where((c) => !c.swaps.first.household);
    final household = swappable.where((c) => c.swaps.first.household);

    Widget group(String title, Iterable<Coefficient> items, String key) {
      return Column(
        key: Key(key),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: typography.labelSm),
          SizedBox(height: spacing.xs),
          for (final c in items)
            Semantics(
              button: true,
              selected: _swapChoice == c.habit,
              child: ListTile(
                key: Key('swap-${c.habit.name}'),
                selected: _swapChoice == c.habit,
                leading: Icon(
                  _swapChoice == c.habit
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                onTap: () => setState(() => _swapChoice = c.habit),
                title: Text(tr(l10n, c.swaps.first.labelKey),
                    style: typography.bodySm),
                subtitle: _swapEffect(c.habit, strings),
              ),
            ),
        ],
      );
    }

    return Column(
      key: const Key('panel-swap'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.footprintSwapTitle, style: typography.subtitle),
        SizedBox(height: spacing.md),
        group(l10n.footprintSwapYours, mine, 'swaps-yours'),
        SizedBox(height: spacing.md),
        group(l10n.footprintSwapHousehold, household, 'swaps-household'),
        SizedBox(height: spacing.md),
        Text(l10n.footprintCommitmentPrompt, style: typography.bodySm),
        SizedBox(height: spacing.sm),
        TextField(
          key: const Key('commitment-field'),
          controller: _commitment,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: l10n.footprintCommitmentHint,
            border: const OutlineInputBorder(),
          ),
        ),
        SizedBox(height: spacing.sm),
        ElevatedButton(
          key: const Key('commitment-save'),
          onPressed: () async {
            final saved =
                Map<String, dynamic>.from(SettingsManager().footprintState);
            saved['commitment'] = _commitment.text;
            saved['commitment_at'] = DateTime.now().toIso8601String();
            await SettingsManager().setFootprintState(saved);
            ServiceLocator().eventService.log(
              'footprint_commitment',
              props: {'habit': _swapChoice?.name ?? 'none'},
            );
          },
          child: Text(l10n.footprintCommitmentSave),
        ),
      ],
    );
  }

  /// Shows the swap's effect in the student's own numbers, by count and by
  /// weight, so the response is concrete rather than a slogan.
  Widget? _swapEffect(Habit habit, FootprintStrings strings) {
    final after = _result.withChange(habit);
    final target = habit == Habit.bottleStorage ? Habit.bottledWater : habit;
    final before =
        _result.habits.firstWhere((h) => h.habit == target).particlesPerYear;
    final now =
        after.habits.firstWhere((h) => h.habit == target).particlesPerYear;
    if (before <= 0 || before == now) return null;
    final typography = AppTypography.of(context);
    return Text(
      '${formatParticles(before, strings)} → ${formatParticles(now, strings)}',
      style: typography.labelXs,
    );
  }

  Widget _buildExplain(AppLocalizations l10n) {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final saved = SettingsManager().footprintState;
    final answered = (saved['explanation'] as String?)?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.footprintExplainPrompt, style: typography.subtitle),
        SizedBox(height: spacing.sm),
        TextField(
          key: const Key('explain-field'),
          controller: _explanation,
          maxLines: 2,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        SizedBox(height: spacing.sm),
        ElevatedButton(
          key: const Key('explain-save'),
          onPressed: () async {
            final s =
                Map<String, dynamic>.from(SettingsManager().footprintState);
            s['explanation'] = _explanation.text;
            await SettingsManager().setFootprintState(s);
            ServiceLocator().eventService.log('footprint_explained');
            setState(() {});
          },
          child: Text(l10n.footprintExplainSave),
        ),
        // Never graded. The model answer appears beside what they wrote.
        if (answered) ...[
          SizedBox(height: spacing.sm),
          Text(
            l10n.footprintExplainModelAnswer,
            key: const Key('explain-model-answer'),
            style: typography.bodySm,
          ),
        ],
      ],
    );
  }
}
