import 'package:flutter/widgets.dart';
import 'responsive_config.dart';

/// Design token: sizing values (icons, containers, radii) scaled to device
///
/// Usage: `AppSizing.of(context).iconMd`
class AppSizing {
  final double scaleW;
  final double scaleH;
  final double compactScale;
  final double heroScale;
  final double logoScale;
  final double categoryScale;
  final bool isBig;
  final bool isLandscape;

  AppSizing({
    required this.scaleW,
    required this.scaleH,
    required this.compactScale,
    required this.heroScale,
    required this.logoScale,
    required this.categoryScale,
    required this.isBig,
    required this.isLandscape,
  });

  static AppSizing of(BuildContext context) {
    final r = ResponsiveConfig.fromContext(context);
    final compactScale = r.isCompact ? 0.85 : 1.0;
    final heroScale = (r.isSmallPhone || r.isCompact) ? 0.8 : 1.0;
    final logoScale = r.isXLargePhone ? 0.5 : (r.isLargePhone ? 0.5 : 0.8);
    final categoryScale = categoryScaleFor(r);
    return AppSizing(
      scaleW: r.scaleW,
      scaleH: r.scaleH,
      compactScale: compactScale,
      heroScale: heroScale,
      logoScale: logoScale,
      categoryScale: categoryScale,
      isBig: r.isBig,
      isLandscape: r.isLandscape,
    );
  }

  static double categoryScaleFor(ResponsiveConfig config) {
    if (!config.isBig) {
      return 1.0;
    }
    // Scale category cards based on height to fill vertical space on tall phones
    // Baseline: 812px height → 1.0x. Tall phone (e.g., 2000px) scales proportionally with no cap
    final heightScale = config.height / ResponsiveConfig.baseHeight;
    return heightScale * 1.2;
  }

  // ── Icons ──
  double get iconXss => 8 * scaleW * compactScale;
  double get iconXs => 16 * scaleW * compactScale;
  double get iconSm => 20 * scaleW * compactScale;
  double get iconMd => 24 * scaleW * compactScale;
  double get iconLg => 45 * scaleW * compactScale;
  double get iconXl => 80 * scaleW * compactScale;
  double get iconContainer => 40 * scaleW * compactScale;
  double get arrowSize => 20 * scaleW * compactScale;

  // ── Back button (navigation) ──

  // portrait: scales with device width; landscape: fixed base so scaleW boost doesn't enlarge it
  double get backIcon =>
      isLandscape ? 6.5 * compactScale : 17 * scaleW * compactScale;

  // ── Logos ──

  // landscape: scaleH ≈ 0.46 makes the result ~14px regardless of multiplier — use fixed value instead
  double get logoHeight =>
      isLandscape ? 21.0 : 70 * scaleH * compactScale * logoScale;

  /// Large logo for all screen headers.
  /// On compact-height phones (≤860dp, e.g. 6.1" iPhone 16e) the 1.5× multiplier
  /// would push the logo to ~87px while 6.5" phones get only ~58px — a 29px header
  /// gap that shifts content toward the hub. Cap at logoHeight on short screens.
  double get logoHeightLg {
    if (isLandscape) return 21.0;
    if (scaleH * 812 <= 860) {
      return logoHeight; // skip the 1.5× boost on short screens
    }
    return logoHeight * 1.5;
  }

  // ── Hero ──

  double get heroIconSize => 110 * scaleW * compactScale * heroScale;
  double get heroPadding => 24 * scaleH * compactScale * heroScale;
  double get heroIconInnerSize => heroIconSize * 0.55;

  // ── Avatar ──

  double get avatarSm => 80 * scaleW * compactScale;
  double get avatarMd => 90 * scaleW * compactScale;
  double get avatarIconSize => avatarMd * 0.5;

  // ── Bottom navigation ──

  double get bottomNavPaddingV => 20 * scaleH * compactScale;
  double get bottomButtonPaddingV => 8 * scaleH * compactScale;
  double get bottomButtonIconSize => 30 * scaleW * compactScale;

  // ── Tab bar ──

  double get tabMarginV => 10 * scaleW * compactScale;

  // ── Category card ──

  double get categoryIconContainer =>
      30 * scaleW * compactScale * categoryScale;
  double get categoryIconSize => 31 * scaleW * compactScale * categoryScale;
  double get categoryPadding => 12 * scaleW * compactScale * categoryScale;

  // ── Radius ──

  double get radiusSm => 6 * scaleW * compactScale;
  double get radiusMd => 12 * scaleW * compactScale;
  double get radiusLg => 16 * scaleW * compactScale;
  double get radiusXl => 20 * scaleW * compactScale;

  // ── Blur ──

  double get blurSigma => 6.0;
  double get backdropBlurSigma => 11 * scaleW * compactScale;

  // ── Shadows ──

  double get shadowBlur => 22 * scaleW * compactScale;
  double get shadowSpread => 2.5 * scaleW * compactScale;

  // ── Border ──

  double get borderThin => 1.0;
  double get borderMedium => 2 * scaleW * compactScale;
  double get borderThick => 3.5 * scaleW * compactScale;

  // ── Touch targets ──

  double get minTouchTarget => 44 * scaleW * compactScale;

  // ── Settings joystick ──

  double get joystickSize => 48 * scaleW * compactScale;
  double get joystickIconSize => 22 * scaleW * compactScale;
  double get joystickBorderWidth => 1.5 * scaleW * compactScale;
  double get joystickShadowBlur => 12 * scaleW * compactScale;
  double get joystickShadowSpread => 1 * scaleW * compactScale;

  // ── QR / link icons ──

  double get qrCodeSize => iconXl * 2.5;
  double get qrCodeIconSize => iconXl;
  double get linkIconSize => iconSm;
  double get secondaryIconSize => iconXs;

  // ── Control Hub ──
  double get w => isBig ? (400 * scaleW / 1.2) : (400 * scaleW * compactScale);
  double get hubGridWidth => w;
  double get hubGridHeight => 140 * scaleW * compactScale;
  double get hubContainerHeight => 200 * scaleW * compactScale;
  double get hubBottomPadding => 30 * scaleW * compactScale;
  double get hubKnobSize => 62 * scaleW * compactScale;
  double get hubKnobBorderWidth => 6 * scaleW * compactScale;
  double get hubKnobIconSize => 24 * scaleW * compactScale;
  double get hubButtonIconSize => 22 * scaleW * compactScale;
  double get hubActiveGlowBlur => 20 * scaleW * compactScale;
}
