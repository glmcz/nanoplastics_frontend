import 'package:flutter/widgets.dart';
import 'responsive_config.dart';
import 'app_sizing.dart';

/// Design token: spacing values scaled to device width
///
/// Usage: `AppSpacing.of(context).md`
class AppSpacing {
  final double scale;
  final double compactScale;

  /// change size of everything according screen size
  final double categoryScale;

  /// additional categor vertical boost.
  final bool isLandscape;
  AppSpacing(this.scale,
      {required this.compactScale,
      required this.categoryScale,
      required this.isLandscape});

  static AppSpacing of(BuildContext context) {
    final r = ResponsiveConfig.fromContext(context);
    double a = 1; // Default scale for normal-sized phones
    if (r.isBig) {
      a = 1;
    } else if (r.isCompact) {
      a = 0.85;
    }
    final categoryScale = AppSizing.categoryScaleFor(r);
    return AppSpacing(r.scaleW,
        compactScale: a,
        categoryScale: categoryScale,
        isLandscape: r.isLandscape);
  }

  // ── Base spacing scale ──

  double get xs => 4 * scale * compactScale;
  double get sm => 8 * scale * compactScale;
  double get md => 12 * scale * compactScale;
  double get lg => 16 * scale * compactScale;
  double get xl => 20 * scale * compactScale;
  double get xl2 => 24 * scale * compactScale;
  double get xl3 => 32 * scale * compactScale;

  // ── Semantic spacing ──

  double get contentPaddingH => 28 * scale * compactScale;
  double get contentPaddingV => 2 * scale * compactScale * categoryScale;
  double get cardPadding => 22 * scale * compactScale;
  double get cardSpacing => 18 * scale * compactScale;
  double get sectionSpacing => 30 * scale * compactScale;
  double get gridSpacing => 5 * scale * compactScale;
  double get gridRowSpacing => 5 * scale * compactScale * categoryScale;
  double get gridBottomPadding => 54 * scale * compactScale;

  // ── Header (secondary screens) ──

  double get headerPadding => 2 * scale * compactScale;
  // landscape: collapse gap above logo so it doesn't eat into PDF viewing space
  double get headerSpacing => isLandscape ? 0 : 10 * scale * compactScale;

  // ── Bottom navigation ──

  double get bottomNavPaddingH => 16 * scale * compactScale;
  double get bottomNavSpacing => 24 * scale * compactScale;
  double get bottomButtonPaddingH => 18 * scale * compactScale;
  double get bottomButtonSpacing => 10 * scale * compactScale;

  // ── Tab bar ──

  double get tabMarginH => 14 * scale * compactScale;
  double get tabInnerPadding => 3 * scale * compactScale;
  double get tabButtonPadding => 7 * scale * compactScale;

  // ── Control Hub ──

  double get hubGridGap => 10 * scale * compactScale;
  double get hubButtonGap => 6 * scale * compactScale;
}
