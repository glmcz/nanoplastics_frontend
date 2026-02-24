import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/idea_attachment.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/app_theme_colors.dart';
import '../utils/app_typography.dart';
import '../services/settings_manager.dart';

class BrainstormBox extends StatefulWidget {
  final String title;
  final String username;
  final String placeholder;
  final String? submitText;
  final Function(String, List<IdeaAttachment>)? onSubmit;
  final String? category;
  // Tour keys
  final GlobalKey? titleKey;
  final GlobalKey? inputKey;
  final GlobalKey? attachmentKey;

  const BrainstormBox({
    super.key,
    required this.title,
    required this.username,
    required this.placeholder,
    this.submitText,
    this.onSubmit,
    this.category,
    this.titleKey,
    this.inputKey,
    this.attachmentKey,
  });

  @override
  State<BrainstormBox> createState() => _BrainstormBoxState();
}

class _BrainstormBoxState extends State<BrainstormBox>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String? _username;
  bool _isSubmitting = false;
  late final SettingsManager _settingsManager;

  // Attachments
  final List<IdeaAttachment> _attachments = [];
  static const int _maxAttachments = 5;

  // Voice recording
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  late final AudioRecorder _audioRecorder;

  // Pulsing animation for recording indicator
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _settingsManager = SettingsManager();
    _loadUsername();
    _loadDraft();
    _controller.addListener(_saveDraft);
    _settingsManager.addDisplayNameListener(_onDisplayNameChanged);
    _audioRecorder = AudioRecorder();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _controller.removeListener(_saveDraft);
    _controller.dispose();
    _settingsManager.removeDisplayNameListener(_onDisplayNameChanged);
    _recordTimer?.cancel();
    _audioRecorder.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BrainstormBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) _loadDraft();
    if (oldWidget.username != widget.username) _loadUsername();
  }

  void _onDisplayNameChanged(String newDisplayName) {
    if (mounted) {
      setState(() {
        _username =
            newDisplayName.isNotEmpty ? newDisplayName : widget.username;
      });
    }
  }

  void _loadUsername() {
    final displayName = _settingsManager.displayName;
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
    await _settingsManager.setDisplayName(value);
    setState(() => _username = value);
  }

  // ── Attachment pickers ────────────────────────────────────────────────────

  Future<void> _pickImageOrVideo() async {
    if (!mounted) return;
    final choice = await showModalBottomSheet<_MediaSource>(
      context: context,
      backgroundColor: AppThemeColors.of(context).dialogBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (_) => _MediaSourceSheet(),
    );
    if (choice == null || !mounted) return;

    final picker = ImagePicker();
    XFile? xfile;

    if (choice == _MediaSource.galleryImage) {
      xfile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
    } else if (choice == _MediaSource.cameraImage) {
      xfile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
    } else if (choice == _MediaSource.galleryVideo) {
      xfile = await picker.pickVideo(source: ImageSource.gallery);
    } else if (choice == _MediaSource.cameraVideo) {
      xfile = await picker.pickVideo(source: ImageSource.camera);
    }

    if (xfile == null) return;
    final ext = p.extension(xfile.path).replaceFirst('.', '');

    // Reject videos over 95 MB (approaching server limit)
    if (attachmentTypeFromExtension(ext) == AttachmentType.video) {
      final bytes = await File(xfile.path).length();
      if (bytes > 95 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video is too large (max 95 MB). Please trim it first.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }
    final att = IdeaAttachment(
      path: xfile.path,
      name: p.basename(xfile.path),
      mimeType: mimeFromExtension(ext),
      type: attachmentTypeFromExtension(ext),
    );
    if (mounted) setState(() => _attachments.add(att));
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'csv'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    final ext = file.extension ?? '';
    final att = IdeaAttachment(
      path: file.path!,
      name: file.name,
      mimeType: mimeFromExtension(ext),
      type: AttachmentType.document,
    );
    if (mounted) setState(() => _attachments.add(att));
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for voice notes.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _recordDuration = Duration.zero;
    });
    _pulseController.repeat(reverse: true);

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _recordDuration += const Duration(seconds: 1));
      }
    });
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    final path = await _audioRecorder.stop();
    _pulseController
      ..stop()
      ..reset();

    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _recordDuration = Duration.zero;
    });

    if (path == null) return;
    final name =
        'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final att = IdeaAttachment(
      path: path,
      name: name,
      mimeType: 'audio/mp4',
      type: AttachmentType.audio,
    );
    setState(() => _attachments.add(att));
  }

  void _removeAttachment(int index) {
    final att = _attachments[index];
    // Clean up temp audio files
    if (att.type == AttachmentType.audio) {
      File(att.path).delete().ignore();
    }
    setState(() => _attachments.removeAt(index));
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final text = _controller.text.trim();
    if (text.length < 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.categoryDetailBrainstormMinLength,
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    final l10n = AppLocalizations.of(context)!;

    try {
      setState(() => _isSubmitting = true);
      await widget.onSubmit?.call(text, List.unmodifiable(_attachments));
      _controller.clear();
      if (widget.category != null) {
        SettingsManager().clearDraftIdea(widget.category!);
      }
      setState(() => _attachments.clear());

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
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg.isNotEmpty
                  ? errorMsg
                  : l10n.categoryDetailBrainstormError,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.categoryDetailBrainstormSave),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _saveUsername(result);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDuration(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  IconData _iconForType(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return Icons.image_outlined;
      case AttachmentType.video:
        return Icons.videocam_outlined;
      case AttachmentType.audio:
        return Icons.mic_outlined;
      case AttachmentType.document:
        return Icons.description_outlined;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final atMax = _attachments.length >= _maxAttachments;

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
                  // Header
                  KeyedSubtree(
                    key: widget.titleKey,
                    child: Row(
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.pastelAqua,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.space8),

                  // Username badge
                  InkWell(
                    onTap: _showEditDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.space8,
                        vertical: AppConstants.space4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppColors.pastelLavender.withValues(alpha: 0.1),
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
                        topLeft:
                            Radius.circular(AppConstants.radiusMedium),
                        topRight:
                            Radius.circular(AppConstants.radiusMedium),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color:
                              AppColors.pastelAqua.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    child: TextField(
                      key: widget.inputKey,
                      controller: _controller,
                      maxLines: 4,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: tc.textMain),
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: TextStyle(color: tc.textMuted),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.all(AppConstants.space12),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.space12),

                  // ── Attachment action bar ─────────────────────────────
                  Row(
                    key: widget.attachmentKey,
                    children: [
                      _buildAttachBtn(
                        icon: Icons.photo_library_outlined,
                        label: 'Image / Video',
                        color: AppColors.pastelAqua,
                        enabled: !atMax && !_isRecording,
                        onTap: _pickImageOrVideo,
                        spacing: spacing,
                        sizing: sizing,
                        typography: typography,
                      ),
                      SizedBox(width: spacing.sm),
                      _buildAttachBtn(
                        icon: Icons.attach_file_outlined,
                        label: 'Document',
                        color: AppColors.pastelLavender,
                        enabled: !atMax && !_isRecording,
                        onTap: _pickDocument,
                        spacing: spacing,
                        sizing: sizing,
                        typography: typography,
                      ),
                      SizedBox(width: spacing.sm),
                      _buildVoiceBtn(
                        atMax: atMax,
                        spacing: spacing,
                        sizing: sizing,
                        typography: typography,
                      ),
                    ],
                  ),

                  // ── Attachment chips ──────────────────────────────────
                  if (_attachments.isNotEmpty) ...[
                    SizedBox(height: spacing.sm),
                    SizedBox(
                      height: sizing.minTouchTarget,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _attachments.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: spacing.xs),
                        itemBuilder: (_, i) =>
                            _buildChip(i, _attachments[i], tc,
                                spacing: spacing,
                                sizing: sizing,
                                typography: typography),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppConstants.space16),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.all(AppConstants.space12),
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color(0xFF0A0A12),
                        shadowColor:
                            AppColors.pastelAqua.withValues(alpha: 0.5),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusMedium),
                        ),
                      ).copyWith(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color>(
                          (_) => Colors.transparent,
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isSubmitting
                                ? [
                                    AppColors.pastelAqua
                                        .withValues(alpha: 0.5),
                                    AppColors.pastelMint
                                        .withValues(alpha: 0.5),
                                  ]
                                : const [
                                    AppColors.pastelAqua,
                                    AppColors.pastelMint,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusMedium),
                        ),
                        child: Container(
                          padding:
                              const EdgeInsets.all(AppConstants.space12),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSubmitting)
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Color(0xFF0A0A12),
                                    ),
                                  ),
                                )
                              else ...[
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
                                const SizedBox(
                                    width: AppConstants.space8),
                                Text('🚀',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium),
                              ],
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

  Widget _buildAttachBtn({
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
  }) {
    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(sizing.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: spacing.xs, horizontal: spacing.xs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: enabled ? 0.10 : 0.04),
            borderRadius: BorderRadius.circular(sizing.radiusMd),
            border: Border.all(
                color: color.withValues(alpha: enabled ? 0.25 : 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: sizing.iconXs,
                  color: color.withValues(alpha: enabled ? 1.0 : 0.35)),
              const SizedBox(height: 2),
              Text(
                label,
                style: typography.labelXs.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: enabled ? 0.9 : 0.35),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceBtn({
    required bool atMax,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
  }) {
    final enabled = !atMax || _isRecording;
    final color = _isRecording ? Colors.red : AppColors.energy;

    return Expanded(
      child: InkWell(
        onTap: enabled ? _toggleRecording : null,
        borderRadius: BorderRadius.circular(sizing.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: spacing.xs, horizontal: spacing.xs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: enabled ? 0.10 : 0.04),
            borderRadius: BorderRadius.circular(sizing.radiusMd),
            border: Border.all(
                color: color.withValues(alpha: enabled ? 0.25 : 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isRecording)
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Icon(
                    Icons.stop_circle_outlined,
                    size: sizing.iconXs,
                    color: Colors.red.withValues(alpha: _pulseAnim.value),
                  ),
                )
              else
                Icon(Icons.mic_outlined,
                    size: sizing.iconXs,
                    color: color.withValues(alpha: enabled ? 1.0 : 0.35)),
              const SizedBox(height: 2),
              Text(
                _isRecording ? _formatDuration(_recordDuration) : 'Voice',
                style: typography.labelXs.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: enabled ? 0.9 : 0.35),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(int index, IdeaAttachment att, AppThemeColors tc,
      {required AppSpacing spacing,
      required AppSizing sizing,
      required AppTypography typography}) {
    final isImage = att.type == AttachmentType.image;
    final chipH = sizing.minTouchTarget;
    final r = sizing.radiusMd;

    return Container(
      height: chipH,
      decoration: BoxDecoration(
        color: tc.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(r),
        border: Border.all(
            color: AppColors.pastelAqua.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thumbnail for images, icon for everything else
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(r),
                bottomLeft: Radius.circular(r),
              ),
              child: Image.file(
                File(att.path),
                width: chipH,
                height: chipH,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _chipIcon(att, sizing: sizing),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.sm),
              child: _chipIcon(att, sizing: sizing),
            ),
          SizedBox(width: spacing.xs),
          ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: 80 * sizing.scaleW * sizing.compactScale),
            child: Text(
              att.name,
              style: typography.labelXs.copyWith(
                color: tc.textMuted,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: spacing.xs),
          // Remove button
          InkWell(
            onTap: () => _removeAttachment(index),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(r),
              bottomRight: Radius.circular(r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm, vertical: spacing.xs),
              child: Icon(
                Icons.close,
                size: sizing.iconXs * 0.875,
                color: tc.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipIcon(IdeaAttachment att, {required AppSizing sizing}) {
    return Icon(
      _iconForType(att.type),
      size: sizing.iconXs,
      color: AppColors.pastelAqua,
    );
  }
}

// ── Media source picker sheet ─────────────────────────────────────────────

enum _MediaSource { galleryImage, cameraImage, galleryVideo, cameraVideo }

class _MediaSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: AppConstants.space16,
            horizontal: AppConstants.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppConstants.space16),
              decoration: BoxDecoration(
                color: tc.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const _SheetTile(
              icon: Icons.photo_library_outlined,
              label: 'Photo from gallery',
              color: AppColors.pastelAqua,
              value: _MediaSource.galleryImage,
            ),
            const _SheetTile(
              icon: Icons.camera_alt_outlined,
              label: 'Take a photo',
              color: AppColors.pastelMint,
              value: _MediaSource.cameraImage,
            ),
            const _SheetTile(
              icon: Icons.video_library_outlined,
              label: 'Video from gallery',
              color: AppColors.pastelLavender,
              value: _MediaSource.galleryVideo,
            ),
            const _SheetTile(
              icon: Icons.videocam_outlined,
              label: 'Record a video',
              color: AppColors.energy,
              value: _MediaSource.cameraVideo,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final _MediaSource value;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: tc.textMain,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}
