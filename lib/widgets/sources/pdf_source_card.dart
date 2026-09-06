import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../models/pdf_source.dart';
import '../../services/web_link_cache_service.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';

class PdfSourceCard extends StatelessWidget {
  final PDFSource source;
  final int number;
  final VoidCallback onTap;

  const PdfSourceCard({
    super.key,
    required this.source,
    required this.number,
    required this.onTap,
  });

  /// Maps source description keywords to a category accent color.
  static Color accentColor(String description) {
    if (description.contains('Brain') ||
        description.contains('Central') ||
        description.contains('мозг') ||
        description.contains('mozek') ||
        description.contains('Centraux') ||
        description.contains('Centrales')) {
      return AppColors.neonCyan;
    }
    if (description.contains('Heart') ||
        description.contains('Vital') ||
        description.contains('srdce') ||
        description.contains('Vitalit')) {
      return AppColors.neonCrimson;
    }
    if (description.contains('Reproduc') ||
        description.contains('Fertil') ||
        description.contains('placenta') ||
        description.contains('Репродук')) {
      return AppColors.neonViolet;
    }
    if (description.contains('Entry') ||
        description.contains('Inhal') ||
        description.contains('vstupní') ||
        description.contains('Entrées') ||
        description.contains('Vías') ||
        description.contains('Пути')) {
      return AppColors.neonOrange;
    }
    if (description.contains('Filtrat') ||
        description.contains('Detox') ||
        description.contains('Filtrace') ||
        description.contains('Filtr') ||
        description.contains('Фильтр')) {
      return AppColors.neonLime;
    }
    if (description.contains('Ocean') ||
        description.contains('Marine') ||
        description.contains('oceán') ||
        description.contains('Océan') ||
        description.contains('océano') ||
        description.contains('мор')) {
      return AppColors.neonOcean;
    }
    if (description.contains('Atmos') ||
        description.contains('atmos') ||
        description.contains('Atmosphère') ||
        description.contains('Атмос')) {
      return AppColors.neonAtmos;
    }
    if (description.contains('Flora') ||
        description.contains('Fauna') ||
        description.contains('Biosphere') ||
        description.contains('Biosphère')) {
      return AppColors.neonBio;
    }
    if (description.contains('Magnetic') ||
        description.contains('Core') ||
        description.contains('Magnét') ||
        description.contains('ядро') ||
        description.contains('Магнит')) {
      return AppColors.neonMagma;
    }
    return AppColors.pastelAqua;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final themeColors = AppThemeColors.of(context);
    final chipColor = accentColor(source.description);
    final isWebOnlyLink = source.isWebLink && !source.url!.contains('.pdf');

    return InkWell(
      onTap: onTap,
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
                    source.title,
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
                      source.description,
                      style: typography.labelXs.copyWith(color: chipColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  source.getPageRangeDisplay(),
                  style: typography.labelSm.copyWith(
                    color: themeColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isWebOnlyLink)
                      FutureBuilder<bool>(
                        future: WebLinkCacheService().hasVisited(source.url!),
                        builder: (ctx, snap) {
                          if (snap.data != true) return const SizedBox.shrink();
                          return Semantics(
                            label: 'Available offline',
                            child: Tooltip(
                              message: 'Available offline',
                              child: Icon(
                                Icons.cloud_done,
                                size: sizing.iconXs,
                                color:
                                    AppColors.pastelMint.withValues(alpha: 0.7),
                              ),
                            ),
                          );
                        },
                      ),
                    if (isWebOnlyLink) SizedBox(width: spacing.xs / 2),
                    Icon(
                      isWebOnlyLink
                          ? Icons.open_in_browser
                          : Icons.picture_as_pdf,
                      size: sizing.iconSm,
                      color: AppColors.pastelAqua.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
