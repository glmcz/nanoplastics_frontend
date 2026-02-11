import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/app_sizing.dart';
import '../utils/app_typography.dart';

class HeaderBackButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool showArrow;

  const HeaderBackButton({
    super.key,
    required this.label,
    this.color = AppColors.pastelAqua,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(sizing.radiusSm),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: sizing.minTouchTarget,
            minWidth: sizing.minTouchTarget,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showArrow) ...[
                  Icon(
                    Icons.arrow_back_ios,
                    size: sizing.backIcon,
                    color: color,
                  ),
                  const SizedBox(width: AppConstants.space4),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: typography.back.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
