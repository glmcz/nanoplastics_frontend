import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';
import '../utils/app_theme_colors.dart';
import '../utils/responsive_config.dart';
import '../widgets/vault_setup.dart';
import 'settings_manager.dart';

/// The main screen's widgets the first-launch tour points at.
class ExtendedTourKeys {
  final GlobalKey logoKey;
  final GlobalKey categoryGridKey;
  final GlobalKey humanButtonKey;
  final GlobalKey planetButtonKey;
  final GlobalKey humanPlanetRowKey;
  final GlobalKey sourcesButtonKey;
  final GlobalKey resultsButtonKey;
  final GlobalKey centerKnobKey;

  const ExtendedTourKeys({
    required this.logoKey,
    required this.categoryGridKey,
    required this.humanButtonKey,
    required this.planetButtonKey,
    required this.humanPlanetRowKey,
    required this.sourcesButtonKey,
    required this.resultsButtonKey,
    required this.centerKnobKey,
  });
}

/// The first-launch tour of the main screen. It ends on the Vault and the
/// daily digest, which need an email, and offers to set that up on the spot:
/// buried under Settings → My Vault, nobody found out a code was needed.
class ExtendedTourService {
  static bool get _shouldSuppressTourUi {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    return bindingType.contains('TestWidgetsFlutterBinding');
  }

  /// The full tour on first launch; for anyone who finished it before the
  /// Vault step existed, that one step on its own, once.
  static Future<void> showIfNeeded(
    BuildContext context,
    ExtendedTourKeys keys, {
    VoidCallback? onSwitchToHuman,
  }) async {
    final settings = SettingsManager();
    if (settings.hasShownAdvisorTour && settings.hasShownVaultIntro) return;
    final vaultOnly = settings.hasShownAdvisorTour;

    // Marked before showing, so a language change (app restart) mid-tour does
    // not start it again.
    await settings.setAdvisorTourShown(true);
    await settings.setVaultIntroShown(true);

    if (!context.mounted || _shouldSuppressTourUi) return;

    // Lets the iOS page transition (~400 ms) finish first; measured mid-slide,
    // the category grid spotlight landed at the right edge of the screen.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!context.mounted) return;
      final targets = [
        if (!vaultOnly) ..._mainTargets(context, keys),
        _vaultTarget(context, keys),
      ];
      TutorialCoachMark(
        targets: targets,
        colorShadow: Colors.black,
        opacityShadow: 0.85,
        textSkip: AppLocalizations.of(context)!.tourBtnSkipTour,
        alignSkip: Alignment.topRight,
        paddingFocus: 4,
        focusAnimationDuration: const Duration(milliseconds: 300),
        pulseAnimationDuration: const Duration(milliseconds: 800),
        onClickTarget: (target) {
          if (target.identify == 'tour_human_planet_row') {
            onSwitchToHuman?.call();
          }
        },
        onSkip: () => true,
      ).show(context: context);
    });
  }

  static TargetFocus _target(
    String id,
    GlobalKey key, {
    required ShapeLightFocus shape,
    required ContentAlign align,
    required String Function(AppLocalizations) body,
    double? paddingFocus,
  }) =>
      TargetFocus(
        identify: id,
        keyTarget: key,
        shape: shape,
        paddingFocus: paddingFocus,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: align,
            builder: (context, controller) => _TourTooltip(
              body: body(AppLocalizations.of(context)!),
              controller: controller,
            ),
          ),
        ],
      );

  static List<TargetFocus> _mainTargets(
          BuildContext context, ExtendedTourKeys keys) =>
      [
        // The grid sits at the top of the screen: always explain below it.
        _target('tour_category_grid', keys.categoryGridKey,
            shape: ShapeLightFocus.RRect,
            align: ContentAlign.bottom,
            paddingFocus: 4,
            body: (l) => l.tourCategoryGridBody),
        _target('tour_human_planet_row', keys.humanPlanetRowKey,
            shape: ShapeLightFocus.RRect,
            align: ContentAlign.top,
            paddingFocus: 8,
            body: (l) => l.tourHumanPlanetBody),
        _target('tour_sources_button', keys.sourcesButtonKey,
            shape: ShapeLightFocus.Circle,
            align: ContentAlign.top,
            body: (l) => l.tourSourcesButtonBody),
        _target('tour_results_button', keys.resultsButtonKey,
            shape: ShapeLightFocus.Circle,
            align: ContentAlign.top,
            body: (l) => l.tourResultsButtonBody),
        _target('tour_center_knob', keys.centerKnobKey,
            shape: ShapeLightFocus.Circle,
            align: ContentAlign.top,
            body: (l) => l.tourSettingsBody),
      ];

  /// The Vault lives under the settings knob, so the step points there.
  static TargetFocus _vaultTarget(
          BuildContext screenContext, ExtendedTourKeys keys) =>
      TargetFocus(
        identify: 'tour_vault',
        keyTarget: keys.centerKnobKey,
        shape: ShapeLightFocus.Circle,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              final l10n = AppLocalizations.of(context)!;
              return _TourTooltip(
                body: l10n.tourVaultBody,
                controller: controller,
                isFinal: true,
                actionLabel: l10n.tourVaultAction,
                // The overlay's context dies with the tour; navigate from the
                // screen underneath.
                onAction: () {
                  controller.skip();
                  openVaultSetup(screenContext);
                },
              );
            },
          ),
        ],
      );
}

/// Glassmorphism tooltip for a tour step.
class _TourTooltip extends StatelessWidget {
  final String body;
  final TutorialCoachMarkController controller;
  final bool isFinal;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _TourTooltip({
    required this.body,
    required this.controller,
    this.isFinal = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveConfig.fromContext(context);
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final tc = AppThemeColors.of(context);
    final isCompact = responsive.isCompact;
    final tooltipWidth = responsive.isBig
        ? spacing.lg * 25
        : (isCompact ? spacing.lg * 17.5 : spacing.lg * 20);
    final buttonStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: const Size(44, 24),
      tapTargetSize: MaterialTapTargetSize.padded,
    );
    final buttonText = typography.label.copyWith(
      color: AppColors.pastelAqua,
      fontSize: 11,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: tooltipWidth),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tc.cardBackground.withValues(alpha: 0.92),
              tc.surfaceMid.withValues(alpha: 0.96),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.pastelAqua.withValues(alpha: 0.12),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: typography.body.copyWith(
                color: tc.textMuted,
                fontSize: isCompact ? 10 : 11,
                height: 1.3,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.end,
              children: [
                if (actionLabel != null)
                  TextButton(
                    style: buttonStyle.copyWith(
                      backgroundColor: WidgetStatePropertyAll(
                          AppColors.pastelAqua.withValues(alpha: 0.15)),
                    ),
                    onPressed: onAction,
                    child: Text(actionLabel!,
                        style:
                            buttonText.copyWith(fontWeight: FontWeight.w700)),
                  ),
                TextButton(
                  style: buttonStyle,
                  onPressed: () => controller.next(),
                  child: Text(
                    isFinal
                        ? AppLocalizations.of(context)!.tourBtnDone
                        : AppLocalizations.of(context)!.tourBtnNext,
                    style: buttonText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
