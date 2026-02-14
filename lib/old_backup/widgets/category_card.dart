import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../models/category_item.dart';
import '../services/localization_service.dart';

class CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border(
            left: BorderSide(color: category.color, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.emoji,
              style: TextStyle(
                fontSize: 20,
                color: category.color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              localization.translate(category.titleKey),
              style: const TextStyle(
                fontSize: AppConstants.fontSizeNormal,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              localization.translate(category.descriptionKey),
              style: const TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
