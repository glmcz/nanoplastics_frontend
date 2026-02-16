import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/category_detail_data.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    // Load English localizations for testing
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  /// Maps category IDs (as used in MainScreen switch) to factory methods.
  /// This mirrors the switch in main_screen.dart:503-539.
  Map<String, CategoryDetailData> buildCategoryMap(AppLocalizations l10n) {
    return {
      'human_central': CategoryDetailDataFactory.centralSystems(l10n),
      'human_detox': CategoryDetailDataFactory.filtrationDetox(l10n),
      'human_vitality': CategoryDetailDataFactory.vitalityTissues(l10n),
      'human_reproduction': CategoryDetailDataFactory.reproduction(l10n),
      'human_entry': CategoryDetailDataFactory.entryGates(l10n),
      'human_ways_of_destruction': CategoryDetailDataFactory.physicalAttack(l10n),
      'planet_ocean': CategoryDetailDataFactory.worldOcean(l10n),
      'planet_atmosphere': CategoryDetailDataFactory.atmosphere(l10n),
      'planet_bio': CategoryDetailDataFactory.florFauna(l10n),
      'planet_magnetic': CategoryDetailDataFactory.magneticField(l10n),
      'planet_entry': CategoryDetailDataFactory.planetEntryGates(l10n),
      'planet_physical': CategoryDetailDataFactory.physicalProperties(l10n),
    };
  }

  group('Category ID → Factory completeness', () {
    test('all 6 human category IDs resolve to non-null data', () {
      final map = buildCategoryMap(l10n);
      final humanIds = [
        'human_central',
        'human_detox',
        'human_vitality',
        'human_reproduction',
        'human_entry',
        'human_ways_of_destruction',
      ];

      for (final id in humanIds) {
        expect(map.containsKey(id), isTrue,
            reason: 'Missing factory for human ID: $id');
        expect(map[id], isNotNull,
            reason: 'Factory returned null for human ID: $id');
      }
    });

    test('all 6 planet category IDs resolve to non-null data', () {
      final map = buildCategoryMap(l10n);
      final planetIds = [
        'planet_ocean',
        'planet_atmosphere',
        'planet_bio',
        'planet_magnetic',
        'planet_entry',
        'planet_physical',
      ];

      for (final id in planetIds) {
        expect(map.containsKey(id), isTrue,
            reason: 'Missing factory for planet ID: $id');
        expect(map[id], isNotNull,
            reason: 'Factory returned null for planet ID: $id');
      }
    });

    test('exactly 12 category IDs exist (no extras, no missing)', () {
      final map = buildCategoryMap(l10n);
      expect(map.length, equals(12));
    });
  });

  group('CategoryDetailData integrity', () {
    test('every category has non-empty title and subtitle', () {
      final map = buildCategoryMap(l10n);
      for (final entry in map.entries) {
        expect(entry.value.title.isNotEmpty, isTrue,
            reason: '${entry.key} has empty title');
        expect(entry.value.subtitle.isNotEmpty, isTrue,
            reason: '${entry.key} has empty subtitle');
      }
    });

    test('every category has at least one DetailEntry', () {
      final map = buildCategoryMap(l10n);
      for (final entry in map.entries) {
        expect(entry.value.entries.isNotEmpty, isTrue,
            reason: '${entry.key} has no detail entries');
      }
    });
  });

  group('PDF page range validation', () {
    test(
        'every DetailEntry with pdfStartPage also has pdfEndPage and vice versa',
        () {
      final map = buildCategoryMap(l10n);
      for (final category in map.entries) {
        for (final entry in category.value.entries) {
          if (entry.pdfStartPage != null) {
            expect(entry.pdfEndPage, isNotNull,
                reason:
                    '${category.key}: entry "${entry.highlight}" has startPage but no endPage');
          }
          if (entry.pdfEndPage != null) {
            expect(entry.pdfStartPage, isNotNull,
                reason:
                    '${category.key}: entry "${entry.highlight}" has endPage but no startPage');
          }
        }
      }
    });

    test('all DetailEntry pdfStartPage <= pdfEndPage', () {
      final map = buildCategoryMap(l10n);
      for (final category in map.entries) {
        for (final entry in category.value.entries) {
          if (entry.pdfStartPage != null && entry.pdfEndPage != null) {
            expect(entry.pdfStartPage! <= entry.pdfEndPage!, isTrue,
                reason:
                    '${category.key}: entry "${entry.highlight}" has inverted page range: '
                    '${entry.pdfStartPage}-${entry.pdfEndPage}');
          }
        }
      }
    });

    test('all page numbers are within reasonable bounds (1-250)', () {
      final map = buildCategoryMap(l10n);
      for (final category in map.entries) {
        for (final entry in category.value.entries) {
          if (entry.pdfStartPage != null) {
            expect(entry.pdfStartPage! >= 1, isTrue,
                reason:
                    '${category.key}: startPage ${entry.pdfStartPage} < 1');
            expect(entry.pdfStartPage! <= 250, isTrue,
                reason:
                    '${category.key}: startPage ${entry.pdfStartPage} > 250');
          }
          if (entry.pdfEndPage != null) {
            expect(entry.pdfEndPage! >= 1, isTrue,
                reason: '${category.key}: endPage ${entry.pdfEndPage} < 1');
            expect(entry.pdfEndPage! <= 250, isTrue,
                reason:
                    '${category.key}: endPage ${entry.pdfEndPage} > 250');
          }
        }
      }
    });
  });

  group('SourceLink validation', () {
    test('all SourceLink URLs are valid URIs', () {
      final map = buildCategoryMap(l10n);
      for (final category in map.entries) {
        final links = category.value.sourceLinks;
        if (links == null) continue;
        for (final link in links) {
          final uri = Uri.tryParse(link.url);
          expect(uri, isNotNull,
              reason:
                  '${category.key}: invalid URL "${link.url}" for source "${link.title}"');
        }
      }
    });

    test('all SourceLink URLs use HTTPS', () {
      final map = buildCategoryMap(l10n);
      for (final category in map.entries) {
        final links = category.value.sourceLinks;
        if (links == null) continue;
        for (final link in links) {
          expect(link.url.startsWith('https://'), isTrue,
              reason:
                  '${category.key}: URL "${link.url}" does not use HTTPS');
        }
      }
    });

    test('all SourceLinks have non-empty title and source', () {
      final map = buildCategoryMap(l10n);
      for (final category in map.entries) {
        final links = category.value.sourceLinks;
        if (links == null) continue;
        for (final link in links) {
          expect(link.title.isNotEmpty, isTrue,
              reason: '${category.key}: SourceLink has empty title');
          expect(link.source.isNotEmpty, isTrue,
              reason: '${category.key}: SourceLink has empty source');
        }
      }
    });

    test('SourceLinks with pdfAssetPath have valid page ranges', () {
      final map = buildCategoryMap(l10n);
      for (final category in map.entries) {
        final links = category.value.sourceLinks;
        if (links == null) continue;
        for (final link in links) {
          if (link.pdfAssetPath != null) {
            expect(link.pdfStartPage, isNotNull,
                reason:
                    '${category.key}: SourceLink "${link.title}" has pdfAssetPath but no startPage');
            expect(link.pdfEndPage, isNotNull,
                reason:
                    '${category.key}: SourceLink "${link.title}" has pdfAssetPath but no endPage');
            if (link.pdfStartPage != null && link.pdfEndPage != null) {
              expect(link.pdfStartPage! <= link.pdfEndPage!, isTrue,
                  reason:
                      '${category.key}: SourceLink "${link.title}" has inverted page range');
            }
          }
        }
      }
    });
  });

  group('Localization consistency', () {
    test('all categories produce valid data for all 5 supported languages',
        () async {
      final locales = ['en', 'cs', 'es', 'fr', 'ru'];
      for (final langCode in locales) {
        final localL10n =
            await AppLocalizations.delegate.load(Locale(langCode));
        final map = buildCategoryMap(localL10n);

        expect(map.length, equals(12),
            reason: 'Language $langCode: expected 12 categories');

        for (final entry in map.entries) {
          expect(entry.value.title.isNotEmpty, isTrue,
              reason: 'Language $langCode, ${entry.key}: empty title');
          expect(entry.value.entries.isNotEmpty, isTrue,
              reason: 'Language $langCode, ${entry.key}: no entries');
        }
      }
    });
  });
}
