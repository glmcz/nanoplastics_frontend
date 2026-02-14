import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../services/localization_service.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();

    return Container(
      height: AppConstants.bottomNavHeight,
      decoration: const BoxDecoration(
        color: Color(0xFF101010),
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: '📚',
            label: localization.translate('nav_library'),
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          _NavItemFab(
            label: localization.translate('nav_ideas'),
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          _NavItem(
            icon: '📊',
            label: localization.translate('nav_results'),
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: isSelected ? const Offset(0, -3) : Offset.zero,
              child: Text(
                icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.accent : AppColors.textDarker,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemFab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemFab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -25),
              child: Container(
                width: AppConstants.fabSize,
                height: AppConstants.fabSize,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGlow,
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? AppColors.accent : AppColors.textDarker,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
