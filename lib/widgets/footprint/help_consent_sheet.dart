import 'package:flutter/material.dart';

import '../../features/footprint/footprint_types.dart';
import '../../l10n/app_localizations.dart';
import '../../services/service_locator.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';
import 'chapter_page.dart' show habitLabel;

/// The Help door: a personal hook, three seed prompts, and consent that is
/// actually consent.
///
/// A line above a Send button is not consent. Storage, third-party scoring and
/// attaching habit answers are three separate decisions, and the third is
/// optional: the idea sends without it.
class HelpConsentSheet extends StatefulWidget {
  final Habit headlineHabit;
  final String category;
  final Map<String, dynamic> context;

  const HelpConsentSheet({
    super.key,
    required this.headlineHabit,
    required this.category,
    required this.context,
  });

  @override
  State<HelpConsentSheet> createState() => HelpConsentSheetState();
}

class HelpConsentSheetState extends State<HelpConsentSheet> {
  final TextEditingController _idea = TextEditingController();

  bool showConsent = false;
  bool agreeStorage = false;
  bool agreeScoring = false;
  bool agreeContext = false;
  bool agreeAge = false;
  bool sendAnonymously = false;
  bool sending = false;
  String? sentMessage;

  bool get canConfirm => agreeStorage && agreeScoring && agreeAge;

  @override
  void dispose() {
    _idea.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sentMessage != null) ...[
              Text(l10n.footprintHelpSentTitle, style: typography.subtitle),
              SizedBox(height: spacing.sm),
              Text(sentMessage!, style: typography.bodySm),
            ] else if (showConsent)
              _buildConsent(l10n, spacing, typography)
            else
              _buildIdea(l10n, spacing, typography),
          ],
        ),
      ),
    );
  }

  Widget _buildIdea(
      AppLocalizations l10n, AppSpacing spacing, AppTypography typography) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.footprintHelpHook(habitLabel(l10n, widget.headlineHabit)),
          style: typography.body,
        ),
        SizedBox(height: spacing.md),
        // A first-year asked to invent a lab instrument writes nothing.
        // These are at observation level.
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: [
            for (final seed in [
              l10n.footprintHelpSeed1,
              l10n.footprintHelpSeed2,
              l10n.footprintHelpSeed3,
            ])
              ActionChip(
                label: Text(seed, style: typography.labelXs),
                onPressed: () => setState(() => _idea.text = seed),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        TextField(
          key: const Key('help-idea-field'),
          controller: _idea,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.footprintHelpField,
            border: const OutlineInputBorder(),
          ),
        ),
        SizedBox(height: spacing.md),
        ElevatedButton(
          key: const Key('help-send'),
          // Opens consent. Nothing leaves the device on this tap.
          onPressed: () => setState(() => showConsent = true),
          child: Text(l10n.footprintHelpSend),
        ),
      ],
    );
  }

  Widget _buildConsent(
      AppLocalizations l10n, AppSpacing spacing, AppTypography typography) {
    return Column(
      key: const Key('consent-sheet'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.footprintConsentTitle, style: typography.subtitle),
        SizedBox(height: spacing.sm),
        CheckboxListTile(
          key: const Key('consent-storage'),
          value: agreeStorage,
          onChanged: (v) => setState(() => agreeStorage = v ?? false),
          title: Text(l10n.footprintConsentStorage, style: typography.bodySm),
        ),
        CheckboxListTile(
          key: const Key('consent-scoring'),
          value: agreeScoring,
          onChanged: (v) => setState(() => agreeScoring = v ?? false),
          title: Text(l10n.footprintConsentScoring, style: typography.bodySm),
        ),
        CheckboxListTile(
          key: const Key('consent-context'),
          value: agreeContext,
          onChanged: (v) => setState(() => agreeContext = v ?? false),
          title: Text(l10n.footprintConsentContext, style: typography.bodySm),
        ),
        CheckboxListTile(
          key: const Key('consent-age'),
          value: agreeAge,
          onChanged: (v) => setState(() => agreeAge = v ?? false),
          title: Text(l10n.footprintConsentAge, style: typography.bodySm),
        ),
        SwitchListTile(
          key: const Key('consent-anonymous'),
          value: sendAnonymously,
          onChanged: (v) => setState(() => sendAnonymously = v),
          title: Text(l10n.footprintConsentAnonymous, style: typography.bodySm),
        ),
        SizedBox(height: spacing.sm),
        Text(l10n.footprintConsentRetention, style: typography.labelXs),
        SizedBox(height: spacing.md),
        ElevatedButton(
          key: const Key('consent-confirm'),
          onPressed: canConfirm && !sending ? _send : null,
          child: Text(l10n.footprintConsentConfirm),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => sending = true);
    final result = await ServiceLocator().apiService.submitIdea(
          description: _idea.text,
          category: widget.category,
          anonymous: sendAnonymously,
          // Only attached when the student ticked that box specifically.
          context: agreeContext ? widget.context : null,
        );

    if (!mounted) return;
    final ok = result['success'] == true;
    if (ok) {
      ServiceLocator().eventService.log(
        'idea_sent',
        props: {'habit': widget.headlineHabit.name},
      );
    }
    setState(() {
      sending = false;
      sentMessage = ok ? l10n.footprintHelpSentBody : l10n.footprintHelpOffline;
    });
  }
}
