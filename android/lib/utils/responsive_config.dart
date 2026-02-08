import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';

/// Centralized responsive configuration for the app.
///
/// Two target screen sizes:
///   - small:  phones ~4.5"  (width < 400px)
///   - medium: phones ~6.2"  (width > 400px)
///
/// Uses MediaQuery for screen-based layouts (recommended Flutter practice).
/// Uses LayoutBuilder constraints for parent-constrained widgets (e.g., grid items).
class ResponsiveConfig {
  final double width;
  final double height;
  final BuildContext? context;

  /// Create from MediaQuery - use for full-screen responsive layouts.
  ResponsiveConfig.fromMediaQuery(BuildContext context)
      : width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height,
        context = context;

  /// Create from LayoutBuilder constraints - use for parent-constrained widgets.
  ResponsiveConfig.fromConstraints(BoxConstraints constraints)
      : width = constraints.maxWidth,
        height = constraints.maxHeight,
        context = null;

  /// Screen size category based on width (breakpoint: 400px).
  ScreenSize get screenSize =>
      width < 400 ? ScreenSize.small : ScreenSize.medium;

  /// Screen height category (breakpoint: 500px).
  ScreenHeight get screenHeight =>
      height < 500 ? ScreenHeight.small : ScreenHeight.medium;

  // ── Bottom navigation ──────────────────────────────────────────────

  BottomNavConfig get bottomNavConfig {
    switch (screenSize) {
      case ScreenSize.small:
        return BottomNavConfig(
          horizontalPadding: AppConstants.space16,
          verticalPadding: AppConstants.space4,
          spacing: AppConstants.space16,
        );
      case ScreenSize.medium:
        return BottomNavConfig(
          horizontalPadding: AppConstants.space16,
          verticalPadding: AppConstants.space40,
          spacing: AppConstants.space32,
        );
    }
  }

  // ── Main screen header ─────────────────────────────────────────────

  MainScreenHeaderConfig getMainScreenHeaderConfig() {
    _requireContext('getMainScreenHeaderConfig');
    switch (screenSize) {
      case ScreenSize.small:
        return MainScreenHeaderConfig(
          logoHeight: AppConstants.logoSmall,
          horizontalPadding: AppConstants.space20,
          verticalPadding: 0,
          titleStyle: Theme.of(context!).textTheme.displaySmall,
          subtitleStyle: Theme.of(context!).textTheme.labelSmall,
        );
      case ScreenSize.medium:
        return MainScreenHeaderConfig(
          logoHeight: AppConstants.logoMedium,
          horizontalPadding: 0,
          verticalPadding: AppConstants.space20,
          titleStyle: Theme.of(context!).textTheme.displayMedium,
          subtitleStyle: Theme.of(context!).textTheme.labelMedium,
        );
    }
  }

  // ── Bottom button ──────────────────────────────────────────────────

  BottomButtonConfig getBottomButtonConfig() {
    _requireContext('getBottomButtonConfig');
    switch (screenSize) {
      case ScreenSize.small:
        return BottomButtonConfig(
          iconSize: AppConstants.iconMedium,
          verticalPadding: AppConstants.space8,
          horizontalPadding: AppConstants.space12,
          spacing: AppConstants.space8,
          textStyle: Theme.of(context!).textTheme.labelLarge,
        );
      case ScreenSize.medium:
        return BottomButtonConfig(
          iconSize: AppConstants.iconLarge,
          verticalPadding: 0,
          horizontalPadding: AppConstants.space24,
          spacing: AppConstants.space14,
          textStyle: Theme.of(context!).textTheme.headlineMedium,
        );
    }
  }

  // ── Tab bar (top navigation) ──────────────────────────────────────

  TabBarConfig getTabBarConfig() {
    _requireContext('getTabBarConfig');
    switch (screenSize) {
      case ScreenSize.small:
        return TabBarConfig(
          marginH: AppConstants.space12,
          marginV: AppConstants.space8,
          innerPadding: 3,
          buttonPaddingV: AppConstants.space6,
          buttonPaddingH: AppConstants.space6,
          textStyle: Theme.of(context!).textTheme.labelLarge,
        );
      case ScreenSize.medium:
        return TabBarConfig(
          marginH: AppConstants.space16,
          marginV: AppConstants.space12,
          innerPadding: 3,
          buttonPaddingV: AppConstants.space8,
          buttonPaddingH: AppConstants.space8,
          textStyle: Theme.of(context!).textTheme.titleSmall,
        );
    }
  }

