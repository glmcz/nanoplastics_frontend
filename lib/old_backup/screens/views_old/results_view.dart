import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../data/app_data.dart';
import '../../../models/solution_path.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/leaderboard_row.dart';
import '../../../screens/main_screen.dart';

class ResultsView extends StatelessWidget {
  final SolutionPath? selectedPath;

  const ResultsView({
    super.key,
    this.selectedPath,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button at the top
          Row(
            children: [
              IconButton(
                onPressed: () => _navigateToMainScreen(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text(
                localization.translate('back_to_path_selection'),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            localization.translate('results_title'),
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXL,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            localization.translate('results_subtitle'),
            style: const TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          ...AppData.leaderboardItems.map(
            (item) => LeaderboardRow(item: item),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _navigateToMainScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(selectedPath: selectedPath),
      ),
      (route) => false,
    );
  }
}
