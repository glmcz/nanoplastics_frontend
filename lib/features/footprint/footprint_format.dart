import 'dart:math' as math;

/// Strings the formatter needs, supplied by the widget layer so this file
/// stays free of Flutter and testable on its own.
abstract class FootprintStrings {
  String get about;
  String get million;
  String get billion;
  String get trillion;
  String get perSecond;
  String get milligram;
  String get gram;
}

/// Wraps a number so it keeps its own direction inside an Arabic sentence.
/// Without this, a digit sequence next to Arabic text can reorder and the
/// student reads a different number than the one we computed.
///
/// Written as escapes rather than literal characters on purpose: invisible
/// bidi control characters in source are how Trojan Source attacks work, and
/// the analyzer rightly refuses them.
const String _firstStrongIsolate = '\u2068';
const String _popDirectionalIsolate = '\u2069';

String isolate(String s) => '$_firstStrongIsolate$s$_popDirectionalIsolate';

double _oneSigFig(double n) {
  if (n <= 0) return 0;
  final magnitude = (math.log(n) / math.ln10).floor();
  final scale = math.pow(10, magnitude).toDouble();
  return (n / scale).round() * scale;
}

String _trim(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

/// One significant figure plus a scale word. Precision here would be false:
/// the underlying bands span a factor of two or more.
///
/// Digits stay Western in every locale, matching the convention already used
/// throughout this app's ARB files.
String formatParticles(double n, FootprintStrings s) {
  if (n <= 0) return '0';
  final r = _oneSigFig(n);
  if (r < 10) return _trim(r);
  if (r < 1000) return '${s.about} ${_trim(r)}';
  if (r < 1e9) return '${s.about} ${_trim(r / 1e6)} ${s.million}';
  if (r < 1e12) return '${s.about} ${_trim(r / 1e9)} ${s.billion}';
  return '${s.about} ${_trim(r / 1e12)} ${s.trillion}';
}

/// Milligrams until a gram is the more readable unit.
///
/// One significant figure here too, and for the same reason as the counts:
/// the cutting-board source reports a band of 7.4 to 50.7 grams a year, so
/// printing "29 g" would claim a precision the measurement does not have.
String formatMassMg(double mg, FootprintStrings s) {
  if (mg <= 0) return '0 ${s.milligram}';
  if (mg >= 1000) return '${_trim(_oneSigFig(mg / 1000))} ${s.gram}';
  return '${_trim(_oneSigFig(mg))} ${s.milligram}';
}
