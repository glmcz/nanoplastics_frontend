import 'package:flutter/material.dart';
import '../models/solution_path.dart';
import '../config/app_colors.dart';

class SolutionPathsData {
  static const List<SolutionPath> paths = [
    SolutionPath(
      domain: SolutionDomain.humanBody,
      titleKey: 'path_human_title',
      descriptionKey: 'path_human_desc',
      icon: '🧬',
      primaryColor: AppColors.placenta,
      secondaryColor: AppColors.blood,
      categories: [
        SolutionCategory(
          id: 'detox',
          titleKey: 'cat_detox_title',
          descriptionKey: 'cat_detox_desc',
          icon: '🛡️',
          color: AppColors.placenta,
          examples: [
            'cat_detox_example1',
            'cat_detox_example2',
            'cat_detox_example3',
          ],
        ),
        SolutionCategory(
          id: 'barrier',
          titleKey: 'cat_barrier_title',
          descriptionKey: 'cat_barrier_desc',
          icon: '🔬',
          color: AppColors.blood,
          examples: [
            'cat_barrier_example1',
            'cat_barrier_example2',
            'cat_barrier_example3',
          ],
        ),
      ],
    ),
    SolutionPath(
      domain: SolutionDomain.earth,
      titleKey: 'path_earth_title',
      descriptionKey: 'path_earth_desc',
      icon: '🌍',
      primaryColor: AppColors.water,
      secondaryColor: AppColors.energy,
      categories: [
        SolutionCategory(
          id: 'water_filter',
          titleKey: 'cat_water_filter_title',
          descriptionKey: 'cat_water_filter_desc',
          icon: '💧',
          color: AppColors.water,
          examples: [
            'cat_water_example1',
            'cat_water_example2',
            'cat_water_example3',
          ],
        ),
        SolutionCategory(
          id: 'energy_harvest',
          titleKey: 'cat_energy_title',
          descriptionKey: 'cat_energy_desc',
          icon: '⚡',
          color: AppColors.energy,
          examples: [
            'cat_energy_example1',
            'cat_energy_example2',
            'cat_energy_example3',
          ],
        ),
      ],
    ),
  ];
}