  // ── Category card ──────────────────────────────────────────────────

  CategoryCardConfig getCategoryCardConfig() {
    _requireContext('getCategoryCardConfig');
    switch (screenSize) {
      case ScreenSize.small:
        return CategoryCardConfig(
          iconContainerSize: AppConstants.iconContainerSmall,
          iconSize: AppConstants.space32,
          spacing: AppConstants.space8,
          padding: AppConstants.space10,
          gridRowSpacing: AppConstants.space8,
          gridColumnSpacing: AppConstants.space8,
          gridBottomPadding: AppConstants.space48,
          titleStyle: Theme.of(context!).textTheme.headlineMedium,
          descStyle: Theme.of(context!).textTheme.bodyMedium,
        );
      case ScreenSize.medium:
        return CategoryCardConfig(
          iconContainerSize: AppConstants.logoXS,
          iconSize: AppConstants.space30,
          spacing: AppConstants.space20,
          padding: AppConstants.space14,
          gridRowSpacing: AppConstants.space12,
          gridColumnSpacing: AppConstants.space12,
          gridBottomPadding: AppConstants.space60,
          titleStyle: Theme.of(context!).textTheme.headlineLarge,
          descStyle: Theme.of(context!).textTheme.bodyMedium,
        );
    }
  }

  // ── Onboarding slide ───────────────────────────────────────────────

  OnboardingSlideConfig getOnboardingSlideConfig() {
    _requireContext('getOnboardingSlideConfig');
    switch (screenHeight) {
      case ScreenHeight.small:
        return OnboardingSlideConfig(
          imageHeightPercent: 0.20,
          spacing: AppConstants.space8,
          iconRatio: 0.26,
          iconSizeMultiplier: 0.44,
          headerPadding: AppConstants.space8,
          footerPadding: AppConstants.space20,
          sectionSpacing: 0,
          slideHeightPercent: 0.60,
          minSlideHeight: 300.0,
          maxSlideHeight: 300.0,
          titleStyle: Theme.of(context!).textTheme.headlineSmall,
          descStyle: Theme.of(context!).textTheme.bodySmall,
        );
      case ScreenHeight.medium:
        return OnboardingSlideConfig(
          imageHeightPercent: 0.25,
          spacing: AppConstants.space20,
          iconRatio: 0.30,
          iconSizeMultiplier: 0.48,
          headerPadding: AppConstants.space12,
          footerPadding: AppConstants.space24,
          sectionSpacing: 0,
          slideHeightPercent: 0.65,
          minSlideHeight: 300.0,
          maxSlideHeight: 300.0,
          titleStyle: Theme.of(context!).textTheme.headlineXL,
          descStyle: Theme.of(context!).textTheme.bodyMedium,
        );
    }
  }

  // ── Category detail header ─────────────────────────────────────────

  CategoryDetailHeaderConfig getCategoryDetailHeaderConfig() {
    _requireContext('getCategoryDetailHeaderConfig');
    switch (screenSize) {
      case ScreenSize.small:
        return CategoryDetailHeaderConfig(
          logoHeight: AppConstants.logoSmall,
          padding: AppConstants.space20,
          spacing: AppConstants.space14,
          backIconSize: AppConstants.space16,
          titleStyle: Theme.of(context!).textTheme.displaySmall,
          backTextStyle: Theme.of(context!).textTheme.labelSmall,
        );
      case ScreenSize.medium:
        return CategoryDetailHeaderConfig(
          logoHeight: AppConstants.logoMedium,
          padding: AppConstants.space24,
          spacing: AppConstants.space16,
          backIconSize: AppConstants.space20,
          titleStyle: Theme.of(context!).textTheme.displayMedium,
          backTextStyle: Theme.of(context!).textTheme.titleSmall,
        );
    }
  }

  // ── Category detail hero icon ──────────────────────────────────────

  CategoryDetailHeroConfig get heroIconConfig {
    switch (screenSize) {
      case ScreenSize.small:
        return CategoryDetailHeroConfig(
          iconSize: AppConstants.heroIconSmall,
          verticalPadding: AppConstants.space16,
        );
      case ScreenSize.medium:
        return CategoryDetailHeroConfig(
          iconSize: AppConstants.heroIconMedium,
          verticalPadding: AppConstants.space32,
        );
    }
  }

