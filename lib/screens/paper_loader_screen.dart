import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/digest_paper.dart';
import '../services/digest_service.dart';
import '../utils/app_spacing.dart';
import 'paper_detail_screen.dart';

/// Opened straight from a notification tap, before the paper is known.
///
/// Fetching first and navigating afterwards meant the tap showed the launch
/// screen for the whole round trip — worse on a cold start, where the request
/// only begins once the app has booted. This appears immediately and fills in.
class PaperLoaderScreen extends StatefulWidget {
  final String paperId;

  /// Title from the notification payload, shown while the record loads so the
  /// screen is never blank when we already know what the user tapped.
  final String? previewTitle;

  /// Perex from the same payload. With it the tap shows real content with no
  /// network at all; the fetch then fills in the rest of the record.
  final String? previewPerex;

  const PaperLoaderScreen({
    super.key,
    required this.paperId,
    this.previewTitle,
    this.previewPerex,
  });

  @override
  State<PaperLoaderScreen> createState() => _PaperLoaderScreenState();
}

class _PaperLoaderScreenState extends State<PaperLoaderScreen> {
  DigestPaper? _paper;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final paper = await DigestService().fetchPaperById(widget.paperId);
    if (!mounted) return;
    setState(() {
      _paper = paper;
      _failed = paper == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paper = _paper;
    if (paper != null) return PaperDetailScreen(paper: paper);

    final spacing = AppSpacing.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      // Centred while the content is short, scrollable once it is not: the
      // payload perex can run to 600 characters, which is taller than a small
      // phone on its own and far taller at 200% text scale.
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.all(spacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - spacing.lg * 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.previewTitle != null) ...[
                  Text(
                    widget.previewTitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: spacing.md),
                ],
                if (widget.previewPerex != null) ...[
                  Text(
                    widget.previewPerex!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: spacing.lg),
                ],
                if (_failed) ...[
                  const Icon(Icons.cloud_off, size: 40),
                  SizedBox(height: spacing.md),
                  const Text('Could not load this paper.'),
                  SizedBox(height: spacing.md),
                  TextButton(
                    onPressed: () {
                      setState(() => _failed = false);
                      _load();
                    },
                    child: const Text('Retry'),
                  ),
                ] else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
