import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../config/app_colors.dart';
import '../utils/app_typography.dart';
import '../utils/app_theme_colors.dart';
import 'settings_manager.dart';

/// Keys bundle passed from MainScreen to AdvisorTourService.
/// Keeps GlobalKey ownership in MainScreen while giving the service
/// a typed, discoverable reference to each target widget.
class MainScreenTourKeys {
  final GlobalKey logoKey;
  final GlobalKey categoryGridKey;
  final GlobalKey humanButtonKey;
  final GlobalKey planetButtonKey;
  final GlobalKey sourcesButtonKey;
  final GlobalKey resultsButtonKey;
  final GlobalKey centerKnobKey;

  const MainScreenTourKeys({
    required this.logoKey,
    required this.categoryGridKey,
    required this.humanButtonKey,
    required this.planetButtonKey,
    required this.sourcesButtonKey,
    required this.resultsButtonKey,
    required this.centerKnobKey,
  });
}

/// App advisor tour service for guiding first-time users through the app.
/// Uses tutorial_coach_mark package with glassmorphism tooltips.
class AdvisorTourService {
  AdvisorTourService._();

  /// Show the advisor tour if the user hasn't seen it yet.
  /// Safe to call multiple times; only shows once per device.
  static Future<void> showIfNeeded(
    BuildContext context,
    MainScreenTourKeys keys,
  ) async {
    final settings = SettingsManager();
    if (settings.hasShownAdvisorTour) return;

    // Mark as shown immediately so a crash mid-tour doesn't re-show it
    await settings.setAdvisorTourShown(true);

    if (!context.mounted) return;
    _show(context, keys);
  }

  static void _show(BuildContext context, MainScreenTourKeys keys) {
    final typography = AppTypography.of(context);
    final tc = AppThemeColors.of(context);

    final targets = <TargetFocus>[
      // Step 1 — Logo / App identity
      TargetFocus(
        identify: 'logo',
        keyTarget: keys.logoKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _TourTooltip(
              title: 'NanoSolve Hive',
              body:
                  'Your R&D platform for crowdsourcing nanoplastic solutions.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),

      // Step 2 — Category grid
      TargetFocus(
        identify: 'category_grid',
        keyTarget: keys.categoryGridKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              title: 'Impact Categories',
              body:
                  'Tap any card to explore research areas. Switch between Human and Planet impacts below.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),

      // Step 3 — Human / Planet tabs
      TargetFocus(
        identify: 'human_button',
        keyTarget: keys.humanButtonKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              title: 'Human & Planet Views',
              body:
                  'Switch between how nanoplastics affect the human body and planet ecosystems.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),

      // Step 4 — Sources
      TargetFocus(
        identify: 'sources_button',
        keyTarget: keys.sourcesButtonKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              title: 'Scientific Sources',
              body:
                  'Browse peer-reviewed research and download the full PDF report.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),

      // Step 5 — Results
      TargetFocus(
        identify: 'results_button',
        keyTarget: keys.resultsButtonKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              title: 'AI-Ranked Results',
              body:
                  'See the best community ideas ranked by our AI. Submit yours to climb the leaderboard.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),

      // Step 6 — Settings knob (final step)
      TargetFocus(
        identify: 'center_knob',
        keyTarget: keys.centerKnobKey,
        shape: ShapeLightFocus.Circle,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              title: 'Settings',
              body: 'Manage your profile, language, and app preferences.',
              typography: typography,
              tc: tc,
              controller: controller,
              isFinal: true,
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      textSkip: 'SKIP TOUR',
      alignSkip: Alignment.topRight,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      onFinish: () {},
      onSkip: () => true,
    ).show(context: context);
  }
}

/// Glassmorphism tooltip widget for each tour step.
class _TourTooltip extends StatelessWidget {
  final String title;
  final String body;
  final AppTypography typography;
  final AppThemeColors tc;
  final dynamic controller; // CoachMarkController from tutorial_coach_mark
  final bool isFinal;

  const _TourTooltip({
    required this.title,
    required this.body,
    required this.typography,
    required this.tc,
    required this.controller,
    this.isFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tc.cardBackground.withValues(alpha: 0.90),
              tc.surfaceMid.withValues(alpha: 0.95),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.pastelAqua.withValues(alpha: 0.12),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: typography.title.copyWith(
                color: AppColors.pastelAqua,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: typography.body.copyWith(
                color: tc.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => controller.skip(),
                  child: Text(
                    'SKIP',
                    style: typography.label.copyWith(
                      color: tc.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => isFinal
                      ? controller.finish()
                      : controller.next(),
                  child: Text(
                    isFinal ? 'DONE' : 'NEXT',
                    style: typography.label.copyWith(
                      color: AppColors.pastelAqua,
                    ),
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