  // ── Secondary screen header (sources, results, settings, profile) ──

  SecondaryHeaderConfig getSecondaryHeaderConfig() {
    _requireContext('getSecondaryHeaderConfig');
    switch (screenSize) {
      case ScreenSize.small:
        return SecondaryHeaderConfig(
          padding: AppConstants.space4,
          logoHeight: AppConstants.logoSmall,
          iconSize: AppConstants.iconMedium,
          spacing: AppConstants.space4,
          backStyle: Theme.of(context!).textTheme.labelLarge,
        );
      case ScreenSize.medium:
        return SecondaryHeaderConfig(
          padding: AppConstants.space10,
          logoHeight: AppConstants.logoMedium,
          iconSize: 28,
          spacing: AppConstants.space10,
          backStyle: Theme.of(context!).textTheme.titleSmall,
        );
    }
  }

  // ── Sources screen ─────────────────────────────────────────────────

  SourcesScreenConfig getSourcesScreenConfig() {
    _requireContext('getSourcesScreenConfig');
    switch (screenSize) {
      case ScreenSize.small:
        return SourcesScreenConfig(
          contentPaddingH: AppConstants.space14,
          reportMarginH: AppConstants.space14,
          reportMarginV: AppConstants.space14,
          reportPaddingH: AppConstants.space10,
          reportPaddingV: AppConstants.space10,
          tabMarginH: AppConstants.space14,
          tabMarginV: AppConstants.space10,
          tabPadding: AppConstants.space5,
          tabButtonPaddingV: AppConstants.space12,
          sectionPadding: AppConstants.space16,
          sectionIconSize: AppConstants.space20,
          sectionIconPadding: AppConstants.space8,
          sectionArrowSize: AppConstants.iconMedium,
          cardPadding: AppConstants.space15,
          cardSpacing: AppConstants.space12,
          pdfIconSize: AppConstants.space20,
          videoIconSize: AppConstants.iconLarge,
          reportLabelStyle: Theme.of(context!).textTheme.labelMedium,
          reportTitleStyle: Theme.of(context!).textTheme.titleMedium,
          tabStyle: Theme.of(context!).textTheme.labelMedium,
          sectionTitleStyle: Theme.of(context!).textTheme.titleSmall,
          sectionCountStyle: Theme.of(context!).textTheme.labelMedium,
          cardTitleStyle: Theme.of(context!).textTheme.titleSmall,
          cardDescStyle: Theme.of(context!).textTheme.labelMedium,
          badgeStyle: Theme.of(context!).textTheme.labelSmall,
          numberStyle: Theme.of(context!).textTheme.labelSmall,
          hintStyle: Theme.of(context!).textTheme.labelSmall,
          videoTextStyle: Theme.of(context!).textTheme.bodyMedium,
        );
      case ScreenSize.medium:
        return SourcesScreenConfig(
          contentPaddingH: AppConstants.space32,
          reportMarginH: AppConstants.space30,
          reportMarginV: AppConstants.space12,
          reportPaddingH: AppConstants.space20,
          reportPaddingV: AppConstants.space12,
          tabMarginH: AppConstants.space30,
          tabMarginV: AppConstants.space24,
          tabPadding: AppConstants.space6,
          tabButtonPaddingV: AppConstants.space16,
          sectionPadding: AppConstants.space20,
          sectionIconSize: AppConstants.iconMedium,
          sectionIconPadding: AppConstants.space10,
          sectionArrowSize: 28,
          cardPadding: AppConstants.space20,
          cardSpacing: AppConstants.space16,
          pdfIconSize: AppConstants.iconMedium,
          videoIconSize: AppConstants.iconXL,
          reportLabelStyle: Theme.of(context!).textTheme.labelLarge,
          reportTitleStyle: Theme.of(context!).textTheme.titleLarge,
          tabStyle: Theme.of(context!).textTheme.headlineMedium,
          sectionTitleStyle: Theme.of(context!).textTheme.headlineLarge,
          sectionCountStyle: Theme.of(context!).textTheme.labelMedium,
          cardTitleStyle: Theme.of(context!).textTheme.headlineMedium,
          cardDescStyle: Theme.of(context!).textTheme.headlineMedium,
          badgeStyle: Theme.of(context!).textTheme.labelMedium,
          numberStyle: Theme.of(context!).textTheme.labelMedium,
          hintStyle: Theme.of(context!).textTheme.labelMedium,
          videoTextStyle: Theme.of(context!).textTheme.bodyLarge,
        );
    }
  }

