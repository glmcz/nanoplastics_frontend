import 'package:flutter/widgets.dart';
import 'responsive_config.dart';
import 'app_spacing.dart';
import 'app_sizing.dart';
import 'app_typography.dart';

class SecondaryHeaderConfig {
  final double padding;
  final double spacing;
  final double iconSize;
  final double logoHeight;

  const SecondaryHeaderConfig({
    required this.padding,
    required this.spacing,
    required this.iconSize,
    required this.logoHeight,
  });
}

class ResultsScreenConfig {
  final double contentHorizontalPadding;
  final double contentVerticalPadding;
  final double sectionSpacing;
  final double cardSpacing;
  final double titleSpacing;
  final double statsIconContainer;
  final double statsIconSize;
  final double infoIconSize;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? statsTitleStyle;
  final TextStyle? statsValueStyle;
  final TextStyle? infoTitleStyle;
  final TextStyle? infoBodyStyle;

  const ResultsScreenConfig({
    required this.contentHorizontalPadding,
    required this.contentVerticalPadding,
    required this.sectionSpacing,
    required this.cardSpacing,
    required this.titleSpacing,
    required this.statsIconContainer,
    required this.statsIconSize,
    required this.infoIconSize,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.statsTitleStyle,
    required this.statsValueStyle,
    required this.infoTitleStyle,
    required this.infoBodyStyle,
  });
}

class SourcesScreenConfig {
  final double reportMarginH;
  final double reportMarginV;
  final double reportPaddingH;
  final double reportPaddingV;
  final double pdfIconSize;
  final double tabMarginH;
  final double tabMarginV;
  final double tabPadding;
  final double tabButtonPaddingV;
  final double contentPaddingH;
  final double cardSpacing;
  final double cardPadding;
  final double sectionPadding;
  final double sectionIconPadding;
  final double sectionIconSize;
  final double sectionArrowSize;
  final TextStyle? reportLabelStyle;
  final TextStyle? reportTitleStyle;
  final TextStyle? tabStyle;
  final TextStyle? sectionTitleStyle;
  final TextStyle? sectionCountStyle;
  final TextStyle? cardTitleStyle;
  final TextStyle? cardDescStyle;
  final TextStyle? badgeStyle;
  final TextStyle? numberStyle;

  const SourcesScreenConfig({
    required this.reportMarginH,
    required this.reportMarginV,
    required this.reportPaddingH,
    required this.reportPaddingV,
    required this.pdfIconSize,
    required this.tabMarginH,
    required this.tabMarginV,
    required this.tabPadding,
    required this.tabButtonPaddingV,
    required this.contentPaddingH,
    required this.cardSpacing,
    required this.cardPadding,
    required this.sectionPadding,
    required this.sectionIconPadding,
    required this.sectionIconSize,
    required this.sectionArrowSize,
    required this.reportLabelStyle,
    required this.reportTitleStyle,
    required this.tabStyle,
    required this.sectionTitleStyle,
    required this.sectionCountStyle,
    required this.cardTitleStyle,
    required this.cardDescStyle,
    required this.badgeStyle,
    required this.numberStyle,
  });
}

class SettingsScreenConfig {
  final double contentPadding;
  final double cardSpacing;
  final double cardPadding;
  final double iconContainerSize;
  final double iconSize;
  final double arrowSize;
  final double sectionBarWidth;
  final double sectionBarHeight;
  final double toggleIconContainer;
  final double toggleIconSize;
  final double dangerIconSize;
  final double dangerArrowSize;

  final double? avatarSize;
  final double? avatarBorderWidth;
  final double? fieldPadding;
  final double? dangerPadding;
  final double? dangerButtonPadding;

  final double? backdropBlurSigma;
  final double? borderWidth;
  final double? shadowBlurRadius;
  final double? shadowSpreadRadius;
  final double? lightShadowBlurRadius;
  final double? textLineHeight;

  final double? qrCodePadding;
  final double? qrCodeSize;
  final double? qrCodeIconSize;
  final double? qrCodeTextFontSize;
  final double? qrCodeUrlFontSize;
  final double? linkIconSize;
  final double? linkIconSpacing;
  final double? secondaryIconSize;
  final double? secondaryIconSpacing;

  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? cardTitleStyle;
  final TextStyle? avatarHintStyle;
  final TextStyle? sectionTitleStyle;
  final TextStyle? fieldLabelStyle;
  final TextStyle? fieldInputStyle;
  final TextStyle? toggleTitleStyle;
  final TextStyle? toggleSubStyle;
  final TextStyle? dangerTitleStyle;
  final TextStyle? dangerSubStyle;

