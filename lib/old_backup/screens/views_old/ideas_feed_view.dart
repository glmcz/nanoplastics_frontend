import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../models/solution_path.dart';
import '../../../services/localization_service.dart';

class IdeasFeedView extends StatelessWidget {
  final SolutionPath? selectedPath;

  const IdeasFeedView({
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
          // Path indicator if path is selected
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
            localization.translate('ideas_feed_title'),
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXL,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Show ideas feed or message
          if (selectedPath != null)
            _buildIdeasFeed(context, localization)
          else
            _buildNoPathSelected(localization),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildIdeasFeed(BuildContext context, LocalizationService localization) {
    // Mock ideas data - in production, this would come from an API
    final mockIdeas = _getMockIdeas();

    return Column(
      children: mockIdeas.map((idea) {
        return _IdeaCard(
          idea: idea,
          pathColor: selectedPath!.primaryColor,
          localization: localization,
        );
      }).toList(),
    );
  }

  Widget _buildNoPathSelected(LocalizationService localization) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: AppColors.textDark,
            ),
            const SizedBox(height: 20),
            Text(
              localization.translate('ideas_feed_no_path'),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockIdeas() {
    if (selectedPath == null) return [];

    // Generate mock ideas based on selected path
    final isHumanBody = selectedPath!.domain == SolutionDomain.humanBody;

    return [
      {
        'author': 'Marie K.',
        'timeAgo': '2h',
        'category': isHumanBody ? 'cat_detox_title' : 'cat_water_filter_title',
        'title': isHumanBody
            ? 'Activated Charcoal Supplement Protocol'
            : 'Biomimetic Filtration Using Mussel Proteins',
        'description': isHumanBody
            ? 'Daily regimen combining activated charcoal with specific prebiotics to bind and eliminate nanoplastics through digestive system.'
            : 'Inspired by mussel adhesive proteins that naturally filter microparticles from water. Could be scaled for municipal water treatment.',
        'votes': 127,
        'comments': 23,
      },
      {
        'author': 'Dr. Chen',
        'timeAgo': '5h',
        'category': isHumanBody ? 'cat_barrier_title' : 'cat_energy_title',
        'title': isHumanBody
            ? 'Placental Barrier Enhancement via Omega-3'
            : 'Triboelectric Nanogenerator from Waste Plastics',
        'description': isHumanBody
            ? 'Research shows high-dose DHA supplementation strengthens placental membrane integrity, potentially reducing nanoplastic penetration by 40%.'
            : 'Convert nanoplastic friction into electrical energy using triboelectric effect. Powers sensors while removing contaminants.',
        'votes': 89,
        'comments': 15,
      },
      {
        'author': 'Elena R.',
        'timeAgo': '1d',
        'category': isHumanBody ? 'cat_detox_title' : 'cat_water_filter_title',
        'title': isHumanBody
            ? 'Fasting-Mimicking Diet for Cellular Cleanup'
            : 'Washing Machine Filter Retrofit Kit',
        'description': isHumanBody
            ? 'Periodic 5-day FMD activates autophagy pathways that may help cells eliminate accumulated nanoplastic particles.'
            : 'DIY filter attachment for home washers to capture microfibers. Open-source design, costs under \$20 to build.',
        'votes': 156,
        'comments': 31,
      },
      {
        'author': 'James W.',
        'timeAgo': '2d',
        'category': isHumanBody ? 'cat_barrier_title' : 'cat_water_filter_title',
        'title': isHumanBody
            ? 'N99+ Respirator Upgrade Path'
            : 'Graphene Oxide Water Purifier',
        'description': isHumanBody
            ? 'Modified N95 masks with electrostatically charged nanofiber layer to capture airborne nanoplastics under 100nm.'
            : 'Graphene oxide sheets can adsorb nanoplastics from water. Prototype shows 95% removal efficiency in lab tests.',
        'votes': 73,
        'comments': 18,
      },
    ];
  }
}

class _IdeaCard extends StatelessWidget {
  final Map<String, dynamic> idea;
  final Color pathColor;
  final LocalizationService localization;

  const _IdeaCard({
    required this.idea,
    required this.pathColor,
    required this.localization,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Author and time
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [pathColor, pathColor.withAlpha(128)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    idea['author'][0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idea['author'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      idea['timeAgo'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pathColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: pathColor.withAlpha(77)),
                ),
                child: Text(
                  localization.translate(idea['category']),
                  style: TextStyle(
                    fontSize: 10,
                    color: pathColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            idea['title'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            idea['description'],
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Footer: Votes and comments
          Row(
            children: [
              Icon(Icons.arrow_upward, size: 18, color: pathColor),
              const SizedBox(width: 4),
              Text(
                '${idea['votes']}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: pathColor,
                ),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.comment_outlined, size: 18, color: AppColors.textDark),
              const SizedBox(width: 4),
              Text(
                '${idea['comments']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  localization.translate('read_more'),
                  style: TextStyle(
                    fontSize: 13,
                    color: pathColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
