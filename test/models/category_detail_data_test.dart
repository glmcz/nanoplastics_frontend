import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import 'package:nanoplastics_app/models/category_detail_data.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    // Load English localizations without needing a BuildContext
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('CategoryDetailDataFactory - Human categories', () {
    test('centralSystems returns valid data', () {
      final data = CategoryDetailDataFactory.centralSystems(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.subtitle.isNotEmpty, isTrue);
      expect(data.entries.isNotEmpty, isTrue);
      expect(data.entries.length, equals(2));
      expect(data.sourceLinks, isNotNull);
      expect(data.sourceLinks!.length, equals(3));
    });

    test('filtrationDetox returns valid data', () {
      final data = CategoryDetailDataFactory.filtrationDetox(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.length, equals(2));
      expect(data.sourceLinks!.length, equals(3));
    });

    test('vitalityTissues returns valid data', () {
      final data = CategoryDetailDataFactory.vitalityTissues(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.length, equals(1));
      expect(data.sourceLinks!.length, equals(3));
    });

    test('reproduction returns valid data', () {
      final data = CategoryDetailDataFactory.reproduction(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.length, equals(1));
      expect(data.sourceLinks!.length, equals(4));
    });

    test('entryGates returns valid data', () {
      final data = CategoryDetailDataFactory.entryGates(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.length, equals(3));
      expect(data.sourceLinks!.length, equals(3));
    });

    test('physicalAttack returns valid data', () {
      final data = CategoryDetailDataFactory.physicalAttack(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.length, equals(3));
      expect(data.sourceLinks!.length, equals(3));
    });
  });

  group('CategoryDetailDataFactory - Planet categories', () {
    test('worldOcean returns valid data', () {
      final data = CategoryDetailDataFactory.worldOcean(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.isNotEmpty, isTrue);
      expect(data.sourceLinks, isNotNull);
    });

    test('atmosphere returns valid data', () {
      final data = CategoryDetailDataFactory.atmosphere(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.isNotEmpty, isTrue);
    });

    test('florFauna returns valid data', () {
      final data = CategoryDetailDataFactory.florFauna(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.length, equals(2));
    });

    test('magneticField returns valid data', () {
      final data = CategoryDetailDataFactory.magneticField(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.length, equals(1));
    });

    test('planetEntryGates returns valid data', () {
      final data = CategoryDetailDataFactory.planetEntryGates(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.length, equals(1));
    });

    test('physicalProperties returns valid data', () {
      final data = CategoryDetailDataFactory.physicalProperties(l10n);
      expect(data.title.isNotEmpty, isTrue);
      expect(data.entries.length, equals(4));
    });
  });

  group('CategoryDetailDataFactory - All factories', () {
    test('every factory produces entries with valid page ranges', () {
      final allFactories = [
        CategoryDetailDataFactory.centralSystems(l10n),
        CategoryDetailDataFactory.filtrationDetox(l10n),
        CategoryDetailDataFactory.vitalityTissues(l10n),
        CategoryDetailDataFactory.reproduction(l10n),
        CategoryDetailDataFactory.entryGates(l10n),
        CategoryDetailDataFactory.physicalAttack(l10n),
        CategoryDetailDataFactory.worldOcean(l10n),
        CategoryDetailDataFactory.atmosphere(l10n),
        CategoryDetailDataFactory.florFauna(l10n),
        CategoryDetailDataFactory.magneticField(l10n),
        CategoryDetailDataFactory.planetEntryGates(l10n),
        CategoryDetailDataFactory.physicalProperties(l10n),
      ];

      for (final data in allFactories) {
        for (final entry in data.entries) {
          if (entry.pdfStartPage != null && entry.pdfEndPage != null) {
            expect(
              entry.pdfStartPage! <= entry.pdfEndPage!,
              isTrue,
              reason:
                  '${data.title} -> ${entry.highlight}: start ${entry.pdfStartPage} > end ${entry.pdfEndPage}',
            );
          }
        }
      }
    });

    test('every factory produces sourceLinks with non-empty URLs', () {
      final allFactories = [
        CategoryDetailDataFactory.centralSystems(l10n),
        CategoryDetailDataFactory.filtrationDetox(l10n),
        CategoryDetailDataFactory.vitalityTissues(l10n),
        CategoryDetailDataFactory.reproduction(l10n),
        CategoryDetailDataFactory.entryGates(l10n),
        CategoryDetailDataFactory.physicalAttack(l10n),
        CategoryDetailDataFactory.worldOcean(l10n),
        CategoryDetailDataFactory.atmosphere(l10n),
        CategoryDetailDataFactory.florFauna(l10n),
        CategoryDetailDataFactory.magneticField(l10n),
        CategoryDetailDataFactory.planetEntryGates(l10n),
        CategoryDetailDataFactory.physicalProperties(l10n),
      ];

      for (final data in allFactories) {
        if (data.sourceLinks != null) {
          for (final link in data.sourceLinks!) {
            expect(link.url.isNotEmpty, isTrue,
                reason: '${data.title} -> ${link.title}: empty URL');
            expect(link.title.isNotEmpty, isTrue,
                reason: '${data.title}: empty source link title');
          }
        }
      }
    });
  });

  group('DetailEntry', () {
    test('bulletPoints can be null', () {
      const entry = DetailEntry(
        highlight: 'Test',
        description: 'Desc',
      );
      expect(entry.bulletPoints, isNull);
    });

    test('pdfStartPage and pdfEndPage can be null', () {
      const entry = DetailEntry(
        highlight: 'Test',
        description: 'Desc',
      );
      expect(entry.pdfStartPage, isNull);
      expect(entry.pdfEndPage, isNull);
    });
  });

  group('SourceLink', () {
    test('pdfAssetPath defaults to null', () {
      const link = SourceLink(
        title: 'Test',
        source: 'Source',
        url: 'https://example.com',
      );
      expect(link.pdfAssetPath, isNull);
    });
  });
}