  const SettingsScreenConfig({
    required this.contentPadding,
    required this.cardSpacing,
    required this.cardPadding,
    required this.iconContainerSize,
    required this.iconSize,
    required this.arrowSize,
    required this.sectionBarWidth,
    required this.sectionBarHeight,
    required this.toggleIconContainer,
    required this.toggleIconSize,
    required this.dangerIconSize,
    required this.dangerArrowSize,
    required this.avatarSize,
    required this.avatarBorderWidth,
    required this.fieldPadding,
    required this.dangerPadding,
    required this.dangerButtonPadding,
    required this.backdropBlurSigma,
    required this.borderWidth,
    required this.shadowBlurRadius,
    required this.shadowSpreadRadius,
    required this.lightShadowBlurRadius,
    required this.textLineHeight,
    required this.qrCodePadding,
    required this.qrCodeSize,
    required this.qrCodeIconSize,
    required this.qrCodeTextFontSize,
    required this.qrCodeUrlFontSize,
    required this.linkIconSize,
    required this.linkIconSpacing,
    required this.secondaryIconSize,
    required this.secondaryIconSpacing,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.cardTitleStyle,
    required this.avatarHintStyle,
    required this.sectionTitleStyle,
    required this.fieldLabelStyle,
    required this.fieldInputStyle,
    required this.toggleTitleStyle,
    required this.toggleSubStyle,
    required this.dangerTitleStyle,
    required this.dangerSubStyle,
  });
}

class CategoryDetailHeaderConfig {
  final double padding;
  final double backIconSize;
  final double spacing;
  final double logoHeight;
  final TextStyle? backTextStyle;
  final TextStyle? titleStyle;

  const CategoryDetailHeaderConfig({
    required this.padding,
    required this.backIconSize,
    required this.spacing,
    required this.logoHeight,
    required this.backTextStyle,
    required this.titleStyle,
  });
}

class HeroIconConfig {
  final double iconSize;
  final double verticalPadding;

  const HeroIconConfig({
    required this.iconSize,
    required this.verticalPadding,
  });
}

class OnboardingSlideConfig {
  final double headerPadding;
  final double footerPadding;
  final double sectionSpacing;
  final double spacing;
  final double slideHeightPercent;
  final double minSlideHeight;
  final double maxSlideHeight;
  final double imageHeightPercent;
  final double iconRatio;
  final double iconSizeMultiplier;
  final TextStyle titleStyle;

  const OnboardingSlideConfig({
    required this.headerPadding,
    required this.footerPadding,
    required this.sectionSpacing,
    required this.spacing,
    required this.slideHeightPercent,
    required this.minSlideHeight,
    required this.maxSlideHeight,
    required this.imageHeightPercent,
    required this.iconRatio,
    required this.iconSizeMultiplier,
    required this.titleStyle,
  });
}

extension ScreenConfigExtensions on ResponsiveConfig {
  SecondaryHeaderConfig getSecondaryHeaderConfig() {
    final spacing = AppSpacing(scaleW);
    final sizing = AppSizing(scaleW: scaleW, scaleH: scaleH);

    return SecondaryHeaderConfig(
      padding: spacing.headerPadding,
      spacing: spacing.headerSpacing,
      iconSize: sizing.iconMd,
      logoHeight: sizing.logoHeight,
    );
  }

  ResultsScreenConfig getResultsScreenConfig() {
    final spacing = AppSpacing(scaleW);
    final sizing = AppSizing(scaleW: scaleW, scaleH: scaleH);
    final typography = AppTypography(fontScale);

    return ResultsScreenConfig(
      contentHorizontalPadding: spacing.contentPadding,
      contentVerticalPadding: spacing.contentPadding,
      sectionSpacing: spacing.sectionSpacing,
      cardSpacing: spacing.cardSpacing,
      titleSpacing: spacing.sm,
      statsIconContainer: sizing.iconContainer,
      statsIconSize: sizing.iconMd,
      infoIconSize: sizing.iconSm,
      titleStyle: typography.display,
      subtitleStyle: typography.subtitle,
      statsTitleStyle: typography.label,
      statsValueStyle: typography.stat,
      infoTitleStyle: typography.title,
      infoBodyStyle: typography.body,
    );
  }

