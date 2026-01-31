import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
import 'package:pdfx/pdfx.dart';
import '../config/app_colors.dart';
import '../widgets/nanosolve_logo.dart';
import '../l10n/app_localizations.dart';
import '../services/logger_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class PDFViewerScreen extends StatefulWidget {
  final String title;
  final int startPage;
  final int endPage;
  final String description;
  final String? pdfAssetPath; // Optional custom PDF asset path

  const PDFViewerScreen({
    super.key,
    required this.title,
    required this.startPage,
    required this.endPage,
    required this.description,
    this.pdfAssetPath,
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
  Orientation? _lastOrientation;
  double _lastScale = 1.0;
  bool _isRotating = false;
  
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
      // Load PDF from assets - use custom path if provided, otherwise default
      final pdfPath = widget.pdfAssetPath ??
          'assets/docs/Nanoplastics_in_the_Biosphere_Report.pdf';
      final document = await PdfDocument.openAsset(pdfPath);

      // Create controller and initialize at start page
      _pdfController = PdfControllerPinch(
        document: Future.value(document),
        initialPage: widget.startPage,
      );

      _pdfDocument = document;

      final loadTime = DateTime.now().difference(startTime).inMilliseconds;

      setState(() {
        _isLoading = false;
        _currentPage = widget.startPage;
      });

      // Log PDF performance
      LoggerService().logPDFPerformance(
        pages: _pdfDocument.pagesCount,
        durationMs: loadTime,
        fileSizeMB: 11, // Approximate size of compressed PDF
      );
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

  void _handleOrientationChange() {
    if (_isRotating) return;
    
    final int pageToPreserve = _currentPage;
    _isRotating = true; // Lock the listener

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 1. HARD RESET: Clear the matrix immediately to identity.
      // This stops the 'blank page' stretching instantly.
      _pdfController.value = Matrix4.identity();

      // 2. FIRST JUMP: Snap to page at 1.0 scale to establish new layout coordinates
      _pdfController.jumpToPage(pageToPreserve);

      // 3. SCALE IN: After a short delay to let the screen resize...
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        
        final currentMatrix = _pdfController.value.clone();
        currentMatrix.storage[0] = _lastScale;
        currentMatrix.storage[5] = _lastScale;
        
        // Inject the zoom. We don't touch storage[12]/[13] here 
        // so we keep the page alignment from the first jump.
        _pdfController.value = currentMatrix;

        // 4. FINAL CALIBRATION: The "Double-Jump" 
        _pdfController.jumpToPage(pageToPreserve);

        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;        
          // Final micro-adjustment
          _pdfController.jumpToPage(pageToPreserve-1);
          
          setState(() {
            _currentPage = pageToPreserve;
            _isRotating = false; // Release lock
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
    _lastScale = newScale; // Sync for rotation handling
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

      // Get PDF data from assets
      final data = await rootBundle.load(
        'assets/docs/Nanoplastics_in_the_Biosphere_Report.pdf',
      );
      final bytes = data.buffer.asUint8List();

      // Let user pick directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        LoggerService().logUserAction('pdf_download_cancelled', params: {
          'title': widget.title,
        });
        return;
      }

      final savePath = '$selectedDirectory/$fileName';
      final file = File(savePath);
      await file.writeAsBytes(bytes);

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
                const SizedBox(height: 4),
                Text(
                  savePath,
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
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

  Future<void> _openFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File saved successfully and ready to open'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File no longer exists'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService().logError('OpenFileFailed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.orange,
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
              AppColors.pastelAqua.withValues(alpha: 0.05),
              AppColors.pastelLavender.withValues(alpha: 0.05),
              const Color(0xFF0A0A12),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              if (_lastOrientation != null && _lastOrientation != orientation) {
                _handleOrientationChange();
              }
              _lastOrientation = orientation;

              final isPortrait = orientation == Orientation.portrait;
              return Column(
                children: [
                  _buildHeader(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.sourcesBack,
                style: TextStyle(
                  color: AppColors.pastelAqua,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
            const NanosolveLogo(height: 40),
            SizedBox(
              width: 50,
              child: Text(
                'p. $_currentPage',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.pastelAqua,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.title} • str. ${widget.startPage}-${widget.endPage}',
            style: TextStyle(
              color: AppColors.pastelLavender,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, color: Colors.black),
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }

  Widget _buildPDFViewer({bool isPortrait = true}) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.pastelAqua,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
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
                  style: TextStyle(
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
                if (_isRotating) return; // Ignore updates while we are repositioning

                setState(() {
                  _currentPage = page;
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
                    color: Colors.black.withValues(alpha: 0.1), // Subtle divider
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
        color: const Color(0xFF141928).withValues(alpha: 0.9),
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
              child: Icon(
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
                'Page ${_currentPage}/${widget.endPage}',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
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
              if (_currentPage < widget.endPage) {
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
              child: Icon(
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
