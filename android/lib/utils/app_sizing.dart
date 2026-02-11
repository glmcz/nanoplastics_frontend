import 'package:flutter/widgets.dart';
import 'responsive_config.dart';

/// Design token: sizing values (icons, containers, radii) scaled to device
///
/// Usage: `AppSizing.of(context).iconMd`
class AppSizing {
  final double scaleW;
  final double scaleH;

  AppSizing({required this.scaleW, required this.scaleH});

  static AppSizing of(BuildContext context) {
    final r = ResponsiveConfig.fromContext(context);
    return AppSizing(scaleW: r.scaleW, scaleH: r.scaleH);
  }

  // ── Icons ──

  double get iconXs => 16 * scaleW;
  double get iconSm => 20 * scaleW;
  double get iconMd => 24 * scaleW;
  double get iconLg => 45 * scaleW;
  double get iconXl => 80 * scaleW;
  double get iconContainer => 40 * scaleW;
  double get arrowSize => 20 * scaleW;

  // ── Back button (navigation) ──

  double get backIcon => 17 * scaleW; // iconMd * 0.7

  // ── Logos ──

  double get logoHeight => 60 * scaleH;

  // ── Hero ──

  double get heroIconSize => 110 * scaleW;
  double get heroPadding => 24 * scaleH;
  double get heroIconInnerSize => heroIconSize * 0.55;

  // ── Avatar ──

  double get avatarSm => 80 * scaleW;
  double get avatarMd => 90 * scaleW;
  double get avatarIconSize => avatarMd * 0.5;

  // ── Bottom navigation ──

  double get bottomNavPaddingV => 20 * scaleH;
  double get bottomButtonPaddingV => 8 * scaleH;
  double get bottomButtonIconSize => 30 * scaleW;

  // ── Tab bar ──

  double get tabMarginV => 10 * scaleW;

  // ── Category card ──

  double get categoryIconContainer => 30 * scaleW;
  double get categoryIconSize => 31 * scaleW;
  double get categoryPadding => 12 * scaleW;

  // ── Radius ──

  double get radiusSm => 6 * scaleW;
  double get radiusMd => 12 * scaleW;
  double get radiusLg => 16 * scaleW;
  double get radiusXl => 20 * scaleW;

  // ── Blur ──

  double get blurSigma => 6.0;
  double get backdropBlurSigma => 11 * scaleW;

  // ── Shadows ──

  double get shadowBlur => 22 * scaleW;
  double get shadowSpread => 2.5 * scaleW;

  // ── Border ──

  double get borderThin => 1.0;
  double get borderMedium => 2 * scaleW;
  double get borderThick => 3.5 * scaleW;

  // ── Touch targets ──

  double get minTouchTarget => 44 * scaleW;

  // ── Settings joystick ──

  double get joystickSize => 48 * scaleW;
  double get joystickIconSize => 22 * scaleW;
  double get joystickBorderWidth => 1.5 * scaleW;
  double get joystickShadowBlur => 12 * scaleW;
  double get joystickShadowSpread => 1 * scaleW;

  // ── QR / link icons ──

  double get qrCodeSize => iconXl * 2.5;
  double get qrCodeIconSize => iconXl;
  double get linkIconSize => iconSm;
  double get secondaryIconSize => iconXs;
}
