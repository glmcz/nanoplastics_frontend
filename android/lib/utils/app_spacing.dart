import 'package:flutter/widgets.dart';
import 'responsive_config.dart';
import 'app_sizing.dart';

/// Design token: spacing values scaled to device width
///
/// Usage: `AppSpacing.of(context).md`
class AppSpacing {
  final double scale;
  final double compactScale;
  final double categoryScale;
  AppSpacing(this.scale,
      {required this.compactScale, required this.categoryScale});

  static AppSpacing of(BuildContext context) {
    final r = ResponsiveConfig.fromContext(context);
    double a = 0;
    if (r.isBig) {
      a = 1.5;
    } else if (r.isCompact) {
      a = 0.85;
    } else {
      a = 1.0;
    }
    final categoryScale = AppSizing.categoryScaleFor(r);
    return AppSpacing(r.scaleW, compactScale: a, categoryScale: categoryScale);
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

  double get contentPadding => 28 * scale * compactScale;
  double get cardPadding => 22 * scale * compactScale;
  double get cardSpacing => 18 * scale * compactScale;
  double get sectionSpacing => 30 * scale * compactScale;
  double get gridSpacing => 10 * scale * compactScale;
  double get gridRowSpacing => 10 * scale * compactScale * categoryScale;
  double get gridBottomPadding => 54 * scale * compactScale;

  // ── Header (secondary screens) ──

  double get headerPadding => 2 * scale * compactScale;
  double get headerSpacing => 10 * scale * compactScale;

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
