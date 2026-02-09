import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/responsive_config.dart';

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
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final header = responsive.getSecondaryHeaderConfig();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppConstants.minTouchTarget,
          minWidth: AppConstants.minTouchTarget,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showArrow) ...[
                Icon(
                  Icons.arrow_back_ios,
                  size: header.iconSize * 0.7,
                  color: color,
                ),
                const SizedBox(width: AppConstants.space4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: header.backStyle?.copyWith(
                    color: color,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
