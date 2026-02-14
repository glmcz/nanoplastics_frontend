import 'package:flutter/material.dart';

class CategoryData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const CategoryData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
