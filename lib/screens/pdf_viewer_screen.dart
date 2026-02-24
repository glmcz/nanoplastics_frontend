import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:pdfx/pdfx.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/app_typography.dart';
import '../widgets/nanosolve_logo.dart';
import '../l10n/app_localizations.dart';
import '../services/logger_service.dart';
import '../utils/app_theme_colors.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewerScreen extends StatefulWidget {
  final String title;
  final int startPage;
  final int endPage;
  final String description;
  final String pdfPath; // File system path to the PDF

  const PDFViewerScreen({
    super.key,
    required this.title,
    required this.startPage,
    required this.endPage,
    required this.description,
    required this.pdfPath,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late PdfControllerPinch _pdfController;
  late PdfDocument _pdfDocument;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _stablePageBeforeRotation = 1; // Stores page before rotation starts
  Orientation? _lastOrientation;
  bool _isRotating = false;
  bool _initialPageSet = false; // Track if initial page has been set
  String? _resolvedPath; // The actual path used to open the PDF
  bool _pdfIsAsset = true; // Whether _resolvedPath is a Flutter asset
  int _actualEndPage = 0; // Clamped endPage based on actual PDF page count; initialized on PDF load

  @override
  void initState() {
    super.initState();
    // Allow all orientations for PDF reading
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    LoggerService().logScreenNavigation('PDFViewerScreen', params: {
      'title': widget.title,
      'startPage': widget.startPage,
      'endPage': widget.endPage,
    });
    _initializePDF();
  }

  Future<void> _initializePDF() async {
    final startTime = DateTime.now();
    try {
      PdfDocument document;

      // Open PDF from file system path (provided by PdfService)
      _resolvedPath = widget.pdfPath;
      _pdfIsAsset = false;
      document = await PdfDocument.openFile(widget.pdfPath);

      _openDocument(document, startTime);
    } catch (e) {
      final loadTime = DateTime.now().difference(startTime).inMilliseconds;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load PDF: $e';
      });

      LoggerService().logError(
        'PDFLoadFailed',
        e,
        null,
        {'title': widget.title, 'loadTime': loadTime},
      );
    }
  }

  void _openDocument(PdfDocument document, DateTime startTime) {
    _pdfController = PdfControllerPinch(
      document: Future.value(document),
      initialPage:
          widget.startPage - 1, // Convert from 1-based to 0-based for pdfx
    );

    _pdfDocument = document;

    final loadTime = DateTime.now().difference(startTime).inMilliseconds;

    setState(() {
      _isLoading = false;
      _currentPage = widget.startPage;
      _stablePageBeforeRotation = widget.startPage;
      // Clamp endPage to actual PDF page count (replaces sentinel 1 << 30)
      _actualEndPage =
          widget.endPage.clamp(widget.startPage, _pdfDocument.pagesCount);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _safeJumpToPage(
            widget.startPage - 1); // Convert from 1-based to 0-based for pdfx
        _initialPageSet = true;
      }
    });

    LoggerService().logPDFPerformance(
      pages: _pdfDocument.pagesCount,
      durationMs: loadTime,
      fileSizeMB: 11,
    );
  }

  @override
  void dispose() {
    // Restore portrait-only orientation for the rest of the app
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Close document before disposing controller, only if successfully loaded
    if (!_isLoading && _error == null) {
      _pdfDocument.close();
      _pdfController.dispose();
    }
    super.dispose();
  }

  /// Attempts jumpToPage, retrying on next frame if page rects
  /// aren't ready yet (e.g. right after orientation change).
  void _safeJumpToPage(int page, {int retries = 3}) {
    try {
      _pdfController.jumpToPage(page);
    } catch (e) {
      if (retries > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _safeJumpToPage(page, retries: retries - 1);
        });
      }
    }
  }

  void _handleOrientationChange(int pageToPreserve) {
    if (_isRotating) return;
    _isRotating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _pdfController.value = Matrix4.identity();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // pdfx uses 0-based indexing, so convert to 0-based
        _safeJumpToPage(pageToPreserve - 1);

        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          setState(() {
            _currentPage = pageToPreserve;
            _stablePageBeforeRotation = pageToPreserve;
            _isRotating = false;
          });
        });
      });
    });
  }

  void _applyZoom(double delta) {
    final matrix = _pdfController.value.clone();
    final double oldScale = matrix.storage[0];
    final double newScale = (oldScale + delta).clamp(1.0, 5.0);

    // If scale didn't change (e.g. hitting min/max), do nothing
    if (newScale == oldScale) return;

    final double ratio = newScale / oldScale;

    // Get the center of the viewer to use as the "Eye of the Spiral"
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final double centerX = box.size.width / 2;
    final double centerY = box.size.height / 2;

    // Transform translations relative to the center focal point
    matrix.storage[12] = centerX - (centerX - matrix.storage[12]) * ratio;
    matrix.storage[13] = centerY - (centerY - matrix.storage[13]) * ratio;

    // Apply new scale
    matrix.storage[0] = newScale;
    matrix.storage[5] = newScale;

    _pdfController.value = matrix;
  }

  void _jumpToPage(String pageText) {
    if (pageText.isEmpty) {
      LoggerService().logDebug(
        'pdf_page_input_empty',
        'User tried to jump to page but input was empty',
      );
      return;
    }

    try {
      final int pageNumber = int.parse(pageText);

      LoggerService().logDebug(
        'pdf_page_input_parsed',
        'User input parsed: "$pageText" -> page number: $pageNumber',
      );

      // Validate page number is within PDF bounds (1 to total pages)
      // Note: startPage-endPage (e.g., 71-91) are just recommendations for context,
      // users can navigate anywhere in the full PDF
      if (pageNumber < 1 || pageNumber > _pdfDocument.pagesCount) {
        LoggerService().logUserAction('pdf_page_jump_out_of_range', params: {
          'input': pageNumber,
          'total_pages': _pdfDocument.pagesCount,
          'suggested_range': '${widget.startPage}-${widget.endPage}',
          'current_page': _currentPage,
        });
        return;
      }

      final oldPage = _currentPage;

      // Convert from 1-based (user-facing) to 0-based (pdfx internal)
      _pdfController.jumpToPage(pageNumber - 1);

      // Update current page state manually
      setState(() {
        _currentPage = pageNumber;
        _stablePageBeforeRotation = pageNumber;
      });

      LoggerService().logUserAction('pdf_page_jump_successful', params: {
        'from_page': oldPage,
        'to_page': pageNumber,
        'total_pages': _pdfDocument.pagesCount,
        'suggested_range': '${widget.startPage}-${widget.endPage}',
        'title': widget.title,
      });

      LoggerService().logDebug(
        'pdf_page_updated',
        'Page successfully updated from $oldPage to $pageNumber (PDF has ${_pdfDocument.pagesCount} total pages)',
      );
    } catch (e) {
      LoggerService().logUserAction('pdf_page_jump_invalid_input', params: {
        'input': pageText,
        'error': e.toString(),
        'current_page': _currentPage,
      });
    }
  }

  Future<Uint8List> _loadPdfBytes() async {
    if (_pdfIsAsset) {
      final data = await rootBundle.load(_resolvedPath!);
      return data.buffer.asUint8List();
    } else {
      return await File(_resolvedPath!).readAsBytes();
    }
  }

  Future<void> _sharePDF() async {
    if (kIsWeb || _resolvedPath == null) return;

    try {
      final bytes = await _loadPdfBytes();

      final sanitizedTitle =
          widget.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');

      // On iOS, use application documents directory (more persistent than temp)
      final saveDir = await getApplicationDocumentsDirectory();
      final tempFile =
          File('${saveDir.path}/Nanoplastics_$sanitizedTitle.pdf');
      await tempFile.writeAsBytes(bytes);

      if (!await tempFile.exists()) {
        throw Exception('Failed to create PDF file');
      }

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: widget.title,
      );

      LoggerService().logUserAction('pdf_shared', params: {
        'title': widget.title,
      });

      // Clean up after share (with small delay to ensure share completes)
      Future.delayed(const Duration(seconds: 2), () {
        try {
          tempFile.deleteSync();
        } catch (_) {}
      });
    } catch (e) {
      LoggerService().logError('PDFShareFailed', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _downloadAndSharePDF() async {
    // Check if running on web - dart:io File doesn't work on web
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'PDF download is not supported on web. Please use a mobile device.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final sanitizedTitle =
          widget.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final fileName = 'Nanoplastics_$sanitizedTitle.pdf';

      // Get PDF data from asset or local file
      final bytes = await _loadPdfBytes();

      // On iOS: use FilePicker.saveFile() to open Files app
      // On Android: use getDirectoryPath() if available, else Documents directory
      String? savePath;

      if (Platform.isIOS) {
        // iOS: use saveFile which opens Files app
        final result = await FilePicker.platform.saveFile(
          fileName: fileName,
          bytes: bytes,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        savePath = result;
      } else {
        // Android: let user pick directory
        String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
        if (selectedDirectory != null) {
          savePath = '$selectedDirectory/$fileName';
          final file = File(savePath);
          await file.writeAsBytes(bytes);
        }
      }

      if (savePath == null) {
        LoggerService().logUserAction('pdf_download_cancelled', params: {
          'title': widget.title,
        });
        return;
      }

      LoggerService().logUserAction('pdf_downloaded', params: {
        'title': widget.title,
        'filePath': savePath,
        'fileName': fileName,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✓ PDF saved successfully'),
                const SizedBox(height: 4),
                Text(
                  fileName,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      LoggerService().logError('PDFDownloadFailed', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelAqua.withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppColors.pastelLavender.withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppThemeColors.of(context).gradientEnd,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              // Use stable page that was captured before any rotation events
              if (_lastOrientation != null && _lastOrientation != orientation) {
                _handleOrientationChange(_stablePageBeforeRotation);
              }
              _lastOrientation = orientation;

              final isPortrait = orientation == Orientation.portrait;
              return Column(
                children: [
                  _buildHeader(isPortrait: isPortrait),
                  if (isPortrait) _buildInfoCard(),
                  Expanded(
                    child: _buildPDFViewer(isPortrait: isPortrait),
                  ),
                  _buildFooter(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({bool isPortrait = true}) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Container(
      padding: EdgeInsets.all(isPortrait ? AppConstants.space8 : 1.0),
      decoration: BoxDecoration(
        color: AppThemeColors.of(context).cardBackground.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_back_ios,
                            color: AppThemeColors.of(context).textMain, size: sizing.backIcon),
                        const SizedBox(width: AppConstants.space4),
                        Flexible(
                          child: Text(
                            l10n.categoryDetailBackToOverview,
                            style: typography.back.copyWith(
                              color: AppThemeColors.of(context).textMain,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onSubmitted: _jumpToPage,
                    controller: TextEditingController(text: '$_currentPage'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.pastelAqua,
                        ),
                    decoration: InputDecoration(
                      prefix: Text(
                        'p. ',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.pastelAqua,
                            ),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.headerSpacing),
            NanosolveLogo(height: isPortrait ? sizing.logoHeightLg : sizing.logoHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.space4),
      padding: const EdgeInsets.all(AppConstants.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pastelAqua.withValues(alpha: 0.1),
            AppColors.pastelMint.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: AppColors.pastelAqua.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.title} • str. ${widget.startPage}-$_actualEndPage',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.pastelLavender,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, color: Colors.black),
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }

  Widget _buildPDFViewer({bool isPortrait = true}) {
    if (_isLoading) {
      return Container(
        color: Colors.white, // Prevent red screen flash during loading
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.pastelAqua,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading PDF...',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final radius = isPortrait ? 0.0 : 16.0;
    return Container(
      margin: isPortrait
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: isPortrait
            ? null
            : [
                BoxShadow(
                  color: AppColors.pastelAqua.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: PdfViewPinch(
              controller: _pdfController,
              onPageChanged: (page) {
                if (_isRotating || !_initialPageSet) return;

                // When zoomed in, the viewport can drift across page
                // boundaries producing unreliable page numbers.
                final scale = _pdfController.value.storage[0];
                if (scale > 1.05) return;

                setState(() {
                  _currentPage = page;
                  _stablePageBeforeRotation = page;
                });
                LoggerService().logPDFInteraction(
                  'page_changed',
                  page: page,
                );
              },
              scrollDirection: Axis.vertical,
              padding: 0,
              backgroundDecoration:
                  const BoxDecoration(color: Color(0xFFFFFFFF)),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Material(
              elevation: 4,
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildZoomButton(
                    icon: Icons.add,
                    onPressed: () => _applyZoom(0.25),
                  ),
                  Container(
                    width: 24,
                    height: 1,
                    color:
                        Colors.black.withValues(alpha: 0.1), // Subtle divider
                  ),
                  _buildZoomButton(
                    icon: Icons.remove,
                    onPressed: () => _applyZoom(-0.25),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppThemeColors.of(context).cardBackground.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (_currentPage > 1) {
                _pdfController.previousPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.pastelAqua.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.pastelAqua.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.pastelAqua,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Page $_currentPage/$_actualEndPage',
                style: TextStyle(
                  color: AppThemeColors.of(context).textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _sharePDF,
                child: Icon(
                  Icons.share,
                  size: 20,
                  color: AppColors.pastelMint.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _downloadAndSharePDF,
                child: Icon(
                  Icons.download,
                  size: 20,
                  color: AppColors.pastelMint.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              if (_currentPage < _actualEndPage) {
                _pdfController.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.pastelAqua.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.pastelAqua.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 20,
                color: AppColors.pastelAqua,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
