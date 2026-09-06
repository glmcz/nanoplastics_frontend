import 'package:flutter/material.dart';

import '../../features/footprint/chapters.dart';
import '../../features/footprint/footprint_format.dart';
import '../../features/footprint/footprint_model.dart';
import '../../features/footprint/footprint_strings_l10n.dart';
import '../../features/footprint/footprint_types.dart';
import '../../l10n/app_localizations.dart';
import '../../services/service_locator.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';
import '../../widgets/footprint/chapter_page.dart';
import '../../widgets/footprint/particle_cloud.dart';
import '../../widgets/shared/screen_header.dart';
import 'footprint_result_screen.dart';

/// One ordinary day, told as seven chapters.
class FootprintStoryScreen extends StatefulWidget {
  const FootprintStoryScreen({super.key});

  @override
  State<FootprintStoryScreen> createState() => FootprintStoryScreenState();
}

class FootprintStoryScreenState extends State<FootprintStoryScreen> {
  final PageController _controller = PageController();

  FootprintInput input = FootprintInput.gulfDefault();
  bool started = false;
  bool cloudPaused = false;
  int index = 0;
  bool _reachedResult = false;

  @override
  void dispose() {
    if (started && !_reachedResult) {
      ServiceLocator()
          .eventService
          .log('footprint_abandoned', props: {'index': index});
    }
    _controller.dispose();
    super.dispose();
  }

  void _touch(ChapterKey key) {
    if (input.touched.contains(key)) return;
    setState(() {
      input = input.copyWith(touched: {...input.touched, key});
    });
  }

  void _start({required bool skip}) {
    ServiceLocator()
        .eventService
        .log('footprint_started', props: {'mode': skip ? 'skip' : 'story'});
    if (skip) {
      _openResult(mode: 'skip');
      return;
    }
    setState(() => started = true);
  }

  void _openResult({required String mode}) {
    _reachedResult = true;
    ServiceLocator().eventService.log(
      'footprint_result',
      props: {'mode': mode, 'touched_count': input.touched.length},
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FootprintResultScreen(input: input),
      ),
    );
  }

  void _next() {
    if (index == kChapters.length - 1) {
      _openResult(mode: 'story');
      return;
    }
    setState(() => index++);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    ServiceLocator().eventService.log(
      'footprint_chapter',
      props: {'index': index, 'touched': input.touched.length},
    );
  }

  void _back() {
    if (index == 0) {
      setState(() => started = false);
      return;
    }
    setState(() => index--);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(),
            Expanded(child: started ? _buildStory() : _buildIntro()),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.contentPaddingH,
        vertical: spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.footprintIntroTitle, style: typography.title),
          SizedBox(height: spacing.md),
          Text(l10n.footprintIntroBody, style: typography.body),
          SizedBox(height: spacing.sm),
          Text(l10n.footprintIntroReassurance, style: typography.bodySm),
          SizedBox(height: spacing.xl),
          Center(
            child: ElevatedButton(
              key: const Key('story-start'),
              onPressed: () => _start(skip: false),
              child: Text(l10n.footprintStart),
            ),
          ),
          SizedBox(height: spacing.md),
          Center(
            child: TextButton(
              key: const Key('story-skip'),
              // Narrative persuades the already-curious; people who only want
              // facts do better with facts.
              onPressed: () => _start(skip: true),
              child: Text(l10n.footprintSkipStory),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStory() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final result = estimate(input);
    final strings = L10nFootprintStrings(l10n);
    final subMicron = result.byFamily(Family.swallowedSubMicron);
    final total = subMicron.fold<double>(0, (a, h) => a + h.particlesPerYear);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.contentPaddingH),
          // One cloud, above the pages, owned by this screen. Inside a page it
          // would animate twice during a chapter change.
          child: ParticleCloud(
            habits: subMicron,
            semanticLabel: formatParticles(total, strings),
            paused: cloudPaused,
            onTogglePause: () => setState(() => cloudPaused = !cloudPaused),
            // A share of the screen rather than a fixed shape, so a short
            // landscape window does not lose the chapter beneath it.
            height: (MediaQuery.of(context).size.height * 0.14).clamp(48, 120),
          ),
        ),
        _buildProgressDots(),
        Expanded(
          child: PageView(
            controller: _controller,
            // Deliberate: main.dart installs a right-edge back gesture for RTL
            // that eats a forward swipe, and horizontal sliders inside a page
            // fight a horizontal PageView for the same drag.
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final chapter in kChapters)
                ChapterPage(
                  chapter: chapter,
                  input: input,
                  // Preserve `touched`: the chapter page builds its new
                  // input from the value it was given, so a plain assignment
                  // would discard the answered-flag that onTouched just set.
                  onChanged: (v) => setState(
                    () => input = v.copyWith(touched: input.touched),
                  ),
                  onTouched: () => _touch(chapter.key),
                  showWhy: input.touched.contains(chapter.key),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(spacing.md),
          // Flexible rather than fixed: at 200% text scale two natural-width
          // buttons do not fit side by side on a phone.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextButton(
                  key: const Key('story-back'),
                  onPressed: _back,
                  child: Text(
                    l10n.footprintBack,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              Flexible(
                child: ElevatedButton(
                  key: const Key('story-next'),
                  onPressed: _next,
                  child: Text(
                    index == kChapters.length - 1
                        ? l10n.footprintSeeMyYear
                        : l10n.footprintNext,
                    style: typography.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDots() {
    final spacing = AppSpacing.of(context);
    final colors = AppThemeColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < kChapters.length; i++)
            Container(
              width: spacing.sm,
              height: spacing.sm,
              margin: EdgeInsets.symmetric(horizontal: spacing.xs / 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == index ? colors.textMain : colors.textDark,
              ),
            ),
        ],
      ),
    );
  }
}
