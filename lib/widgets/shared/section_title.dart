import 'package:flutter/material.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';

/// Section heading with a coloured accent bar, as used on the settings screens.
///
/// The title wraps rather than overflowing: at Android's largest font size a
/// Russian heading is wider than the screen.
class SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const SectionTitle(this.title, {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    return Row(
      children: [
        Container(
          width: spacing.xs,
          height: spacing.xl,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(spacing.xs / 2),
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            title,
            style: typography.title.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
