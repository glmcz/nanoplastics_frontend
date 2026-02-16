import 'package:flutter/material.dart';
import '../screens/pdf_viewer_screen.dart';
import '../config/backend_config.dart';
import 'settings_manager.dart';
import 'logger_service.dart';
import 'service_locator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Centralized PDF management service
/// Handles caching, downloading, and navigation for all PDF access across app
/// All PDFs (bundled + downloaded) stored in single app documents directory
class PdfService {
  final SettingsManager settingsManager;
  static const String _bundledExtractedKey = 'bundled_pdfs_extracted';

  /// Create PdfService with injected SettingsManager dependency
  /// This ensures a single SettingsManager instance is used throughout the app
  ///
  /// Example:
  ///   final pdfService = PdfService(settingsManager);
  PdfService(this.settingsManager);

  /// Initialize PDF service by extracting bundled PDFs to app documents directory
  /// Should be called once during app startup
  Future<void> initialize() async {
    try {
      // Only extract bundled PDFs once per app lifetime
      final prefs = await SharedPreferences.getInstance();
      final alreadyExtracted = prefs.getBool(_bundledExtractedKey) ?? false;

      if (!alreadyExtracted) {
        await _extractBundledPdfs();
        await prefs.setBool(_bundledExtractedKey, true);
        LoggerService().logDebug(
          'pdf_service_init',
          'Bundled PDFs extracted to documents directory',
        );
      }
    } catch (e) {
      LoggerService().logError(
        'pdf_service_init_failed',
        'Error initializing bundled PDFs: $e',
      );
    }
  }

  /// Open PDF from unified documents directory or download if needed
  /// All PDFs are stored in the same directory (bundled on init, downloaded on demand)
  Future<void> openPdf({
    required BuildContext context,
    required String title,
    required String description,
    required int startPage,
    required int endPage,
    String? language,
  }) async {
    // Use provided language or current user language
    final lang = language ?? settingsManager.userLanguage;

    try {
      // Check if PDF exists in unified documents directory
      final pdf = await settingsManager.getPdfForLanguage(lang);

      LoggerService().logDebug(
        'pdf_lookup',
        'Looking for PDF: language=$lang, found=${pdf != null}, path=${pdf?.path ?? "N/A"}',
      );

      if (pdf != null && await pdf.exists()) {
        // PDF exists, open immediately
        LoggerService().logDebug(
          'pdf_open',
          'Opening PDF for language: $lang',
        );
        _navigateToPdfViewer(
          context,
          title,
          description,
          startPage,
          endPage,
          pdf.path,
        );
      } else {
        // PDF not available, download it
        LoggerService().logDebug(
          'pdf_download_needed',
          'PDF not available, downloading: $lang',
        );
        await _downloadAndOpenPdf(
          context,
          title,
          description,
          startPage,
          endPage,
          lang,
        );
      }
    } catch (e) {
      LoggerService().logError(
        'pdf_open_failed',
        'Error opening PDF: $e',
      );
      _showErrorDialog(context, 'Failed to open PDF: $e');
    }
  }

  /// Download PDF and open after successful download
  Future<void> _downloadAndOpenPdf(
    BuildContext context,
    String title,
    String description,
    int startPage,
    int endPage,
    String language,
  ) async {
    if (!context.mounted) return;

    // Show loading dialog with progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('Downloading $language PDF'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Please wait...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    try {
      // Download PDF
      final success =
          await ServiceLocator().pdfService.downloadPdfFromBackend(language);

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Download succeeded, get the file and open
        final pdf = await settingsManager.getPdfForLanguage(language);

        if (pdf != null && await pdf.exists()) {
          if (context.mounted) {
            _navigateToPdfViewer(
              context,
              title,
              description,
              startPage,
              endPage,
              pdf.path,
            );
          }
        }
      } else {
        // Download failed
        if (context.mounted) {
          _showErrorDialog(
            context,
            'Failed to download $language PDF. Please check your internet connection and try again.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog(context, 'Error downloading PDF: $e');
      }

      // Log error
      LoggerService().logError(
        'pdf_download_failed',
        'Language: $language, Error: $e',
      );
    }
  }

