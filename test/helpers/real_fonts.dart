import 'dart:io';
import 'package:flutter/services.dart';

/// Loads Roboto and the Material icon font from the Flutter SDK.
///
/// The default test font draws every glyph one em wide, so text measures about
/// twice as wide as on a phone and overflow results can't be trusted. The theme
/// asks for SF Pro and the logo for Montserrat; the app bundles neither, so
/// Android renders Roboto. The test engine ignores fontFamilyFallback, so
/// register Roboto under each of those names.
Future<void> loadRealFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  if (root == null || !dir.existsSync()) {
    throw StateError('Roboto not found under FLUTTER_ROOT ($root); '
        'run `flutter precache` so these tests measure real text widths.');
  }

  Future<ByteData> read(String file) async =>
      ByteData.sublistView(File('${dir.path}/$file').readAsBytesSync());

  for (final family in ['SF Pro', 'Montserrat', 'Roboto']) {
    final loader = FontLoader(family);
    for (final weight in ['Light', 'Regular', 'Medium', 'Bold', 'Black']) {
      loader.addFont(read('Roboto-$weight.ttf'));
    }
    await loader.load();
  }
  await (FontLoader('MaterialIcons')
        ..addFont(read('MaterialIcons-Regular.otf')))
      .load();
}
