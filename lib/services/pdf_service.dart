import '../config/backend_config.dart';
import 'settings_manager.dart';
import 'logger_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Centralized PDF management service
/// Handles caching and downloading for all PDF access across app
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

  /// Resolve PDF file from unified documents directory or download if needed
  /// Returns the File if successful, null if unable to resolve
  /// This is a pure service method with no UI dependencies
  Future<File?> resolvePdf({
    required String language,
  }) async {
    try {
      final lang = language;

      // Check if PDF exists in unified documents directory
      final pdf = await settingsManager.getPdfForLanguage(lang);

      LoggerService().logDebug(
        'pdf_lookup',
        'Looking for PDF: language=$lang, found=${pdf != null}, path=${pdf?.path ?? "N/A"}',
      );

      if (pdf != null && await pdf.exists()) {
        // PDF exists, return it
        LoggerService().logDebug(
          'pdf_resolve_success',
          'Resolved PDF for language: $lang',
        );
        return pdf;
      } else {
        // PDF not available, try to download it
        LoggerService().logDebug(
          'pdf_download_needed',
          'PDF not available, downloading: $lang',
        );
        final success = await downloadPdfFromBackend(lang);
        if (success) {
          return await settingsManager.getPdfForLanguage(lang);
        }
        return null;
      }
    } catch (e) {
      LoggerService().logError(
        'pdf_resolve_failed',
        'Error resolving PDF: $e',
      );
      return null;
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

  /// Get list of all available PDF languages from documents directory
  Future<List<String>> getAvailableLanguages() async {
    return await settingsManager.getCachedPdfLanguages();
  }

  /// Check if specific language PDF is available
  Future<bool> isPdfAvailable(String language) async {
    final pdf = await settingsManager.getPdfForLanguage(language);
    return pdf != null && await pdf.exists();
  }

  /// Resolve PDF from asset path (for bundled special PDFs like water PDFs)
  /// Extracts and caches the PDF, returns the File path
  Future<File?> resolveAssetPdf(String assetPath) async {
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

      return cachedFile;
    } catch (e) {
      LoggerService().logError(
        'asset_pdf_resolve_failed',
        'Error resolving PDF from asset $assetPath: $e',
      );
      return null;
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
  /// Returns true if download was successful
  /// Stores downloaded PDF locally via SettingsManager
  Future<bool> downloadPdfFromBackend(String language) async {
    try {
      LoggerService()
          .logUserAction('Downloading PDF', params: {'language': language});

      // Get backend URL from centralized config (can be overridden at build time)
      final String backendBaseUrl = BackendConfig.getBaseUrl();

      // Download the PDF directly from the /reports/ static endpoint
      final filename =
          'Nanoplastics_Report_${language.toUpperCase()}_compressed.pdf';
      final pdfResponse = await http
          .get(Uri.parse('$backendBaseUrl/reports/$filename'))
          .timeout(
            const Duration(seconds: 120),
            onTimeout: () => throw Exception('PDF download timeout'),
          );

      if (pdfResponse.statusCode == 404) {
        LoggerService().logError('PDF not available', 'Language: $language');
        return false;
      }

      if (pdfResponse.statusCode != 200) {
        throw Exception('Failed to download PDF: ${pdfResponse.statusCode}');
      }

      // Save PDF to local storage
      await settingsManager.savePdfLocally(language, pdfResponse.bodyBytes);

      LoggerService().logUserAction('PDF downloaded successfully', params: {
        'language': language,
        'size': pdfResponse.bodyBytes.length,
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
