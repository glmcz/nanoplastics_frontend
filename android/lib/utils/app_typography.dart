import 'package:flutter/widgets.dart';
import 'responsive_config.dart';

/// Design token: text styles scaled to device with semantic naming
///
/// Usage: `AppTypography.of(context).display`
class AppTypography {
  final double fontScale;

  AppTypography(this.fontScale);

  static AppTypography of(BuildContext context) {
    final r = ResponsiveConfig.fromContext(context);
    return AppTypography(r.fontScale);
  }

  /// Screen titles — large, bold
  TextStyle get display => TextStyle(
        fontSize: 28 * fontScale,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        height: 1.2,
      );

  /// Section titles — medium emphasis
  TextStyle get headline => TextStyle(
        fontSize: 20 * fontScale,
        fontWeight: FontWeight.w800,
        height: 1.25,
      );

  /// Card titles, setting item names
  TextStyle get title => TextStyle(
        fontSize: 17 * fontScale,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  /// Tab / navigation text
  TextStyle get tab => TextStyle(
        fontSize: 13 * fontScale,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  /// Subtitles, descriptions
  TextStyle get subtitle => TextStyle(
        fontSize: 15 * fontScale,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  /// Body text
  TextStyle get body => TextStyle(
        fontSize: 14 * fontScale,
        height: 1.6,
      );

  /// Small body
  TextStyle get bodySm => TextStyle(
        fontSize: 12 * fontScale,
        height: 1.5,
      );

  /// Labels, badges, navigation
  TextStyle get label => TextStyle(
        fontSize: 12 * fontScale,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      );

  /// Small labels, counts
  TextStyle get labelSm => TextStyle(
        fontSize: 11 * fontScale,
        fontWeight: FontWeight.w600,
      );

  /// Tiny labels, badges
  TextStyle get labelXs => TextStyle(
        fontSize: 10 * fontScale,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );

  /// Large stat numbers
  TextStyle get stat => TextStyle(
        fontSize: 31 * fontScale,
        fontWeight: FontWeight.w900,
      );

  /// Back button / navigation link
  TextStyle get back => TextStyle(
        fontSize: 12.5 * fontScale,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      );
}