  /// Extract all bundled PDFs to app documents directory (called once on init)
  Future<void> _extractBundledPdfs() async {
    final buildType = settingsManager.buildType.toUpperCase();
    final reportLanguages =
        buildType == 'FULL' ? ['en', 'cs', 'es', 'fr', 'ru'] : ['en'];
    final waterLanguages = buildType == 'FULL' ? ['en', 'cs'] : ['en'];

    LoggerService().logDebug(
      'pdf_extraction_start',
      'Starting PDF extraction for build type: $buildType, languages: $reportLanguages',
    );

    // Extract main Nanoplastics reports
    for (final lang in reportLanguages) {
      try {
        await _extractPdfAsset(
          assetPath:
              'assets/docs/Nanoplastics_Report_${lang.toUpperCase()}_compressed.pdf',
          fileName: 'Nanoplastics_Report_${lang.toUpperCase()}_compressed.pdf',
          type: 'report',
          language: lang,
        );
      } catch (e) {
        LoggerService().logError(
          'pdf_extract_failed',
          'Error extracting $lang PDF: $e',
        );
      }
    }

    // Extract water PDFs
    for (final lang in waterLanguages) {
      try {
        await _extractPdfAsset(
          assetPath: 'assets/docs/${lang.toUpperCase()}_WATER_compressed.pdf',
          fileName: 'water_${lang.toUpperCase()}_compressed.pdf',
          type: 'water',
          language: lang,
        );
      } catch (e) {
        LoggerService().logError(
          'water_pdf_extract_failed',
          'Error extracting water PDF for $lang: $e',
        );
      }
    }
  }

  /// Generic method to extract bundled PDF assets
  /// Handles both main reports and special PDFs (water, etc.)
  Future<void> _extractPdfAsset({
    required String assetPath,
    required String fileName,
    required String type, // 'report', 'water', etc.
    required String language,
  }) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final pdfsDir = Directory('${appDocDir.path}/pdfs');
      final cachedFile = File('${pdfsDir.path}/$fileName');

      // Check if already extracted
      if (await cachedFile.exists()) {
        LoggerService().logDebug(
          '${type}_pdf_already_exists',
          '$type PDF already exists: $language',
        );
        return;
      }

      // Ensure pdfs directory exists
      if (!await pdfsDir.exists()) {
        await pdfsDir.create(recursive: true);
      }

      // Load asset as bytes
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      // Save to documents directory
      await cachedFile.writeAsBytes(bytes);

