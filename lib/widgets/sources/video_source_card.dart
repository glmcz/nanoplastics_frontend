import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../models/pdf_source.dart';
import '../../services/logger_service.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';

class VideoSourceCard extends StatelessWidget {
  final VideoSource video;
  final int number;

  const VideoSourceCard({
    super.key,
    required this.video,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final themeColors = AppThemeColors.of(context);

    final chipColor =
        video.isReport ? AppColors.pastelAqua : AppColors.pastelMint;
    final chipLabel = video.isReport ? 'PDF Report' : 'Documentary';

    return InkWell(
      onTap: () => _openUrl(context),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: spacing.sm),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: themeColors.cardBackground.withValues(alpha: 0.85),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              child: Text(
                number.toString().padLeft(2, '0'),
                style: typography.labelXs.copyWith(
                  color: themeColors.textMuted.withValues(alpha: 0.5),
                ),
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.title,
                    style: typography.title.copyWith(
                      color: themeColors.textMain,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs / 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: chipColor.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      chipLabel,
                      style: typography.labelXs.copyWith(color: chipColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Icon(
              video.isReport ? Icons.picture_as_pdf : Icons.play_circle_filled,
              size: sizing.iconSm,
              color: chipColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context) async {
    LoggerService().logUserAction('video_source_clicked', params: {
      'title': video.title,
      'url': video.url,
      'language': video.language,
      'isReport': video.isReport,
    });
    try {
      await launchUrl(
        Uri.parse(video.url),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: AppThemeColors.of(context).cardBackground,
          ),
          shareState: CustomTabsShareState.off,
          urlBarHidingEnabled: true,
          showTitle: true,
        ),
        safariVCOptions: const SafariViewControllerOptions(
          preferredBarTintColor: Color(0xFF0A0A12),
          preferredControlTintColor: Color(0xFF7FFFD4),
          barCollapsingEnabled: true,
        ),
      );
    } catch (e) {
      LoggerService().logError('VideoLinkOpen', e.toString());
    }
  }
}