  // ── Results screen ─────────────────────────────────────────────────

  ResultsScreenConfig getResultsScreenConfig() {
    _requireContext('getResultsScreenConfig');
    switch (screenSize) {
      case ScreenSize.small:
        return ResultsScreenConfig(
          contentHorizontalPadding: AppConstants.space12,
          contentVerticalPadding: AppConstants.space4,
          statsIconContainer: 50,
          statsIconSize: 26,
          statsValueStyle: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
          infoIconSize: AppConstants.space20,
          titleStyle: Theme.of(context!).textTheme.displayMedium,
          subtitleStyle: Theme.of(context!).textTheme.bodyMedium,
          statsTitleStyle: Theme.of(context!).textTheme.labelLarge,
          infoTitleStyle: Theme.of(context!).textTheme.labelLarge,
          infoBodyStyle: Theme.of(context!).textTheme.bodyMedium,
          sectionSpacing: AppConstants.space30,
          cardSpacing: AppConstants.space16,
          titleSpacing: AppConstants.space8,
          statsIconSpacing: AppConstants.space16,
          statsValueSpacing: AppConstants.space4,
          infoIconSpacing: AppConstants.space12,
          infoBodySpacing: AppConstants.space16,
        );
      case ScreenSize.medium:
        return ResultsScreenConfig(
          contentHorizontalPadding: AppConstants.space32,
          contentVerticalPadding: AppConstants.space16,
          statsIconContainer: AppConstants.space60,
          statsIconSize: AppConstants.space30,
          statsValueStyle: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
          infoIconSize: AppConstants.iconMedium,
          titleStyle: Theme.of(context!).textTheme.displayLarge,
          subtitleStyle: Theme.of(context!).textTheme.bodyMedium,
          statsTitleStyle: Theme.of(context!).textTheme.titleSmall,
          infoTitleStyle: Theme.of(context!).textTheme.titleSmall,
          infoBodyStyle: Theme.of(context!).textTheme.bodyMedium,
          sectionSpacing: AppConstants.space30,
          cardSpacing: AppConstants.space16,
          titleSpacing: AppConstants.space8,
          statsIconSpacing: AppConstants.space16,
          statsValueSpacing: AppConstants.space4,
          infoIconSpacing: AppConstants.space12,
          infoBodySpacing: AppConstants.space16,
        );
    }
  }

  // ── Settings screen ────────────────────────────────────────────────

