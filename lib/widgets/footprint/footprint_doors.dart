import 'package:flutter/material.dart';

import '../../features/footprint/chapters.dart';
import '../../features/footprint/footprint_coefficients.dart';
import '../../features/footprint/footprint_model.dart';
import '../../features/footprint/footprint_types.dart';
import '../../l10n/app_localizations.dart';
import '../../services/service_locator.dart';
import '../../services/settings_manager.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';
import 'chapter_page.dart' show habitLabel;
import 'help_consent_sheet.dart';

/// An open question a student could actually close, with a size and a first
/// step. Each one came out of the coefficient table, where the honest answer
/// was that nobody has measured it.
class OpenQuestion {
  final String id;
  final String question;
  final String size;
  final String step;
  const OpenQuestion(this.id, this.question, this.size, this.step);
}

const List<OpenQuestion> kOpenQuestions = [
  OpenQuestion(
    'gulfTapWater',
    'How many nanoplastics are in Gulf tap water?',
    'one term project',
    'the 2021 Saudi survey screened only down to 25 micrometres',
  ),
  OpenQuestion(
    'coolerJug',
    'What is in a 20 litre cooler jug at nano scale?',
    'one term project',
    'the 2024 bottled-water method applies unchanged',
  ),
  OpenQuestion(
    'breathedNano',
    'What is the nano fraction of the air a Gulf student breathes?',
    'a thesis',
    'the Kuwait indoor baseline stops at 11 micrometres',
  ),
];

/// Change, study, help. Equal weight, because a number with no door is just
/// a number.
class FootprintDoors extends StatelessWidget {
  final FootprintResult result;

  const FootprintDoors({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.footprintDoorsTitle, style: typography.subtitle),
        SizedBox(height: spacing.md),
        _door(
          context,
          'door-change',
          l10n.footprintDoorChange,
          l10n.footprintDoorChangeBody,
          Icons.swap_horiz,
          () => _log(context, 'change'),
        ),
        SizedBox(height: spacing.sm),
        _door(
          context,
          'door-study',
          l10n.footprintDoorStudy,
          l10n.footprintDoorStudyBody,
          Icons.menu_book_outlined,
          () {
            _log(context, 'study');
            _openStudy(context);
          },
        ),
        SizedBox(height: spacing.sm),
        _door(
          context,
          'door-help',
          l10n.footprintDoorHelp,
          l10n.footprintDoorHelpBody,
          Icons.lightbulb_outline,
          () {
            _log(context, 'help');
            _openHelp(context);
          },
        ),
      ],
    );
  }

  void _log(BuildContext context, String door) {
    ServiceLocator().eventService.log('footprint_door', props: {'door': door});
  }

  Widget _door(
    BuildContext context,
    String key,
    String title,
    String body,
    IconData icon,
    VoidCallback onTap,
  ) {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final colors = AppThemeColors.of(context);

    return Semantics(
      button: true,
      label: '$title. $body',
      child: Material(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(spacing.sm),
        child: InkWell(
          key: Key(key),
          onTap: onTap,
          borderRadius: BorderRadius.circular(spacing.sm),
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Row(
              children: [
                Icon(icon, color: colors.textMuted),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: typography.body),
                      Text(body, style: typography.labelSm),
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

  /// A path, not a reading list: where to start, what was measured nearby,
  /// and what nobody has measured yet.
  void _openStudy(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.footprintStudyStartHere,
                key: const Key('study-start-here'),
                style: typography.subtitle,
              ),
              SizedBox(height: spacing.sm),
              for (final h in result.habits.take(3))
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.sm),
                  child: Text(
                    '${habitLabel(l10n, h.habit)}: ${h.source}',
                    style: typography.labelSm,
                  ),
                ),
              SizedBox(height: spacing.md),
              Text(
                l10n.footprintStudyRegional,
                key: const Key('study-regional'),
                style: typography.subtitle,
              ),
              SizedBox(height: spacing.sm),
              Text(
                'Jaywun expedition 2026: Arabian Sea 56 particles per litre, '
                'Strait of Hormuz 34, UAE waters 31, Red Sea 25. '
                'Gulf of Aqaba 2026: 6.7 particles per litre.',
                style: typography.labelSm,
              ),
              SizedBox(height: spacing.md),
              Text(
                l10n.footprintStudyOpenQuestions,
                key: const Key('study-open-questions'),
                style: typography.subtitle,
              ),
              SizedBox(height: spacing.sm),
              for (final q in kOpenQuestions)
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.question, style: typography.bodySm),
                      Text(
                        l10n.footprintQuestionSize(q.size),
                        key: Key('question-size-${q.id}'),
                        style: typography.labelXs,
                      ),
                      Text(
                        l10n.footprintQuestionNext(q.step),
                        key: Key('question-next-${q.id}'),
                        style: typography.labelXs,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openHelp(BuildContext context) {
    final headline = result.headlineHabit ??
        (result.habits.isEmpty
            ? Habit.bottledWater
            : result.habits.first.habit);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => HelpConsentSheet(
        headlineHabit: headline,
        category: categoryKeyFor(headline),
        context: _contextPayload(),
      ),
    );
  }

  Map<String, dynamic> _contextPayload() {
    final byMass = result.habitsWithMass.isEmpty
        ? null
        : result.habitsWithMass.first.habit;
    return {
      'source': 'footprint',
      'coefficients_version': kCoefficientsVersion,
      'largest_by_count': result.headlineHabit?.name,
      'largest_by_mass': byMass?.name,
      'prediction': result.input.prediction?.name,
      'touched': result.touchedCount,
      'input': result.input.toJson(),
    };
  }
}

/// Reads the saved commitment date so the result screen can decide whether to
/// ask how it went.
DateTime? savedCommitmentDate() {
  final raw = SettingsManager().footprintState['commitment_at'] as String?;
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}
