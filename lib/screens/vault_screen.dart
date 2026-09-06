import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/digest_paper.dart';
import '../services/digest_service.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import 'paper_detail_screen.dart';
import 'digest_settings_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  late Future<List<DigestPaper>> _papersFuture;
  bool _exporting = false;
  final _exportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _papersFuture = DigestService().fetchSavedPapers();
  }

  void _deletePaper(String paperId) {
    DigestService().removeFromTresor(paperId).then((_) {
      if (mounted) {
        setState(() => _papersFuture = DigestService().fetchSavedPapers());
      }
    });
  }

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final text = await DigestService().exportTresor();
      if (text != null && text.isNotEmpty) {
        final box = _exportKey.currentContext?.findRenderObject() as RenderBox?;
        final origin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 1, 1);
        await Share.share(text,
            subject: 'NanoSolve Research Papers', sharePositionOrigin: origin);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, spacing, sizing),
            Expanded(
              child: FutureBuilder<List<DigestPaper>>(
                future: _papersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.neonCyan),
                    );
                  }
                  final papers = snapshot.data ?? [];
                  if (papers.isEmpty) {
                    return _buildEmpty();
                  }
                  return RefreshIndicator(
                    color: AppColors.neonCyan,
                    backgroundColor: AppColors.cardBackground,
                    onRefresh: () async {
                      setState(() {
                        _papersFuture = DigestService().fetchSavedPapers();
                      });
                      await _papersFuture;
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(spacing.md),
                      itemCount: papers.length,
                      itemBuilder: (context, i) => _VaultCard(
                        paper: papers[i],
                        spacing: spacing,
                        onDelete: () => _deletePaper(papers[i].id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppSpacing spacing, AppSizing sizing) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: spacing.md, vertical: spacing.sm),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.9),
            border: Border(
              bottom:
                  BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.15)),
            ),
          ),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Back',
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.neonCyan, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: spacing.sm),
              const Icon(Icons.lock_outline,
                  color: AppColors.neonCyan, size: 18),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.vaultTitle,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'Research keywords',
                child: IconButton(
                  icon: const Icon(Icons.tune,
                      color: AppColors.neonCyan, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DigestSettingsScreen()),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              Semantics(
                button: true,
                label: AppLocalizations.of(context)!.vaultExportLabel,
                child: Tooltip(
                  message: 'Export all saved papers as text',
                  child: _exporting
                      ? SizedBox(
                          width: sizing.iconSm,
                          height: sizing.iconSm,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.neonCyan,
                          ),
                        )
                      : IconButton(
                          key: _exportKey,
                          icon: const Icon(Icons.ios_share,
                              color: AppColors.neonCyan, size: 20),
                          onPressed: _export,
                          padding: EdgeInsets.zero,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline,
              color: AppColors.neonCyan.withValues(alpha: 0.3), size: 48),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.vaultEmptyMessage,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Tap ♥ on a paper to save it here',
            style: TextStyle(color: AppColors.textDark, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Vault card ────────────────────────────────────────────────────────────────

class _VaultCard extends StatelessWidget {
  final DigestPaper paper;
  final AppSpacing spacing;
  final VoidCallback? onDelete;

  const _VaultCard({
    required this.paper,
    required this.spacing,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = paper.categoryColor(context);

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Semantics(
        button: true,
        label: paper.title,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaperDetailScreen(paper: paper),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: catColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(paper.categoryIcon(), color: catColor, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          paper.category ?? 'research',
                          style: TextStyle(
                              color: catColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                        if (paper.subcategory != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '· ${paper.subcategory!.replaceAll('_', ' ')}',
                            style: const TextStyle(
                                color: AppColors.textDark, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                    if (onDelete != null)
                      Semantics(
                        button: true,
                        label: 'Delete',
                        child: GestureDetector(
                          onTap: onDelete,
                          child: const Icon(Icons.close,
                              color: AppColors.neonCrimson, size: 18),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: spacing.xs),
                Text(
                  paper.title,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (paper.perex != null) ...[
                  SizedBox(height: spacing.xs),
                  Text(
                    paper.perex!,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
