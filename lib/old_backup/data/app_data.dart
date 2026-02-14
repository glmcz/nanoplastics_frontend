import 'package:flutter/material.dart';
import '../models/category_item.dart';
import '../models/leaderboard_item.dart';
import '../models/resource_item.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class AppData {
  static const List<CategoryItem> categories = [
    CategoryItem(
      id: 'placenta',
      emoji: '🟣',
      titleKey: 'cat_placenta',
      descriptionKey: 'cat_placenta_desc',
      color: AppColors.placenta,
    ),
    CategoryItem(
      id: 'blood',
      emoji: '🔴',
      titleKey: 'cat_blood',
      descriptionKey: 'cat_blood_desc',
      color: AppColors.blood,
    ),
    CategoryItem(
      id: 'energy',
      emoji: '⚡️',
      titleKey: 'cat_energy',
      descriptionKey: 'cat_energy_desc',
      color: AppColors.energy,
    ),
    CategoryItem(
      id: 'water',
      emoji: '💧',
      titleKey: 'cat_water',
      descriptionKey: 'cat_water_desc',
      color: AppColors.water,
    ),
  ];

  static const List<LeaderboardItem> leaderboardItems = [
    LeaderboardItem(
      rank: 1,
      title: 'Triboelectric Nano-Harvester',
      category: 'Fyzika',
      categoryColor: AppColors.energy,
      votes: 1450,
      aiScore: 94,
    ),
    LeaderboardItem(
      rank: 2,
      title: 'Magnetic Hemodialysis',
      category: 'Krev',
      categoryColor: AppColors.blood,
      votes: 890,
      aiScore: 88,
    ),
    LeaderboardItem(
      rank: 3,
      title: 'Mycelium Packaging 2.0',
      category: 'Materiály',
      categoryColor: AppColors.materials,
      votes: 2100,
      aiScore: 76,
    ),
    LeaderboardItem(
      rank: 4,
      title: 'Bio-Enzymatic Spray',
      category: 'Voda',
      categoryColor: AppColors.water,
      votes: 530,
      aiScore: 72,
    ),
  ];

  static const List<ResourceItem> officialReports = [
    ResourceItem(
      icon: '📄',
      titleKey: 'res_nano_title',
      subtitle: 'Allatra Global Research Center',
      tag: ResourceTag.pdf,
      url: AppConstants.nanoPlasticsReportUrl,
    ),
  ];

  static const List<ResourceItem> scientificDatabases = [
    ResourceItem(
      icon: '🔬',
      titleKey: 'PubMed Central',
      subtitle: 'res_pubmed_desc',
      tag: ResourceTag.web,
      url: AppConstants.pubMedUrl,
    ),
    ResourceItem(
      icon: '🧪',
      titleKey: 'ScienceDirect',
      subtitle: 'res_sd_desc',
      tag: ResourceTag.web,
      url: AppConstants.scienceDirectUrl,
    ),
  ];

  static const List<ResourceItem> publicEducation = [
    ResourceItem(
      icon: '🎥',
      titleKey: 'res_vid_title',
      subtitle: 'res_vid_desc',
      tag: ResourceTag.video,
    ),
  ];
}