  SettingsScreenConfig getSettingsScreenConfig() {
    _requireContext('getSettingsScreenConfig');
    switch (screenSize) {
      case ScreenSize.small:
        return SettingsScreenConfig(
          contentPadding: AppConstants.space24,
          cardPadding: AppConstants.space20,
          iconContainerSize: AppConstants.iconContainerSmall,
          iconSize: 26,
          arrowSize: AppConstants.iconSmall,
          cardSpacing: AppConstants.space16,
          titleStyle: Theme.of(context!).textTheme.displayMedium,
          subtitleStyle: Theme.of(context!).textTheme.bodyMedium,
          cardTitleStyle: Theme.of(context!).textTheme.bodyLarge,
          fieldPadding: AppConstants.space20,
          avatarSize: AppConstants.avatarSmall,
          avatarBorderWidth: 2,
          toggleIconContainer: 38,
          toggleIconSize: AppConstants.space20,
          sectionBarWidth: 3,
          sectionBarHeight: AppConstants.iconSmall,
          dangerPadding: AppConstants.space16,
          dangerButtonPadding: AppConstants.space12,
          dangerIconSize: AppConstants.space20,
          dangerArrowSize: AppConstants.iconXS,
          sectionTitleStyle: Theme.of(context!).textTheme.titleSmall,
          fieldLabelStyle: Theme.of(context!).textTheme.labelMedium,
          fieldInputStyle: Theme.of(context!).textTheme.titleSmall,
          toggleTitleStyle: Theme.of(context!).textTheme.bodyMedium,
          toggleSubStyle: Theme.of(context!).textTheme.labelMedium,
          avatarHintStyle: Theme.of(context!).textTheme.labelMedium,
          dangerTitleStyle: Theme.of(context!).textTheme.bodyMedium,
          dangerSubStyle: Theme.of(context!).textTheme.labelSmall,
          linkIconSize: 18,
          linkIconSpacing: 8,
          secondaryIconSize: 14,
          secondaryIconSpacing: 4,
          qrCodeSize: 200,
          qrCodeIconSize: 80,
          qrCodePadding: 16,
          qrCodeTextFontSize: 14,
          qrCodeUrlFontSize: 10,
          textLineHeight: 1.6,
          borderWidth: 3,
          shadowBlurRadius: 20,
          shadowSpreadRadius: 2,
          lightShadowBlurRadius: 15,
          backdropBlurSigma: 10,
        );
      case ScreenSize.medium:
        return SettingsScreenConfig(
          contentPadding: AppConstants.space32,
          cardPadding: AppConstants.space24,
          iconContainerSize: 56,
          iconSize: AppConstants.space30,
          arrowSize: 22,
          cardSpacing: AppConstants.space20,
          titleStyle: Theme.of(context!).textTheme.headlineXXL,
          subtitleStyle: Theme.of(context!).textTheme.headlineLarge,
          cardTitleStyle: Theme.of(context!).textTheme.headlineLarge,
          fieldPadding: AppConstants.space20,
          avatarSize: AppConstants.avatarMedium,
          avatarBorderWidth: 3,
          toggleIconContainer: AppConstants.avatarXS,
          toggleIconSize: AppConstants.iconMedium,
          sectionBarWidth: 4,
          sectionBarHeight: AppConstants.space20,
          dangerPadding: AppConstants.space20,
          dangerButtonPadding: AppConstants.space15,
          dangerIconSize: 22,
          dangerArrowSize: AppConstants.space16,
          sectionTitleStyle: Theme.of(context!).textTheme.titleLarge,
          fieldLabelStyle: Theme.of(context!).textTheme.bodyMedium,
          fieldInputStyle: Theme.of(context!).textTheme.titleLarge,
          toggleTitleStyle: Theme.of(context!).textTheme.bodyMedium,
          toggleSubStyle: Theme.of(context!).textTheme.labelLarge,
          avatarHintStyle: Theme.of(context!).textTheme.labelLarge,
          dangerTitleStyle: Theme.of(context!).textTheme.bodyMedium,
          dangerSubStyle: Theme.of(context!).textTheme.labelMedium,
          linkIconSize: 20,
          linkIconSpacing: 10,
          secondaryIconSize: 16,
          secondaryIconSpacing: 6,
          qrCodeSize: 240,
          qrCodeIconSize: 100,
          qrCodePadding: 20,
          qrCodeTextFontSize: 16,
          qrCodeUrlFontSize: 12,
          textLineHeight: 1.8,
          borderWidth: 4,
          shadowBlurRadius: 25,
          shadowSpreadRadius: 3,
          lightShadowBlurRadius: 20,
          backdropBlurSigma: 12,
        );
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  void _requireContext(String methodName) {
    if (context == null) {
      throw StateError('context is required for $methodName');
    }
  }
}

// ── Enums ──────────────────────────────────────────────────────────────

enum ScreenSize { small, medium }

enum ScreenHeight { small, medium }

// ── Configuration data classes ─────────────────────────────────────────

class BottomNavConfig {
  final double horizontalPadding;
  final double verticalPadding;
  final double spacing;

  BottomNavConfig({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.spacing,
  });
}

class BottomButtonConfig {
  final double iconSize;
  final double verticalPadding;
  final double horizontalPadding;
  final double spacing;
  final TextStyle? textStyle;

  BottomButtonConfig({
    required this.iconSize,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.spacing,
    required this.textStyle,
  });
}

class MainScreenHeaderConfig {
  final double logoHeight;
  final double horizontalPadding;
  final double verticalPadding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  MainScreenHeaderConfig({
    required this.logoHeight,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.titleStyle,
    required this.subtitleStyle,
  });
}

class CategoryCardConfig {
  final double iconContainerSize;
  final double iconSize;
  final double spacing;
  final double padding;
  final double gridRowSpacing;
  final double gridColumnSpacing;
  final double gridBottomPadding;
  final TextStyle? titleStyle;
  final TextStyle? descStyle;

  CategoryCardConfig({
    required this.iconContainerSize,
    required this.iconSize,
    required this.spacing,
    required this.padding,
    required this.gridRowSpacing,
    required this.gridColumnSpacing,
    required this.gridBottomPadding,
    required this.titleStyle,
    required this.descStyle,
  });
}

class OnboardingSlideConfig {
  final double imageHeightPercent;
  final double spacing;
  final double iconRatio;
  final double iconSizeMultiplier;
  final double headerPadding;
  final double footerPadding;
  final double sectionSpacing;
  final double slideHeightPercent;
  final double minSlideHeight;
  final double maxSlideHeight;
  final TextStyle? titleStyle;
  final TextStyle? descStyle;

  OnboardingSlideConfig({
    required this.imageHeightPercent,
    required this.spacing,
    required this.iconRatio,
    required this.iconSizeMultiplier,
    required this.headerPadding,
    required this.footerPadding,
    required this.sectionSpacing,
    required this.slideHeightPercent,
    required this.minSlideHeight,
    required this.maxSlideHeight,
    required this.titleStyle,
    required this.descStyle,
  });
}

class CategoryDetailHeaderConfig {
  final double logoHeight;
  final double padding;
  final double spacing;
  final double backIconSize;
  final TextStyle? titleStyle;
  final TextStyle? backTextStyle;

  CategoryDetailHeaderConfig({
    required this.logoHeight,
    required this.padding,
    required this.spacing,
    required this.backIconSize,
    required this.titleStyle,
    required this.backTextStyle,
  });
}

class CategoryDetailHeroConfig {
  final double iconSize;
  final double verticalPadding;

  CategoryDetailHeroConfig({
    required this.iconSize,
    required this.verticalPadding,
  });
}

class SecondaryHeaderConfig {
  final double padding;
  final double logoHeight;
  final double iconSize;
  final double spacing;
  final TextStyle? backStyle;

  SecondaryHeaderConfig({
    required this.padding,
    required this.logoHeight,
    required this.iconSize,
    required this.spacing,
    required this.backStyle,
  });
}

class SourcesScreenConfig {
  final double contentPaddingH;
  final double reportMarginH;
  final double reportMarginV;
  final double reportPaddingH;
  final double reportPaddingV;
  final double tabMarginH;
  final double tabMarginV;
  final double tabPadding;
  final double tabButtonPaddingV;
  final double sectionPadding;
  final double sectionIconSize;
  final double sectionIconPadding;
  final double sectionArrowSize;
  final double cardPadding;
  final double cardSpacing;
  final double pdfIconSize;
  final double videoIconSize;
  final TextStyle? reportLabelStyle;
  final TextStyle? reportTitleStyle;
  final TextStyle? tabStyle;
  final TextStyle? sectionTitleStyle;
  final TextStyle? sectionCountStyle;
  final TextStyle? cardTitleStyle;
  final TextStyle? cardDescStyle;
  final TextStyle? badgeStyle;
  final TextStyle? numberStyle;
  final TextStyle? hintStyle;
  final TextStyle? videoTextStyle;

  SourcesScreenConfig({
    required this.contentPaddingH,
    required this.reportMarginH,
    required this.reportMarginV,
    required this.reportPaddingH,
    required this.reportPaddingV,
    required this.tabMarginH,
    required this.tabMarginV,
    required this.tabPadding,
    required this.tabButtonPaddingV,
    required this.sectionPadding,
    required this.sectionIconSize,
    required this.sectionIconPadding,
    required this.sectionArrowSize,
    required this.cardPadding,
    required this.cardSpacing,
    required this.pdfIconSize,
    required this.videoIconSize,
    required this.reportLabelStyle,
    required this.reportTitleStyle,
    required this.tabStyle,
    required this.sectionTitleStyle,
    required this.sectionCountStyle,
    required this.cardTitleStyle,
    required this.cardDescStyle,
    required this.badgeStyle,
    required this.numberStyle,
    required this.hintStyle,
    required this.videoTextStyle,
  });
}

class ResultsScreenConfig {
  final double contentHorizontalPadding;
  final double contentVerticalPadding;
  final double statsIconContainer;
  final double statsIconSize;
  final TextStyle? statsValueStyle;
  final double infoIconSize;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? statsTitleStyle;
  final TextStyle? infoTitleStyle;
  final TextStyle? infoBodyStyle;
  final double sectionSpacing;
  final double cardSpacing;
  final double titleSpacing;
  final double statsIconSpacing;
  final double statsValueSpacing;
  final double infoIconSpacing;
  final double infoBodySpacing;

  ResultsScreenConfig({
    required this.contentHorizontalPadding,
    required this.contentVerticalPadding,
    required this.statsIconContainer,
    required this.statsIconSize,
    required this.statsValueStyle,
    required this.infoIconSize,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.statsTitleStyle,
    required this.infoTitleStyle,
    required this.infoBodyStyle,
    required this.sectionSpacing,
    required this.cardSpacing,
    required this.titleSpacing,
    required this.statsIconSpacing,
    required this.statsValueSpacing,
    required this.infoIconSpacing,
    required this.infoBodySpacing,
  });
}

class TabBarConfig {
  final double marginH;
  final double marginV;
  final double innerPadding;
  final double buttonPaddingV;
  final double buttonPaddingH;
  final TextStyle? textStyle;

  TabBarConfig({
    required this.marginH,
    required this.marginV,
    required this.innerPadding,
    required this.buttonPaddingV,
    required this.buttonPaddingH,
    required this.textStyle,
  });
}

class SettingsScreenConfig {
  final double contentPadding;
  final double cardPadding;
  final double iconContainerSize;
  final double iconSize;
  final double arrowSize;
  final double cardSpacing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? cardTitleStyle;
  final double? fieldPadding;
  final double? avatarSize;
  final double? avatarBorderWidth;
  final double? toggleIconContainer;
  final double? toggleIconSize;
  final double? sectionBarWidth;
  final double? sectionBarHeight;
  final double? dangerPadding;
  final double? dangerButtonPadding;
  final double? dangerIconSize;
  final double? dangerArrowSize;
  final TextStyle? sectionTitleStyle;
  final TextStyle? fieldLabelStyle;
  final TextStyle? fieldInputStyle;
  final TextStyle? toggleTitleStyle;
  final TextStyle? toggleSubStyle;
  final TextStyle? avatarHintStyle;
  final TextStyle? dangerTitleStyle;
  final TextStyle? dangerSubStyle;
  final double? linkIconSize;
  final double? linkIconSpacing;
  final double? secondaryIconSize;
  final double? secondaryIconSpacing;
  final double? qrCodeSize;
  final double? qrCodeIconSize;
  final double? qrCodePadding;
  final double? qrCodeTextFontSize;
  final double? qrCodeUrlFontSize;
  final double? textLineHeight;
  final double? borderWidth;
  final double? shadowBlurRadius;
  final double? shadowSpreadRadius;
  final double? lightShadowBlurRadius;
  final double? backdropBlurSigma;

  SettingsScreenConfig({
    required this.contentPadding,
    required this.cardPadding,
    required this.iconContainerSize,
    required this.iconSize,
    required this.arrowSize,
    required this.cardSpacing,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.cardTitleStyle,
    this.fieldPadding,
    this.avatarSize,
    this.avatarBorderWidth,
    this.toggleIconContainer,
    this.toggleIconSize,
    this.sectionBarWidth,
    this.sectionBarHeight,
    this.dangerPadding,
    this.dangerButtonPadding,
    this.dangerIconSize,
    this.dangerArrowSize,
    this.sectionTitleStyle,
    this.fieldLabelStyle,
    this.fieldInputStyle,
    this.toggleTitleStyle,
    this.toggleSubStyle,
    this.avatarHintStyle,
    this.dangerTitleStyle,
    this.dangerSubStyle,
    this.linkIconSize,
    this.linkIconSpacing,
    this.secondaryIconSize,
    this.secondaryIconSpacing,
    this.qrCodeSize,
    this.qrCodeIconSize,
    this.qrCodePadding,
    this.qrCodeTextFontSize,
    this.qrCodeUrlFontSize,
    this.textLineHeight,
    this.borderWidth,
    this.shadowBlurRadius,
    this.shadowSpreadRadius,
    this.lightShadowBlurRadius,
    this.backdropBlurSigma,
  });
}
