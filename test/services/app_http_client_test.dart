// Android 7.0–7.1.0 (API 24) ships a trust store without ISRG Root X1, so every
// HTTPS call to api.nanosolve.org fails there with CERTIFICATE_VERIFY_FAILED.
// The fix bundles that root and feeds it to a SecurityContext. These tests
// exercise dart:io and the Flutter asset bundle, neither of which exists on the
// Chrome platform (flutter test --platform chrome).
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nanoplastics_app/services/http/app_http_client.dart';
import 'package:nanoplastics_app/services/http/trusted_http_client_io.dart';
import 'package:nanoplastics_app/services/http/trusted_http_client_web.dart'
    as web_impl;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bundled ISRG roots', () {
    test('is declared in every pubspec a release build could come from', () {
      // An asset that is only on disk never reaches the device. pubspec.base
      // is checked too because the release workflow used to regenerate
      // pubspec.yaml from it; that step is currently removed, but if it comes
      // back an asset listed only in pubspec.yaml is dropped from every CI APK.
      final candidates = ['pubspec.yaml', 'pubspec.base.yaml']
          .map(File.new)
          .where((file) => file.existsSync());
      for (final file in candidates) {
        expect(
          file.readAsStringSync(),
          contains(bundledRootsAssetPath),
          reason: '${file.path} would ship a build with no bundled root',
        );
      }
    });

    test('loads from the asset bundle and holds every root on the chain',
        () async {
      // The served chain is nanosolve.org ← YE1 ← Root YE ← X2 ← X1, where the
      // last two links are cross-signs nginx sends today. X1 alone anchors it
      // only while both cross-signs are served; drop either and API 24 breaks
      // again. X2 and Root YE close those two gaps.
      final pem = utf8.decode(await loadBundledRootCertificate());
      final blocks = RegExp(
        r'-----BEGIN CERTIFICATE-----([\s\S]*?)-----END CERTIFICATE-----',
      ).allMatches(pem).map((m) => m.group(1)!.replaceAll(RegExp(r'\s'), ''));

      // The subject sits in the DER as plain ASCII, so a substituted or
      // hand-typed certificate fails here rather than in the field. The
      // notAfter is the ASN.1 UTCTime of each official root.
      final roots = blocks.map((b) => latin1.decode(base64.decode(b))).toList();
      const expected = {
        'ISRG Root X1': '350604110438Z',
        'ISRG Root X2': '400917160000Z',
        'Root YE': '450902235959Z',
      };
      expect(roots, hasLength(expected.length));
      for (final MapEntry(key: name, value: notAfter) in expected.entries) {
        expect(
          roots.where((der) => der.contains(name) && der.contains(notAfter)),
          hasLength(1),
          reason: '$name missing from $bundledRootsAssetPath',
        );
      }
    });

    test('is accepted by BoringSSL as a trust root', () async {
      final bytes = await loadBundledRootCertificate();
      expect(() => buildSecurityContext(bytes), returnsNormally);
    });

    test('malformed roots are rejected, so the previous test is not vacuous',
        () {
      // If setTrustedCertificatesBytes were ever dropped from
      // buildSecurityContext, these would stop throwing and this test goes red.
      expect(
        () => buildSecurityContext(Uint8List(0)),
        throwsA(isA<TlsException>()),
      );
      expect(
        () => buildSecurityContext(
          Uint8List.fromList(utf8.encode('not a certificate')),
        ),
        throwsA(isA<TlsException>()),
      );
    });

    test('adding a root the platform already trusts is not an error', () async {
      // On Android 12 and iOS, ISRG Root X1 is already in the system store.
      // A duplicate add must not throw, or the fix would break the platforms
      // that currently work.
      final bytes = await loadBundledRootCertificate();
      final context = buildSecurityContext(bytes);
      expect(() => context.setTrustedCertificatesBytes(bytes), returnsNormally);
    });
  });

  group('AppHttpClient', () {
    test('this build adds the bundled root', () {
      // The web counterpart asserts the opposite; see
      // test/services/app_http_client_web_test.dart.
      expect(AppHttpClient.usesBundledRootCertificate, isTrue);
    });

    test('is one shared instance', () {
      expect(identical(AppHttpClient.instance, AppHttpClient.instance), isTrue);
    });

    test('builds its delegate once and reuses it', () async {
      final first = await AppHttpClient.instance.delegateForTesting;
      final second = await AppHttpClient.instance.delegateForTesting;
      expect(
        identical(first, second),
        isTrue,
        reason: 'a SecurityContext per request is expensive and leaks sockets',
      );
      expect(
        first,
        isA<TrustedRootHttpClient>(),
        reason: 'a bare http.Client here means the bundled-root path fell back',
      );
    });

    test('is reusable without awaiting once warmed up', () async {
      await AppHttpClient.instance.warmUp();
      // send() reads this synchronously. A memoised Future would be bound to
      // the zone that created it, and every testWidgets body gets its own
      // FakeAsync zone, so a carried-over Future never completes for the next
      // test. That cost ten passing widget tests before it was caught.
      expect(
        AppHttpClient.instance.resolved,
        isA<TrustedRootHttpClient>(),
        reason:
            'warmUp() must leave a client that send() can use with no await',
      );
    });
  });

  group('web fallback', () {
    test('returns a usable client without touching dart:io', () async {
      final client = await web_impl.buildTrustedHttpClient();
      expect(client, isA<http.Client>());
      client.close();
    });

    // Source-level guards. dart:io compiles to a throwing stub under dart2js
    // rather than failing the build, so a regression here would only surface as
    // a runtime crash in the browser. Assert the shape instead.
    test('web implementation imports neither dart:io nor SecurityContext', () {
      final source = File('lib/services/http/trusted_http_client_web.dart')
          .readAsStringSync();
      expect(source, isNot(contains("import 'dart:io'")));
      expect(source, isNot(contains('SecurityContext')));
    });

    test('the shared client picks its implementation by conditional import',
        () {
      final source =
          File('lib/services/http/app_http_client.dart').readAsStringSync();
      expect(source, isNot(contains("import 'dart:io'")));
      // Default branch must be the web implementation: dart.library.io is false
      // on both dart2js and dart2wasm, whereas dart.library.html is false under
      // wasm and would silently select the dart:io branch there.
      expect(source, contains("import 'trusted_http_client_web.dart'"));
      expect(
        source,
        contains("if (dart.library.io) 'trusted_http_client_io.dart'"),
      );
    });
  });
}
