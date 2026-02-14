import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class SectionHeader extends StatelessWidget {
  final String text;

  const SectionHeader({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.accent, width: 3),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          letterSpacing: 1,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
