import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Manages PDF file caching and retrieval
/// Handles: PDF file operations, getCachedPdfLanguages, getPdfForLanguage
class PdfCacheManager {
  /// Get the PDFs cache directory
  Future<Directory> _getPdfsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return Directory('${appDocDir.path}/pdfs');
  }

  /// Get PDF file for a specific language
  Future<File?> getPdfForLanguage(String language) async {
    try {
      final pdfsDir = await _getPdfsDirectory();
      final fileName =
          'Nanoplastics_Report_${language.toUpperCase()}_compressed.pdf';
      final file = File('${pdfsDir.path}/$fileName');

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get list of cached PDF languages
  Future<List<String>> getCachedPdfLanguages() async {
    try {
      final pdfsDir = await _getPdfsDirectory();
      if (!await pdfsDir.exists()) {
        return [];
      }

      final files = pdfsDir.listSync();
      final languages = <String>[];

      for (final file in files) {
        if (file is File &&
            file.path.contains('Nanoplastics_Report_') &&
            file.path.endsWith('.pdf')) {
          // Extract language from filename
          final fileName = file.path.split('/').last;
          if (fileName.startsWith('Nanoplastics_Report_')) {
            final langPart = fileName.replaceFirst('Nanoplastics_Report_', '');
            final lang = langPart.replaceFirst('_compressed.pdf', '');
            languages.add(lang.toLowerCase());
          }
        }
      }

      return languages;
    } catch (e) {
      return [];
    }
  }

  /// Save PDF to cache
  Future<void> savePdfLocally(String language, List<int> bytes) async {
    try {
      final pdfsDir = await _getPdfsDirectory();
      if (!await pdfsDir.exists()) {
        await pdfsDir.create(recursive: true);
      }

      final fileName =
          'Nanoplastics_Report_${language.toUpperCase()}_compressed.pdf';
      final file = File('${pdfsDir.path}/$fileName');
      await file.writeAsBytes(bytes);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete cached PDF for a language
  Future<void> deleteCachedPdf(String language) async {
    try {
      final pdfsDir = await _getPdfsDirectory();
      final fileName =
          'Nanoplastics_Report_${language.toUpperCase()}_compressed.pdf';
      final file = File('${pdfsDir.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all cached PDFs
  Future<void> clearAllCachedPdfs() async {
    try {
      final pdfsDir = await _getPdfsDirectory();
      if (await pdfsDir.exists()) {
        await pdfsDir.delete(recursive: true);
      }
    } catch (e) {
      rethrow;
    }
  }
}
