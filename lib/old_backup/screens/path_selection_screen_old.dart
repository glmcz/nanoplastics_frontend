import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../data/solution_paths_data.dart';
import '../../models/solution_path.dart';
import '../../services/localization_service.dart';
import '../../screens/category_detail_screen.dart';

class PathSelectionScreen extends StatefulWidget {
  const PathSelectionScreen({super.key});

  @override
  State<PathSelectionScreen> createState() => _PathSelectionScreenState();
}

class _PathSelectionScreenState extends State<PathSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final LocalizationService _localization = LocalizationService();

  @override
  void initState() {
    super.initState();
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 4),
    // )..repeat();
  }

  @override
  void dispose() {
    // _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/crossroad_bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromRGBO(0, 0, 0, 0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 40),
                    _buildPathCards(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            tooltip: 'Back',
          ),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
              children: [
                TextSpan(
                  text: 'NANO',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'SOLVE',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        _localization.translate('choose_path'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPathCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: SolutionPathsData.paths.asMap().entries.map((entry) {
          final index = entry.key;
          final path = entry.value;
          return Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 2), // edge padding
              child: _PathCard(
                path: path,
                onTap: () => _navigateToPath(path),
                index: index,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _navigateToPath(SolutionPath path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(path: path),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final SolutionPath path;
  final VoidCallback onTap;
  final int index;

  const _PathCard({
    required this.path,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();

    // Use index to differentiate arrows
    // Even index = left arrow, Odd index = right arrow
    final isOdd = index % 2 != 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              path.primaryColor.withValues(alpha: 0.15),
              path.secondaryColor.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [path.primaryColor, path.secondaryColor],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: index == 0
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          'assets/icons/dna.png',
                          width: 50,
                          height: 50,
                        ),
                      )
                    : const Icon(
                        Icons.public,
                        size: 50,
                        color: Colors.white,
                      ),
              ),
            ),
            Icon(
              isOdd ? Icons.arrow_back : Icons.arrow_forward,
              color: path.primaryColor,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
