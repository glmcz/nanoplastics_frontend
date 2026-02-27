import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/build_config.dart';
import '../config/backend_config.dart';
import '../services/settings_manager.dart';

/// Filename for a given language code.
String _reportFileName(String langCode) =>
    'Nanoplastics_Report_${langCode.toUpperCase()}_compressed.pdf';

/// Asset path for the bundled report in the given language.
String _reportAssetPath(String langCode) =>
    'assets/docs/${_reportFileName(langCode)}';

/// Asset path for the bundled EN report.
String getMainReportAssetPath() => _reportAssetPath('en');

/// Local file path where a downloaded report is stored.
Future<String> _localReportPath(String langCode) async {
  final dir = await getApplicationDocumentsDirectory();
  return '${dir.path}/pdfs/${_reportFileName(langCode)}';
}

/// Download URL for a given language report.
String _downloadUrl(String langCode) =>
    '${BackendConfig.getBaseUrl()}/reports/${_reportFileName(langCode)}';

/// Result of resolving a PDF — either an asset path or a local file path.
class ResolvedPdf {
  /// True when the PDF comes from Flutter assets (EN bundled).
  final bool isAsset;

  /// The path — either an asset key or an absolute file-system path.
  final String path;

  const ResolvedPdf({required this.isAsset, required this.path});
}

/// Resolves the main report PDF for the current (or given) language.
///
/// - EN is always loaded from bundled assets.
/// - When [BuildConfig.bundleAllLangs] is true (full flavor), all languages
///   are loaded from bundled assets.
/// - Otherwise: check local download cache first, return null if missing
///   (caller must trigger a download).
Future<ResolvedPdf?> resolveMainReport([String? langCode]) async {
  final code = (langCode ?? SettingsManager().userLanguage).toLowerCase();

  // EN is always bundled; in full build all langs are bundled
  if (code == 'en' || BuildConfig.bundleAllLangs) {
    return ResolvedPdf(isAsset: true, path: _reportAssetPath(code));
  }

  // Check local cache
  final localPath = await _localReportPath(code);
  if (await File(localPath).exists()) {
    return ResolvedPdf(isAsset: false, path: localPath);
  }

  return null; // not available locally — needs download
}

/// Downloads the report for [langCode] and saves it locally.
/// Calls [onProgress] with values 0.0–1.0 during download.
/// Returns the local file path on success.
/// Use [cancellationToken] to cancel the download from the UI.
Future<String> downloadReport(
  String langCode, {
  void Function(double progress)? onProgress,
  Completer<void>? cancellationToken,
}) async {
  final code = langCode.toLowerCase();
  final url = _downloadUrl(code);
  final localPath = await _localReportPath(code);

  final dir = Directory(localPath).parent;
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final request = http.Request('GET', Uri.parse(url));
  final client = http.Client();
  final response = await client.send(request);

  if (response.statusCode != 200) {
    client.close();
    throw HttpException('Failed to download report: ${response.statusCode}');
  }

  final contentLength = response.contentLength ?? 0;
  final file = File(localPath);
  final sink = file.openWrite();
  int received = 0;
  final startTime = DateTime.now();

  try {
    await for (final chunk in response.stream) {
      // Check if download was cancelled via the token
      if (cancellationToken?.isCompleted ?? false) {
        throw Exception('Download cancelled');
      }

      sink.add(chunk);
      received += chunk.length;

      // Report progress
      if (onProgress != null) {
        if (contentLength > 0) {
          onProgress(received / contentLength);
        } else {
          final elapsed = DateTime.now().difference(startTime).inMilliseconds;
          if (elapsed < 500) {
            onProgress(0.1 + (elapsed / 500) * 0.3);
          } else {
            onProgress(0.4 + (received / 1000000).clamp(0.0, 0.5));
          }
        }
      }
    }
  } catch (e) {
    // Always clean up partial file on any failure so next attempt starts fresh
    await sink.close();
    client.close();
    try {
      await file.delete();
    } catch (_) {}
    rethrow;
  }

  await sink.close();
  client.close();
  return localPath;
}

/// Convenience: returns the asset path string for EN.
/// For code that only needs the simple EN path (backwards compat).
String getMainReportPath([String? langCode]) {
  final code = (langCode ?? SettingsManager().userLanguage).toLowerCase();
  if (code == 'en') {
    return getMainReportAssetPath();
  }
  // For non-EN, return the asset-style path as a fallback key.
  // Callers that need download support should use resolveMainReport() instead.
  return 'assets/docs/${_reportFileName(code)}';
}
