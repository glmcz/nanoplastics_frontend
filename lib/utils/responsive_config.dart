import 'package:flutter/widgets.dart';

// ── Enums ──────────────────────────────────────────────────────────

enum PhoneSize { small, normal, large, xlarge }

enum PhoneOrientation { portrait, landscape }

// ── Core ───────────────────────────────────────────────────────────

/// Responsive configuration - measurement and scale ONLY
///
/// For design tokens, use:
/// - AppSpacing.of(context) - spacing values
/// - AppSizing.of(context) - icons, containers, radii
/// - AppTypography.of(context) - text styles
class ResponsiveConfig {
  final double width;
  final double height;
  final Orientation orientation;

  // ── Constructors ──

  ResponsiveConfig.fromContext(BuildContext context)
      : width = MediaQuery.sizeOf(context).width,
        height = MediaQuery.sizeOf(context).height,
        orientation = MediaQuery.orientationOf(context);

  ResponsiveConfig.fromMediaQuery(BuildContext context)
      : this.fromContext(context);

  ResponsiveConfig.fromConstraints(
    BoxConstraints constraints,
    this.orientation,
  )   : width = constraints.maxWidth,
        height = constraints.maxHeight;

  // ── Orientation ──

  PhoneOrientation get phoneOrientation => orientation == Orientation.portrait
      ? PhoneOrientation.portrait
      : PhoneOrientation.landscape;

  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  // ── Width breakpoints ──

  PhoneSize get phoneSize {
    if (width < 360) return PhoneSize.small;
    if (width < 400) return PhoneSize.normal;
    if (width < 480) return PhoneSize.large;
    return PhoneSize.xlarge;
  }

  bool get isSmallPhone => phoneSize == PhoneSize.small;
  bool get isNormalPhone => phoneSize == PhoneSize.normal;
  bool get isLargePhone => phoneSize == PhoneSize.large;
  bool get isXLargePhone => phoneSize == PhoneSize.xlarge;

  bool get isCompact => width < 360 || height < 700;
  bool get isBig => width > 410 || height > 900;

  // ── Scaling (baseline: 375 × 812) ──

  static const double baseWidth = 375;
  static const double baseHeight = 812;

  double get scaleW => width / baseWidth;
  double get scaleH => height / baseHeight;
  double get fontScale => scaleW.clamp(0.85, 1.3);

  // ── Grid ──

  int get gridColumns {
    if (isLandscape) return 3;
    return 2;
  }
}
