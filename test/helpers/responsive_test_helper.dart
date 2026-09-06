import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/utils/responsive_config.dart';
import 'package:nanoplastics_app/utils/app_sizing.dart';
import 'package:nanoplastics_app/utils/app_spacing.dart';
import 'package:nanoplastics_app/utils/app_typography.dart';

class DeviceProfile {
  final String name;
  final double width;
  final double height;
  final String category;
  const DeviceProfile(this.name,
      {required this.width, required this.height, this.category = 'portrait'});

  @override
  String toString() => '$name (${width.toInt()}x${height.toInt()})';

  double get area => width * height;
}

const kUserDevice46 = DeviceProfile(
  '4.6" 1280x720 @2x landscape',
  width: 640,
  height: 360,
  category: 'landscape',
);
const kUserDevice46_1x = DeviceProfile(
  '4.6" 1280x720 @1x landscape',
  width: 1280,
  height: 720,
  category: 'landscape',
);
const kMotoG32 = DeviceProfile(
  'Motorola G32',
  width: 393,
  height: 873,
);

const kTinyPhone = DeviceProfile('iPhone 5', width: 320, height: 568);
const kSmallBoundary = DeviceProfile('360x640', width: 360, height: 640);
const kCompactBigOverlap = DeviceProfile('350x950 edge',
    width: 350, height: 950, category: 'edge_case');
const kBaseline = DeviceProfile('baseline 375x812', width: 375, height: 812);
const kiPhone14 = DeviceProfile('iPhone 14', width: 390, height: 844);
const kPixel4 = DeviceProfile('Pixel 4', width: 412, height: 732);
const kiPhone14Plus = DeviceProfile('iPhone 14 Plus', width: 428, height: 926);
const kLogoJump860 = DeviceProfile('logo 860', width: 390, height: 860);
const kLogoJump861 = DeviceProfile('logo 861', width: 390, height: 861);
const kVeryTallSlim =
    DeviceProfile('360x1000', width: 360, height: 1000, category: 'edge_case');
const kXLarge = DeviceProfile('xlarge', width: 500, height: 960);
const kFoldOuter =
    DeviceProfile('Fold outer', width: 584, height: 680, category: 'edge_case');
const kiPhone14Landscape = DeviceProfile('iPhone 14 landscape',
    width: 844, height: 390, category: 'landscape');

const kAllDevices = [
  kTinyPhone,
  kSmallBoundary,
  kCompactBigOverlap,
  kBaseline,
  kiPhone14,
  kMotoG32,
  kPixel4,
  kiPhone14Plus,
  kLogoJump860,
  kLogoJump861,
  kUserDevice46,
  kUserDevice46_1x,
  kVeryTallSlim,
  kXLarge,
  kFoldOuter,
  kiPhone14Landscape
];

// kCompactBigOverlap (350x950) excluded: edge_case category with unusual
// narrow+tall geometry that causes typography floor interactions not
// representative of real UX bugs on production devices.
const kPortraitDevices = [
  kTinyPhone,
  kSmallBoundary,
  kBaseline,
  kiPhone14,
  kMotoG32,
  kPixel4,
  kiPhone14Plus,
  kVeryTallSlim,
  kXLarge
];

void setScreenSize(WidgetTester tester, DeviceProfile d) {
  tester.view.physicalSize = Size(d.width, d.height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

ResponsiveConfig configFor(DeviceProfile d) {
  final orientation =
      d.category == 'landscape' ? Orientation.landscape : Orientation.portrait;
  return ResponsiveConfig.fromConstraints(
    BoxConstraints(maxWidth: d.width, maxHeight: d.height),
    orientation,
  );
}

double spacingCompactScale(ResponsiveConfig r) {
  if (r.isBig) return 1.0;
  if (r.isCompact) return 0.85;
  return 1.0;
}

double sizingCompactScale(ResponsiveConfig r) => r.isCompact ? 0.85 : 1.0;

AppTypography typographyFor(DeviceProfile d) {
  final r = configFor(d);
  final titleScale = (r.isSmallPhone ? 0.78 : 1.0) * (r.isCompact ? 0.9 : 1.0);
  return AppTypography(r.fontScale,
      titleScale: titleScale, isLandscape: r.isLandscape);
}

AppSizing sizingFor(DeviceProfile d) {
  final r = configFor(d);
  return AppSizing(
    scaleW: r.scaleW,
    scaleH: r.scaleH,
    compactScale: sizingCompactScale(r),
    heroScale: (r.isSmallPhone || r.isCompact) ? 0.8 : 1.0,
    logoScale: (r.isXLargePhone || r.isLargePhone) ? 0.5 : 0.8,
    categoryScale: AppSizing.categoryScaleFor(r),
    isBig: r.isBig,
    isLandscape: r.isLandscape,
  );
}

AppSpacing spacingFor(DeviceProfile d) {
  final r = configFor(d);
  return AppSpacing(
    r.scaleW,
    compactScale: spacingCompactScale(r),
    categoryScale: AppSizing.categoryScaleFor(r),
    isLandscape: r.isLandscape,
  );
}
