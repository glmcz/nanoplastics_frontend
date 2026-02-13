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

  AppSizing({
    required this.scaleW,
    required this.scaleH,
    required this.compactScale,
    required this.heroScale,
    required this.logoScale,
    required this.categoryScale,
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
    );
  }

  static double categoryScaleFor(ResponsiveConfig config) {
    if (!config.isBig) {
      return 1.0;
    }
    // Scale category cards based on height to fill vertical space on tall phones
    // Baseline: 812px height → 1.0x. Tall phone (e.g., 2000px) scales proportionally with no cap
    final heightScale = config.height / ResponsiveConfig.baseHeight;
    return heightScale;
  }

  // ── Icons ──

  double get iconXs => 16 * scaleW * compactScale;
  double get iconSm => 20 * scaleW * compactScale;
  double get iconMd => 24 * scaleW * compactScale;
  double get iconLg => 45 * scaleW * compactScale;
  double get iconXl => 80 * scaleW * compactScale;
  double get iconContainer => 40 * scaleW * compactScale;
  double get arrowSize => 20 * scaleW * compactScale;

  // ── Back button (navigation) ──

  double get backIcon => 17 * scaleW * compactScale; // iconMd * 0.7

  // ── Logos ──

  double get logoHeight => 70 * scaleH * compactScale * logoScale;
  double get logoHeightLg => logoHeight * 1.5;

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

  double get hubGridWidth => 340 * scaleW * compactScale;
  double get hubGridHeight => 140 * scaleW * compactScale;
  double get hubContainerHeight => 200 * scaleW * compactScale;
  double get hubBottomPadding => 30 * scaleW * compactScale;
  double get hubKnobSize => 62 * scaleW * compactScale;
  double get hubKnobBorderWidth => 6 * scaleW * compactScale;
  double get hubKnobIconSize => 24 * scaleW * compactScale;
  double get hubButtonIconSize => 22 * scaleW * compactScale;
  double get hubActiveGlowBlur => 20 * scaleW * compactScale;
}
