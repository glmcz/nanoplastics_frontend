import '../../l10n/app_localizations.dart';
import 'footprint_format.dart';

/// Supplies the formatter's strings from the generated localisations, so the
/// formatter itself stays free of Flutter.
class L10nFootprintStrings implements FootprintStrings {
  final AppLocalizations l;
  const L10nFootprintStrings(this.l);

  @override
  String get about => l.footprintAbout;
  @override
  String get million => l.footprintMillion;
  @override
  String get billion => l.footprintBillion;
  @override
  String get trillion => l.footprintTrillion;
  @override
  String get perSecond => l.footprintPerSecond;
  @override
  String get milligram => l.footprintMilligram;
  @override
  String get gram => l.footprintGram;
}
