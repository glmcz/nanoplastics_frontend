import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../data/solution_paths_data.dart';
import '../../../models/solution_path.dart';
import '../../../services/localization_service.dart';
import '../../../screens/idea_submission_screen.dart';

class BrainstormView extends StatelessWidget {
  final SolutionPath? selectedPath;

  const BrainstormView({
    super.key,
    this.selectedPath,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();
    final categories = selectedPath?.categories ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show path indicator if path is selected
          if (selectedPath != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    selectedPath!.primaryColor.withAlpha(51),
                    selectedPath!.secondaryColor.withAlpha(26),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedPath!.primaryColor.withAlpha(77),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    selectedPath!.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.translate(selectedPath!.titleKey),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localization.translate(selectedPath!.descriptionKey),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          Text(
            localization.translate('brainstorm_title'),
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXL,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Show filtered categories or all paths
          if (selectedPath != null)
            _buildCategoryList(context, localization, categories)
          else
            _buildAllPathsView(context, localization),
          const SizedBox(height: AppConstants.spacingXL),
          Center(
            child: Text(
              localization.translate('community_stats'),
              style: const TextStyle(
                fontSize: AppConstants.fontSizeNormal,
                color: AppColors.textDarker,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    LocalizationService localization,
    List<SolutionCategory> categories,
  ) {
    return Column(
      children: categories.map((category) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: category.color, width: 4),
            ),
          ),
          child: InkWell(
            onTap: () => _onCategoryTap(context, category.id),
            child: Row(
              children: [
                Text(
                  category.icon,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.translate(category.titleKey),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localization.translate(category.descriptionKey),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: category.color,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllPathsView(BuildContext context, LocalizationService localization) {
    return Column(
      children: [
        Text(
          'Choose a path first to see specific categories',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ...SolutionPathsData.paths.map((path) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  path.primaryColor.withAlpha(38),
                  path.secondaryColor.withAlpha(26),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: path.primaryColor.withAlpha(77),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [path.primaryColor, path.secondaryColor],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      path.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.translate(path.titleKey),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${path.categories.length} categories',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _onCategoryTap(BuildContext context, String categoryId) {
    if (selectedPath == null) return;

    // Find the category by ID
    final category = selectedPath!.categories.firstWhere(
      (cat) => cat.id == categoryId,
    );

    // Navigate to idea submission screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IdeaSubmissionScreen(
          path: selectedPath!,
          category: category,
        ),
      ),
    );
  }
}
