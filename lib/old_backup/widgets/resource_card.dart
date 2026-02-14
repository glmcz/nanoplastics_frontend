import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../models/resource_item.dart';
import '../services/localization_service.dart';

class ResourceCard extends StatelessWidget {
  final ResourceItem resource;
  final VoidCallback? onTap;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(
              resource.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.translate(resource.titleKey),
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeNormal,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    localization.translate(resource.subtitle),
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            _buildTag(),
          ],
        ),
      ),
    );
  }

  Widget _buildTag() {
    final tagConfig = _getTagConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tagConfig.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tagConfig.label,
        style: const TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  ({Color color, String label}) _getTagConfig() {
    switch (resource.tag) {
      case ResourceTag.pdf:
        return (color: AppColors.tagPdf, label: 'PDF');
      case ResourceTag.web:
        return (color: AppColors.tagWeb, label: 'WEB');
      case ResourceTag.video:
        return (color: AppColors.tagWeb, label: 'VIDEO');
    }
  }
}
