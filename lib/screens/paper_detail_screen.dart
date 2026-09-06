import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/digest_paper.dart';
import '../services/digest_service.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';

class PaperDetailScreen extends StatefulWidget {
  final DigestPaper paper;

  const PaperDetailScreen({super.key, required this.paper});

  @override
  State<PaperDetailScreen> createState() => _PaperDetailScreenState();
}

class _PaperDetailScreenState extends State<PaperDetailScreen> {
  late bool _inTresor;
  bool _tresorLoading = false;

  @override
  void initState() {
    super.initState();
    _inTresor = DigestService().tresorIds.contains(widget.paper.id);
  }

  Future<void> _toggleTresor() async {
    if (_tresorLoading) return;
    setState(() => _tresorLoading = true);

    final svc = DigestService();
    debugPrint('[VAULT] toggle paperId=${widget.paper.id} inTresor=$_inTresor');
    final success = _inTresor
        ? await svc.removeFromTresor(widget.paper.id)
        : await svc.addToTresor(widget.paper.id);
    debugPrint('[VAULT] toggle result=$success');

    if (mounted && success) {
      setState(() => _inTresor = !_inTresor);
    }
    if (mounted) setState(() => _tresorLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final paper = widget.paper;
    final catColor = paper.categoryColor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, spacing, sizing, paper, catColor),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          paper.title,
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: spacing.md),

                        // Perex
                        if (paper.perex != null) ...[
                          Text(
                            paper.perex!,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: spacing.md),
                        ],

                        // Meta row: authors / journal / date
                        _MetaRow(paper: paper),
                        SizedBox(height: spacing.md),

                        // Category chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (paper.category != null)
                              _FilledChip(
                                label: paper.category!,
                                icon: paper.categoryIcon(),
                                color: catColor,
                              ),
                            if (paper.subcategory != null)
                              _OutlinedChip(
                                label: paper.subcategory!.replaceAll('_', ' '),
                                color: catColor,
                              ),
                          ],
                        ),
                        SizedBox(height: spacing.sm),

                        // Labels
                        if (paper.labels.isNotEmpty) ...[
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: paper.labels
                                .map((l) => _LabelChip(label: l))
                                .toList(),
                          ),
                          SizedBox(height: spacing.md),
                        ],

                        // DOI
                        if (paper.doi != null)
                          _DoiRow(doi: paper.doi!, spacing: spacing),

                        SizedBox(height: spacing.md),

                        // Open source button
                        if (paper.sourceUrl.isNotEmpty)
                          _OpenSourceButton(url: paper.sourceUrl),

                        SizedBox(height: spacing.xl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppSpacing spacing,
    AppSizing sizing,
    DigestPaper paper,
    Color catColor,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: spacing.md, vertical: spacing.sm),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.9),
            border: Border(
              bottom: BorderSide(
                color: catColor.withValues(alpha: 0.2),
              ),
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
              Expanded(
                child: Text(
                  paper.source.toUpperCase(),
                  style: TextStyle(
                    color: catColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Tresor heart toggle
              Semantics(
                button: true,
                label: _inTresor
                    ? AppLocalizations.of(context)!.vaultRemoveButton
                    : AppLocalizations.of(context)!.vaultSaveButton,
                child: _tresorLoading
                    ? SizedBox(
                        width: sizing.iconSm,
                        height: sizing.iconSm,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.neonCrimson,
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          _inTresor ? Icons.favorite : Icons.favorite_border,
                          color: _inTresor
                              ? AppColors.neonCrimson
                              : AppColors.textMuted,
                          size: 22,
                        ),
                        onPressed: _toggleTresor,
                        padding: EdgeInsets.zero,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final DigestPaper paper;

  const _MetaRow({required this.paper});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (paper.authors.isNotEmpty) paper.authors,
      if (paper.journal != null) paper.journal!,
      if (paper.publishedDate != null) paper.publishedDate!,
    ];
    return Text(
      parts.join(' · '),
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 12,
      ),
    );
  }
}

class _FilledChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _FilledChip(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _OutlinedChip extends StatelessWidget {
  final String label;
  final Color color;

  const _OutlinedChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;

  const _LabelChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(color: AppColors.textDark, fontSize: 11)),
    );
  }
}

class _DoiRow extends StatelessWidget {
  final String doi;
  final AppSpacing spacing;

  const _DoiRow({required this.doi, required this.spacing});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Copy DOI',
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: doi));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('DOI copied'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: spacing.sm, vertical: spacing.xs),
          decoration: BoxDecoration(
            color: AppColors.panelBackground,
            borderRadius: BorderRadius.circular(6),
            border:
                Border.all(color: AppColors.neonCyan.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.copy, color: AppColors.neonCyan, size: 12),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  doi,
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenSourceButton extends StatelessWidget {
  final String url;

  const _OpenSourceButton({required this.url});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open source paper',
      child: InkWell(
        onTap: () async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.08),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_in_new, color: AppColors.neonCyan, size: 16),
              SizedBox(width: 8),
              Text(
                'Open Source Paper',
                style: TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
