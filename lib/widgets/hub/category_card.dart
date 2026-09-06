import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../models/category_data.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';

class CategoryCard extends StatelessWidget {
  final CategoryData category;
  final VoidCallback onTap;
  final double iconContainerSize;
  final double iconSize;
  final double padding;
  final TextStyle titleStyle;
  final TextStyle descStyle;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.iconContainerSize,
    required this.iconSize,
    required this.padding,
    required this.titleStyle,
    required this.descStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: category.title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: AppColors.cardBgGlass.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Builder(
                builder: (context) {
                  final contentGap = AppSpacing.of(context).xs * 0.5;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = constraints.maxWidth;
                      final cardHeight = constraints.maxHeight;
                      // Tight-height mode: landscape or very compressed cards.
                      final tightHeight = cardHeight > 0 && cardHeight < 90;
                      final dense = cardWidth < 180;
                      final iconScale =
                          tightHeight ? 0.75 : (dense ? 0.9 : 1.0);
                      final effectiveIconContainer = tightHeight
                          ? math.min(
                              iconContainerSize * iconScale,
                              (cardHeight * 0.40).clamp(20.0, double.infinity),
                            )
                          : iconContainerSize * iconScale;
                      final effectiveIconSize = math.min(
                        iconSize * iconScale,
                        effectiveIconContainer * 0.82,
                      );
                      final effectiveTitleStyle = dense
                          ? titleStyle.copyWith(
                              fontSize: ((titleStyle.fontSize ?? 12.0) * 0.92)
                                  .clamp(11.0, double.infinity),
                              height: 1.2,
                            )
                          : titleStyle;
                      final effectiveDescStyle = dense
                          ? descStyle.copyWith(
                              fontSize: ((descStyle.fontSize ?? 12.0) * 0.92)
                                  .clamp(10.0, double.infinity),
                              height: 1.3,
                            )
                          : descStyle;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: effectiveIconContainer,
                            height: effectiveIconContainer,
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusSmall,
                              ),
                            ),
                            child: Icon(
                              category.icon,
                              size: effectiveIconSize,
                              color: category.color,
                            ),
                          ),
                          if (!tightHeight) SizedBox(height: contentGap),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              category.title,
                              style: effectiveTitleStyle.copyWith(
                                color: AppThemeColors.of(context).textMain,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              category.description,
                              style: effectiveDescStyle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