      LoggerService().logDebug(
        '${type}_pdf_extracted',
        'Extracted $type PDF: $language',
      );
    } catch (e) {
      LoggerService().logError(
        '${type}_pdf_extract_error',
        'Error extracting $type PDF for $language: $e',
      );
    }
  }

  /// Navigate to PDF viewer screen
  void _navigateToPdfViewer(
    BuildContext context,
    String title,
    String description,
    int startPage,
    int endPage,
    String pdfPath,
  ) {
    LoggerService().logDebug(
      'pdf_navigate',
      'Navigating to PDF viewer: $title',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          title: title,
          startPage: startPage,
          endPage: endPage,
          description: description,
          pdfPath: pdfPath,
        ),
      ),
    );

    LoggerService().logUserAction('pdf_opened', params: {
      'title': title,
      'startPage': startPage,
      'endPage': endPage,
    });
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get list of all available PDF languages from documents directory
  Future<List<String>> getAvailableLanguages() async {
    return await settingsManager.getCachedPdfLanguages();
  }

  /// Check if specific language PDF is available
  Future<bool> isPdfAvailable(String language) async {
    final pdf = await settingsManager.getPdfForLanguage(language);
    return pdf != null && await pdf.exists();
  }

  /// Open PDF from asset path (for bundled special PDFs like water PDFs)
  Future<void> openPdfFromAsset({
    required BuildContext context,
    required String assetPath,
    required String title,
    required String description,
    required int startPage,
    required int endPage,
  }) async {
    try {
      // Extract PDF name from asset path for caching
      final fileName = assetPath.split('/').last.replaceAll('.pdf', '');

      // Check if already extracted
      final appDocDir = await getApplicationDocumentsDirectory();
      final pdfsDir = Directory('${appDocDir.path}/pdfs');
      final cachedFile = File('${pdfsDir.path}/$fileName.pdf');

      if (!await cachedFile.exists()) {
        // Load from asset and cache it
        final byteData = await rootBundle.load(assetPath);
        final bytes = byteData.buffer.asUint8List();

        if (!await pdfsDir.exists()) {
          await pdfsDir.create(recursive: true);
        }

        await cachedFile.writeAsBytes(bytes);
        LoggerService().logDebug(
          'asset_pdf_cached',
          'Cached PDF from asset: $assetPath',
        );
      }

      // Open the cached file
      _navigateToPdfViewer(
        context,
        title,
        description,
        startPage,
        endPage,
        cachedFile.path,
      );
    } catch (e) {
      LoggerService().logError(
        'asset_pdf_open_failed',
        'Error opening PDF from asset $assetPath: $e',
      );
      _showErrorDialog(context, 'Failed to open PDF: $e');
    }
  }

  /// Delete cached PDF for a language (e.g., for cleanup)
  Future<void> deleteCachedPdf(String language) async {
    await settingsManager.deleteCachedPdf(language);
    LoggerService().logDebug(
      'pdf_deleted',
      'Deleted cached PDF: $language',
    );
  }

  /// Download PDF for specified language from backend
  /// Returns true if download was successful and file size matches
  /// Stores downloaded PDF locally via SettingsManager
  Future<bool> downloadPdfFromBackend(String language) async {
    try {
      LoggerService()
          .logUserAction('Downloading PDF', params: {'language': language});

      // Get backend URL from centralized config (can be overridden at build time)
      final String backendBaseUrl = BackendConfig.getBaseUrl();

      // Fetch PDF metadata from backend
      final response = await http.get(
        Uri.parse('$backendBaseUrl/api/pdfs/$language'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('PDF metadata request timeout'),
      );

      if (response.statusCode == 404) {
        LoggerService().logError('PDF not available', 'Language: $language');
        return false;
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch PDF metadata: ${response.statusCode}');
      }

      final metadata = jsonDecode(response.body);
      final pdfUrl = metadata['url'] as String;
      final expectedSize = metadata['size'] as int;

      // Download the PDF file
      final pdfResponse =
          await http.get(Uri.parse('$backendBaseUrl$pdfUrl')).timeout(
                const Duration(seconds: 120),
                onTimeout: () => throw Exception('PDF download timeout'),
              );

      if (pdfResponse.statusCode != 200) {
        throw Exception('Failed to download PDF: ${pdfResponse.statusCode}');
      }

      final actualSize = pdfResponse.bodyBytes.length;

      // Verify file size matches
      if (actualSize != expectedSize) {
        LoggerService().logError(
          'PDF size mismatch',
          'Expected: $expectedSize, Actual: $actualSize',
        );
        return false;
      }

      // Save PDF to local storage
      await settingsManager.savePdfLocally(language, pdfResponse.bodyBytes);

      LoggerService().logUserAction('PDF downloaded successfully', params: {
        'language': language,
        'size': actualSize,
      });

      return true;
    } catch (e, stackTrace) {
      LoggerService().logError(
        'Error downloading PDF',
        e.toString(),
        stackTrace,
      );
      return false;
    }
  }
}
