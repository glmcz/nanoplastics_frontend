import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../data/app_data.dart';
import '../../../models/solution_path.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/resource_card.dart';
import '../../../widgets/section_header.dart';
import '../../../screens/main_screen.dart';

class LibraryView extends StatelessWidget {
  final SolutionPath? selectedPath;

  const LibraryView({
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

          // Official Reports Section
          SectionHeader(
            text: localization.translate('header_reports'),
          ),
          ...AppData.officialReports.map(
            (resource) => ResourceCard(
              resource: resource,
              onTap: () => _openUrl(resource.url),
            ),
          ),

          const SizedBox(height: 25),

          // Scientific Databases Section
          SectionHeader(
            text: localization.translate('header_db'),
          ),
          ...AppData.scientificDatabases.map(
            (resource) => ResourceCard(
              resource: resource,
              onTap: () => _openUrl(resource.url),
            ),
          ),

          const SizedBox(height: 25),

          // Public Education Section
          SectionHeader(
            text: localization.translate('header_edu'),
          ),
          ...AppData.publicEducation.map(
            (resource) => ResourceCard(
              resource: resource,
              onTap: () => _openUrl(resource.url),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _openUrl(String? url) {
    if (url != null) {
      // TODO: Implement URL launcher
      // launch(url);
      debugPrint('Opening URL: $url');
    }
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
