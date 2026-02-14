import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../models/leaderboard_item.dart';
import '../services/localization_service.dart';

class LeaderboardRow extends StatelessWidget {
  final LeaderboardItem item;

  const LeaderboardRow({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      padding: const EdgeInsets.all(AppConstants.cardRadius),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${item.rank}',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: item.isTopRank ? AppColors.energy : AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeNormal,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: item.categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: item.categoryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '| ${item.votes} ${localization.translate('cat_votes')}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.aiBadgeBackground,
              border: Border.all(
                color: AppColors.aiBadgeBorder,
              ),
              borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
            ),
            child: Text(
              '${item.aiScore}%',
              style: const TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.aiBadgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
