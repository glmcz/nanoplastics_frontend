import 'package:flutter/foundation.dart';
import '../config/backend_config.dart';
import 'settings_manager.dart';
import 'logger_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../utils/pdf_utils.dart';
import 'dart:io';
import 'http/app_http_client.dart';

/// Centralized PDF management service
/// Handles caching and downloading for all PDF access across app
/// All PDFs (bundled + downloaded) stored in single app documents directory
class PdfService {
  final SettingsManager settingsManager;

  /// Swapped in tests so extraction can be held open and observed.
  final Future<void> Function()? _extractor;

  /// Create PdfService with injected SettingsManager dependency
  /// This ensures a single SettingsManager instance is used throughout the app
  ///
  /// Example:
  ///   final pdfService = PdfService(settingsManager);
  PdfService(this.settingsManager, {Future<void> Function()? extractor})
      : _extractor = extractor;

  Future<void>? _extraction;

  /// Completes when bundled PDFs are on disk. Anything that reads a bundled
  /// file awaits this rather than assuming startup already finished.
  Future<void> get ready => _extraction ?? initialize();

  /// Extract bundled PDFs to the app documents directory. Started during app
  /// startup but deliberately not awaited there: on the full flavour this
  /// copies seven PDFs, and nothing on the first frame reads them. Memoised,
  /// so repeated calls join the run already in flight.
  Future<void> initialize() => _extraction ??= _initialize();

  Future<void> _initialize() async {
    try {
      if (kIsWeb) {
        LoggerService().logDebug(
          'pdf_service_init',
          'Skipping bundled PDF extraction on web; browser uses asset/URL access directly.',
        );
        return;
      }

      // Always run extraction — _extractPdfAsset() skips files that already
      // exist, so this is fast on subsequent launches and always correct.
      await (_extractor ?? _extractBundledPdfs)();
      LoggerService().logDebug(
        'pdf_service_init',
        'Bundled PDF extraction complete',
      );
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
    // Startup no longer waits for extraction, so the first read might arrive
    // while it is still running. One gate, here, rather than every caller.
    await ready;
    try {
      if (kIsWeb) {
        LoggerService().logDebug(
          'pdf_lookup_web_skipped',
          'Skipping file-based PDF resolution on web for language=$language.',
        );
        return null;
      }

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
    // Every build bundles all of these: there is one pubspec.yaml now, so a
    // local build and a release ship the same assets.
    const reportLanguages = ['en', 'cs', 'es', 'fr', 'ru'];
    const waterLanguages = ['en', 'cs'];

    LoggerService().logDebug(
      'pdf_extraction_start',
      'Starting PDF extraction for languages: $reportLanguages',
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
      if (!await assetExists(assetPath)) {
        // Every language is declared in pubspec.yaml, so a missing asset is a
        // packaging fault rather than an expected gap. resolvePdf still falls
        // back to a download, which is why this logs instead of throwing.
        LoggerService().logError(
          '${type}_pdf_asset_missing',
          'Missing bundled $type asset: $assetPath',
        );
        return;
      }

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
      if (kIsWeb) {
        LoggerService().logDebug(
          'asset_pdf_web_skipped',
          'Skipping asset PDF caching on web for $assetPath.',
        );
        return null;
      }

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
      if (kIsWeb) {
        LoggerService().logDebug(
          'pdf_download_web_skipped',
          'Skipping file download/caching on web for language=$language.',
        );
        return false;
      }

      LoggerService()
          .logUserAction('Downloading PDF', params: {'language': language});

      // Get backend URL from centralized config (can be overridden at build time)
      final String backendBaseUrl = BackendConfig.getBaseUrl();

      // Download the PDF directly from the /reports/ static endpoint
      final filename =
          'Nanoplastics_Report_${language.toUpperCase()}_compressed.pdf';
      final pdfResponse = await AppHttpClient.instance
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
