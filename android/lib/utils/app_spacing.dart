import 'package:flutter/widgets.dart';
import 'responsive_config.dart';

/// Design token: spacing values scaled to device width
///
/// Usage: `AppSpacing.of(context).md`
class AppSpacing {
  final double scale;

  AppSpacing(this.scale);

  static AppSpacing of(BuildContext context) {
    final r = ResponsiveConfig.fromContext(context);
    return AppSpacing(r.scaleW);
  }

  // ── Base spacing scale ──

  double get xs => 4 * scale;
  double get sm => 8 * scale;
  double get md => 12 * scale;
  double get lg => 16 * scale;
  double get xl => 20 * scale;
  double get xl2 => 24 * scale;
  double get xl3 => 32 * scale;

  // ── Semantic spacing ──

  double get contentPadding => 28 * scale;
  double get cardPadding => 22 * scale;
  double get cardSpacing => 18 * scale;
  double get sectionSpacing => 30 * scale;
  double get gridSpacing => 10 * scale;
  double get gridBottomPadding => 54 * scale;

  // ── Header (secondary screens) ──

  double get headerPadding => 10 * scale;
  double get headerSpacing => 10 * scale;

  // ── Bottom navigation ──

  double get bottomNavPaddingH => 16 * scale;
  double get bottomNavSpacing => 24 * scale;
  double get bottomButtonPaddingH => 18 * scale;
  double get bottomButtonSpacing => 10 * scale;

  // ── Tab bar ──

  double get tabMarginH => 14 * scale;
  double get tabInnerPadding => 3 * scale;
  double get tabButtonPadding => 7 * scale;
}
