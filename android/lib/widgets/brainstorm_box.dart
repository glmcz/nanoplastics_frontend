import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_manager.dart';

class BrainstormBox extends StatefulWidget {
  final String title;
  final String username;
  final String placeholder;
  final String? submitText;
  final Function(String)? onSubmit;
  final String? category;

  const BrainstormBox({
    super.key,
    required this.title,
    required this.username,
    required this.placeholder,
    this.submitText,
    this.onSubmit,
    this.category,
  });

  @override
  State<BrainstormBox> createState() => _BrainstormBoxState();
}

class _BrainstormBoxState extends State<BrainstormBox> {
  final TextEditingController _controller = TextEditingController();
  String? _username;

  @override
  void dispose() {
    _controller.removeListener(_saveDraft);
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadDraft();
    _controller.addListener(_saveDraft);
  }

  void _loadUsername() {
    final settings = SettingsManager();
    final displayName = settings.displayName;
    setState(() {
      _username = displayName.isNotEmpty ? displayName : widget.username;
    });
  }

  void _loadDraft() {
    if (widget.category != null) {
      final draft = SettingsManager().getDraftIdea(widget.category!);
      if (draft != null && draft.isNotEmpty) {
        _controller.text = draft;
      }
    }
  }

  void _saveDraft() {
    if (widget.category != null) {
      SettingsManager().setDraftIdea(widget.category!, _controller.text);
    }
  }

  Future<void> _saveUsername(String value) async {
    final settings = SettingsManager();
    await settings.setDisplayName(value);
    setState(() {
      _username = value;
    });
  }

  Future<void> _handleSubmit() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    final l10n = AppLocalizations.of(context)!;

    try {
      await widget.onSubmit?.call(text);
      _controller.clear();
      if (widget.category != null) {
        SettingsManager().clearDraftIdea(widget.category!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.categoryDetailBrainstormSuccess} 🚀'),
            backgroundColor: AppColors.pastelMint,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.categoryDetailBrainstormError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showEditDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller =
        TextEditingController(text: _username ?? widget.username);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.categoryDetailBrainstormEditUsername),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.categoryDetailBrainstormUsernameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.categoryDetailBrainstormCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.categoryDetailBrainstormSave),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _saveUsername(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pastelAqua.withValues(alpha: 0.05),
        border: Border.all(
          color: AppColors.pastelAqua.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        child: Stack(
          children: [
            // Subtle glow background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.5, -0.5),
                    radius: 2,
                    colors: [
                      AppColors.pastelMint.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.pastelAqua,
                        size: AppConstants.iconMedium,
                      ),
                      const SizedBox(width: AppConstants.space8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.pastelAqua,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.space8),

                  // Username under the title; tappable to edit
                  InkWell(
                    onTap: _showEditDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.space8,
                        vertical: AppConstants.space4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pastelLavender.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _username ?? widget.username,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppColors.pastelLavender,
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppConstants.space4),
                          const Icon(
                            Icons.edit,
                            size: AppConstants.iconSmall,
                            color: AppColors.pastelLavender,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.space16),

                  // Textarea
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppConstants.radiusMedium),
                        topRight: Radius.circular(AppConstants.radiusMedium),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.pastelAqua.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(AppConstants.space12),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.space16),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(AppConstants.space12),
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color(0xFF0A0A12),
                        shadowColor:
                            AppColors.pastelAqua.withValues(alpha: 0.5),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMedium),
                        ),
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            return Colors.transparent;
                          },
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.pastelAqua,
                              AppColors.pastelMint,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMedium),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.space12),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.submitText ??
                                          AppLocalizations.of(context)!
                                              .categoryDetailBrainstormSubmit,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1,
                                            color: const Color(0xFF0A0A12),
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.space8),
                                  Text(
                                    '🚀',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
