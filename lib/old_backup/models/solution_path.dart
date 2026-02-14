import 'package:flutter/material.dart';

enum SolutionDomain {
  humanBody,
  earth,
}

class SolutionPath {
  final SolutionDomain domain;
  final String titleKey;
  final String descriptionKey;
  final String icon;
  final Color primaryColor;
  final Color secondaryColor;
  final List<SolutionCategory> categories;

  const SolutionPath({
    required this.domain,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.categories,
  });
}

class SolutionCategory {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final String icon;
  final Color color;
  final List<String> examples;

  const SolutionCategory({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    required this.examples,
  });
}
