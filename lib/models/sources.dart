import 'package:flutter/material.dart';
import '../models/category_detail_data.dart';

class MobileEvidenceGroup {
  final String categoryKey;
  final String categoryTitle;
  final Color categoryColor;
  final List<EvidenceStudy> studies;

  const MobileEvidenceGroup({
    required this.categoryKey,
    required this.categoryTitle,
    required this.categoryColor,
    required this.studies,
  });
}
