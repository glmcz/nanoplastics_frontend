import 'package:flutter/material.dart';

class OnboardingSlide {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String titleHighlight;
  final String description;

  OnboardingSlide({
    this.icon,
    this.imagePath,
    required this.title,
    required this.titleHighlight,
    required this.description,
  });
}
