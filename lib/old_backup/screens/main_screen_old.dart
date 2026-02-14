import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/solution_path.dart';
import '../../services/localization_service.dart';
import '../../screens/idea_submission_screen.dart';
import '../../screens/views/library_view.dart';
import '../../screens/views/ideas_feed_view.dart';
import '../../screens/views/results_view.dart';
import '../../screens/widgets/app_header.dart';
import '../../screens/widgets/bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  final bool showBackButton;
  final SolutionPath? selectedPath;

  const MainScreen({
    super.key,
    this.showBackButton = false,
    this.selectedPath,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  final LocalizationService _localizationService = LocalizationService();

  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      LibraryView(selectedPath: widget.selectedPath),
      IdeasFeedView(selectedPath: widget.selectedPath),
      ResultsView(selectedPath: widget.selectedPath),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final shouldPop = await _showExitDialog(context);
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withAlpha(38),
                blurRadius: 60,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // AppHeader(
                //   selectedLanguage: _localizationService.currentLanguage,
                //   onLanguageChanged: _onLanguageChanged,
                //   showBackButton: widget.showBackButton,
                //   onBackPressed: widget.showBackButton
                //       ? () => Navigator.of(context).pop()
                //       : null,
                // ),
                Expanded(
                  child: _buildBody(),
                ),
                BottomNavigation(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onTabSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Exit App?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Exit',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _views[_selectedIndex],
    );
  }

  void _onTabSelected(int index) {
    // If Ideas tab (index 1) is clicked
    if (index == 1) {
      // If already on ideas feed, show submission form
      if (_selectedIndex == 1) {
        _showIdeaSubmission();
        return;
      }
      // Otherwise, navigate to ideas feed
      setState(() {
        _selectedIndex = index;
      });
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showIdeaSubmission() {
    if (widget.selectedPath == null) {
      // No path selected, show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _localizationService.translate('idea_validation_category'),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show category selection dialog
    _showCategorySelectionDialog();
  }

  void _showCategorySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => _CategorySelectionDialog(
        path: widget.selectedPath!,
        onCategorySelected: (category) {
          Navigator.pop(context); // Close dialog
          _navigateToIdeaSubmission(category);
        },
      ),
    );
  }

  void _navigateToIdeaSubmission(SolutionCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IdeaSubmissionScreen(
          path: widget.selectedPath!,
          category: category,
        ),
      ),
    );
  }

  void _onLanguageChanged(String languageCode) {
    setState(() {
      _localizationService.setLanguage(languageCode);
    });
  }
}

// Category Selection Dialog
class _CategorySelectionDialog extends StatelessWidget {
  final SolutionPath path;
  final ValueChanged<SolutionCategory> onCategorySelected;

  const _CategorySelectionDialog({
    required this.path,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    path.primaryColor.withAlpha(51),
                    path.secondaryColor.withAlpha(26),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    path.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.translate('idea_category_label'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localization.translate('idea_category_hint'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Categories List
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: path.categories.map((category) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onCategorySelected(category),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.panelBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(
                                color: category.color,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                category.icon,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localization.translate(category.titleKey),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      localization.translate(category.descriptionKey),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: category.color,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Close Button
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  localization.translate('back_to_path_selection'),
                  style: TextStyle(
                    color: path.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