  SourcesScreenConfig getSourcesScreenConfig() {
    final spacing = AppSpacing(scaleW);
    final sizing = AppSizing(scaleW: scaleW, scaleH: scaleH);
    final typography = AppTypography(fontScale);

    return SourcesScreenConfig(
      reportMarginH: spacing.contentPadding,
      reportMarginV: spacing.md,
      reportPaddingH: spacing.cardPadding,
      reportPaddingV: spacing.md,
      pdfIconSize: sizing.iconLg,
      tabMarginH: spacing.tabMarginH,
      tabMarginV: sizing.tabMarginV,
      tabPadding: spacing.tabInnerPadding,
      tabButtonPaddingV: spacing.tabButtonPadding,
      contentPaddingH: spacing.contentPadding,
      cardSpacing: spacing.cardSpacing,
      cardPadding: spacing.cardPadding,
      sectionPadding: spacing.cardPadding,
      sectionIconPadding: spacing.sm,
      sectionIconSize: sizing.iconMd,
      sectionArrowSize: sizing.iconSm,
      reportLabelStyle: typography.label,
      reportTitleStyle: typography.headline,
      tabStyle: typography.tab,
      sectionTitleStyle: typography.title,
      sectionCountStyle: typography.bodySm,
      cardTitleStyle: typography.title,
      cardDescStyle: typography.bodySm,
      badgeStyle: typography.labelSm,
      numberStyle: typography.label,
    );
  }

  SettingsScreenConfig getSettingsScreenConfig() {
    final spacing = AppSpacing(scaleW);
    final sizing = AppSizing(scaleW: scaleW, scaleH: scaleH);
    final typography = AppTypography(fontScale);

    return SettingsScreenConfig(
      contentPadding: spacing.contentPadding,
      cardSpacing: spacing.cardSpacing,
      cardPadding: spacing.cardPadding,
      iconContainerSize: sizing.iconContainer,
      iconSize: sizing.iconMd,
      arrowSize: sizing.arrowSize,
      sectionBarWidth: spacing.xs,
      sectionBarHeight: spacing.xl,
      toggleIconContainer: sizing.iconContainer,
      toggleIconSize: sizing.iconSm,
      dangerIconSize: sizing.iconSm,
      dangerArrowSize: sizing.arrowSize,
      avatarSize: sizing.avatarMd,
      avatarBorderWidth: sizing.borderMedium,
      fieldPadding: spacing.sm,
      dangerPadding: spacing.cardPadding,
      dangerButtonPadding: spacing.md,
      backdropBlurSigma: sizing.backdropBlurSigma,
      borderWidth: sizing.borderThick,
      shadowBlurRadius: sizing.shadowBlur,
      shadowSpreadRadius: sizing.shadowSpread,
      lightShadowBlurRadius: sizing.shadowBlur * 0.7,
      textLineHeight: typography.body.height ?? 1.6,
      qrCodePadding: spacing.md,
      qrCodeSize: sizing.iconXl * 2.5,
      qrCodeIconSize: sizing.iconXl,
      qrCodeTextFontSize: typography.body.fontSize ?? 14,
      qrCodeUrlFontSize: typography.labelXs.fontSize ?? 10,
      linkIconSize: sizing.iconSm,
      linkIconSpacing: spacing.sm,
      secondaryIconSize: sizing.iconXs,
      secondaryIconSpacing: spacing.xs,
      titleStyle: typography.display,
      subtitleStyle: typography.subtitle,
      cardTitleStyle: typography.title,
      avatarHintStyle: typography.label,
      sectionTitleStyle: typography.title,
      fieldLabelStyle: typography.label,
      fieldInputStyle: typography.body,
      toggleTitleStyle: typography.title,
      toggleSubStyle: typography.bodySm,
      dangerTitleStyle: typography.title,
      dangerSubStyle: typography.bodySm,
    );
  }

  CategoryDetailHeaderConfig getCategoryDetailHeaderConfig() {
    final spacing = AppSpacing(scaleW);
    final sizing = AppSizing(scaleW: scaleW, scaleH: scaleH);
    final typography = AppTypography(fontScale);

    return CategoryDetailHeaderConfig(
      padding: spacing.contentPadding,
      backIconSize: sizing.backIcon,
      spacing: spacing.headerSpacing,
      logoHeight: sizing.logoHeight,
      backTextStyle: typography.back,
      titleStyle: typography.headline,
    );
  }

  HeroIconConfig get heroIconConfig {
    final sizing = AppSizing(scaleW: scaleW, scaleH: scaleH);
    return HeroIconConfig(
      iconSize: sizing.heroIconSize,
      verticalPadding: sizing.heroPadding,
    );
  }

  OnboardingSlideConfig getOnboardingSlideConfig() {
    final spacing = AppSpacing(scaleW);
    final typography = AppTypography(fontScale);

    final isWide = isLandscape;

    return OnboardingSlideConfig(
      headerPadding: spacing.lg,
      footerPadding: spacing.lg,
      sectionSpacing: spacing.sectionSpacing,
      spacing: spacing.md,
      slideHeightPercent: isWide ? 0.65 : 0.75,
      minSlideHeight: (isWide ? 220 : 260) * scaleH,
      maxSlideHeight: (isWide ? 360 : 520) * scaleH,
      imageHeightPercent: isWide ? 0.35 : 0.4,
      iconRatio: 0.4,
      iconSizeMultiplier: 0.5,
      titleStyle: typography.display,
    );
  }
}
