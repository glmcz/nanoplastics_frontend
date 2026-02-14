import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../models/solution_path.dart';
import '../../services/localization_service.dart';
import '../../screens/main_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final SolutionPath path;

  const CategoryDetailScreen({
    super.key,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              path.primaryColor.withOpacity(0.1),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, localization),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPathInfo(localization),
                      const SizedBox(height: 40),
                      _buildCategoriesList(localization),
                      const SizedBox(height: 40),
                      _buildContinueButton(context, localization),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LocalizationService localization) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            localization.translate(path.titleKey),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathInfo(LocalizationService localization) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            path.primaryColor.withOpacity(0.2),
            path.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: path.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [path.primaryColor, path.secondaryColor],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                path.icon,
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              localization.translate(path.descriptionKey),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMain,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(LocalizationService localization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Solution Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        ...path.categories.map(
          (category) => _CategoryCard(
            category: category,
            localization: localization,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context, LocalizationService localization) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MainScreen(
                    selectedPath: path,
                    showBackButton: true,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: path.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              localization.translate('confirm_path'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            localization.translate('back_to_path_selection'),
            style: TextStyle(
              fontSize: 14,
              color: path.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final SolutionCategory category;
  final LocalizationService localization;

  const _CategoryCard({
    required this.category,
    required this.localization,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(1),
        border: Border(
          left: BorderSide(color: category.color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localization.translate(category.descriptionKey),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 22, 99, 207),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Examples:',
                  style: TextStyle(
                    fontSize: 11,
                    color: category.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...category.examples.map(
                  (example) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      localization.translate(example),
                      style: const TextStyle(
                        fontSize: 2,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
