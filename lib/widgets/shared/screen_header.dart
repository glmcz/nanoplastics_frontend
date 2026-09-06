import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';
import '../nanosolve_logo.dart';

/// Standard screen header: optional back button + centered NanosolveLogo.
///
/// Pass [backLabel] to show the back row; omit it for logo-only headers.
class ScreenHeader extends StatelessWidget {
  /// Text shown next to the back arrow. Defaults to the app-wide back label
  /// from l10n when not provided.
  final String? backLabel;

  /// Called when the back row is tapped. Defaults to [Navigator.maybePop].
  final VoidCallback? onBack;

  const ScreenHeader({super.key, this.backLabel, this.onBack});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final themeColors = AppThemeColors.of(context);

    final label =
        backLabel ?? AppLocalizations.of(context)!.categoryDetailBackToOverview;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.contentPaddingH,
        vertical: spacing.contentPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios,
                        color: themeColors.textMain, size: sizing.backIcon),
                    const SizedBox(width: AppConstants.space4),
                    Flexible(
                      child: Text(
                        label,
                        style: typography.back
                            .copyWith(color: themeColors.textMain),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: spacing.headerSpacing),
          NanosolveLogo(height: sizing.logoHeightLg),
        ],
      ),
    );
  }
}
