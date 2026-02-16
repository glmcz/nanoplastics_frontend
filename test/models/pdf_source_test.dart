import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/pdf_source.dart';

void main() {
  group('PDFSource', () {
    test('isWebLink returns true when url is non-null and non-empty', () {
      final source = PDFSource(
        title: 'Test',
        startPage: 1,
        endPage: 10,
        description: 'Test desc',
        url: 'https://example.com',
      );
      expect(source.isWebLink, isTrue);
    });

    test('isWebLink returns false when url is null', () {
      final source = PDFSource(
        title: 'Test',
        startPage: 1,
        endPage: 10,
        description: 'Test desc',
      );
      expect(source.isWebLink, isFalse);
    });

    test('isWebLink returns false when url is empty string', () {
      final source = PDFSource(
        title: 'Test',
        startPage: 1,
        endPage: 10,
        description: 'Test desc',
        url: '',
      );
      expect(source.isWebLink, isFalse);
    });

    test('default language is "en"', () {
      final source = PDFSource(
        title: 'Test',
        startPage: 1,
        endPage: 10,
        description: 'Test desc',
      );
      expect(source.language, equals('en'));
    });

    test('pdfAssetPath is null by default', () {
      final source = PDFSource(
        title: 'Test',
        startPage: 1,
        endPage: 10,
        description: 'Test desc',
      );
      expect(source.pdfAssetPath, isNull);
    });
  });

  group('humanHealthSources', () {
    test('contains sources for both en and cs languages', () {
      final languages =
          humanHealthSources.map((s) => s.language).toSet();
      expect(languages, containsAll(['en', 'cs']));
    });

    test('all sources have valid page ranges (startPage <= endPage)', () {
      for (final source in humanHealthSources) {
        expect(
          source.startPage <= source.endPage,
          isTrue,
          reason:
              '${source.title}: startPage ${source.startPage} > endPage ${source.endPage}',
        );
      }
    });

    test('all sources have non-empty title and description', () {
      for (final source in humanHealthSources) {
        expect(source.title.isNotEmpty, isTrue,
            reason: 'Found empty title');
        expect(source.description.isNotEmpty, isTrue,
            reason: 'Found empty description for ${source.title}');
      }
    });

    test('has 10 English and 10 Czech sources', () {
      final enSources =
          humanHealthSources.where((s) => s.language == 'en').toList();
      final csSources =
          humanHealthSources.where((s) => s.language == 'cs').toList();
      expect(enSources.length, equals(10));
      expect(csSources.length, equals(10));
    });
  });

  group('earthPollutionSources', () {
    test('contains sources for en, cs, es, ru, fr', () {
      final languages =
          earthPollutionSources.map((s) => s.language).toSet();
      expect(languages, containsAll(['en', 'cs', 'es', 'ru', 'fr']));
    });

    test('main report sources have endPage of 999', () {
      final mainReports = earthPollutionSources.where(
        (s) => s.title.contains('Report') || s.title.contains('Zpráva') ||
               s.title.contains('Informe') || s.title.contains('Отчёт') ||
               s.title.contains('Rapport'),
      );
      expect(mainReports.isNotEmpty, isTrue);
      for (final report in mainReports) {
        expect(report.endPage, equals(999),
            reason: '${report.title} endPage should be 999');
      }
    });

    test('EN main report has pdfAssetPath set', () {
      final enMainReport = earthPollutionSources.firstWhere(
        (s) =>
            s.language == 'en' &&
            s.title.contains('Nanoplastics in the Biosphere'),
      );
      expect(enMainReport.pdfAssetPath, isNotNull);
      expect(enMainReport.pdfAssetPath,
          contains('Nanoplastics_Report_EN_compressed.pdf'));
    });

    test('all sources have valid page ranges', () {
      for (final source in earthPollutionSources) {
        expect(
          source.startPage <= source.endPage,
          isTrue,
          reason:
              '${source.title}: startPage ${source.startPage} > endPage ${source.endPage}',
        );
      }
    });
  });

  group('waterAbilitiesSources', () {
    test('contains exactly 2 sources (en and cs)', () {
      expect(waterAbilitiesSources.length, equals(2));
      final languages =
          waterAbilitiesSources.map((s) => s.language).toSet();
      expect(languages, equals({'en', 'cs'}));
    });

    test('both have custom pdfAssetPath', () {
      for (final source in waterAbilitiesSources) {
        expect(source.pdfAssetPath, isNotNull,
            reason: '${source.title} should have pdfAssetPath');
        expect(source.pdfAssetPath!.contains('WATER_compressed.pdf'), isTrue);
      }
    });
  });

  group('allVideoSources', () {
    test('contains entries for all 5 languages', () {
      expect(allVideoSources.keys, containsAll(['en', 'cs', 'es', 'ru', 'fr']));
    });

    test('each language has at least 1 video source', () {
      for (final entry in allVideoSources.entries) {
        expect(
          entry.value.isNotEmpty,
          isTrue,
          reason: 'Language ${entry.key} has no video sources',
        );
      }
    });

    test('all URLs start with http', () {
      for (final entry in allVideoSources.entries) {
        for (final video in entry.value) {
          expect(
            video.url.startsWith('http'),
            isTrue,
            reason: '${video.title} URL does not start with http: ${video.url}',
          );
        }
      }
    });

    test('all video sources have non-empty title', () {
      for (final entry in allVideoSources.entries) {
        for (final video in entry.value) {
          expect(video.title.isNotEmpty, isTrue);
        }
      }
    });

    test('video source language matches map key', () {
      for (final entry in allVideoSources.entries) {
        for (final video in entry.value) {
          expect(
            video.language,
            equals(entry.key),
            reason:
                '${video.title} language ${video.language} != map key ${entry.key}',
          );
        }
      }
    });
  });
}
