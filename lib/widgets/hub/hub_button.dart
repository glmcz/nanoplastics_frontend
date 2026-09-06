import 'dart:ui';

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';

enum HubButtonPosition { topLeft, topRight, bottomLeft, bottomRight }

class HubButton extends StatelessWidget {
  final Key? buttonKey;
  final String label;
  final IconData icon;
  final HubButtonPosition position;
  final bool isActive;
  final Color activeColor;
  final TextStyle textStyle;
  final double iconSize;
  final double activeGlowBlur;
  final double internalGap;
  final VoidCallback onTap;

  const HubButton({
    super.key,
    this.buttonKey,
    required this.label,
    required this.icon,
    required this.position,
    required this.isActive,
    required this.activeColor,
    required this.textStyle,
    required this.iconSize,
    required this.activeGlowBlur,
    required this.internalGap,
    required this.onTap,
  });

  BorderRadius get _borderRadius {
    const sharp = Radius.circular(AppConstants.radiusSharp);
    const inner = Radius.circular(AppConstants.radiusHubInner);
    switch (position) {
      case HubButtonPosition.topLeft:
        return const BorderRadius.only(
          topLeft: sharp,
          topRight: sharp,
          bottomLeft: sharp,
          bottomRight: inner,
        );
      case HubButtonPosition.topRight:
        return const BorderRadius.only(
          topLeft: sharp,
          topRight: sharp,
          bottomLeft: inner,
          bottomRight: sharp,
        );
      case HubButtonPosition.bottomLeft:
        return const BorderRadius.only(
          topLeft: sharp,
          topRight: inner,
          bottomLeft: sharp,
          bottomRight: sharp,
        );
      case HubButtonPosition.bottomRight:
        return const BorderRadius.only(
          topLeft: inner,
          topRight: sharp,
          bottomLeft: sharp,
          bottomRight: sharp,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = _borderRadius;

    return Semantics(
      button: true,
      label: label,
      selected: isActive,
      child: InkWell(
        key: buttonKey,
        onTap: onTap,
        borderRadius: borderRadius,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withValues(alpha: 0.15)
                    : AppColors.hubButtonBg.withValues(alpha: 0.7),
                borderRadius: borderRadius,
                border: Border.all(
                  color: isActive
                      ? activeColor
                      : Colors.white.withValues(alpha: 0.08),
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.15),
                          blurRadius: activeGlowBlur,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isActive
                      ? Icon(icon, size: iconSize, color: activeColor)
                      : Opacity(
                          opacity: 0.6,
                          child: Icon(
                            icon,
                            size: iconSize,
                            color: AppColors.hubTextInactive,
                          ),
                        ),
                  SizedBox(height: internalGap),
                  Text(
                    label.toUpperCase(),
                    style: textStyle.copyWith(
                      color:
                          isActive ? Colors.white : AppColors.hubTextInactive,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
