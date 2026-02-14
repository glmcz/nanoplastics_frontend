import 'package:flutter/material.dart';

class CategoryItem {
  final String emoji;
  final String titleKey;
  final String descriptionKey;
  final Color color;
  final String id;

  const CategoryItem({
    required this.emoji,
    required this.titleKey,
    required this.descriptionKey,
    required this.color,
    required this.id,
  });
}
