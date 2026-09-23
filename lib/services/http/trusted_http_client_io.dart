import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../logger_service.dart';

/// ISRG Root X1, ISRG Root X2 and Root YE — every root the api.nanosolve.org
/// chain (leaf ← YE1 ← Root YE ← X2 ← X1) can terminate at.
///
/// Android only shipped X1 in its system store from 7.1.1 (API 25), and X2 and
/// YE later still. Our minSdk is 24, so on 7.0–7.1.0 the device cannot build a
/// chain and every HTTPS call dies with CERTIFICATE_VERIFY_FAILED. Bundling the
/// roots and adding them to the client's [SecurityContext] closes that gap
/// without moving minSdk. X1 alone is enough only while nginx keeps sending the
/// X1-signed X2 and X2-signed YE cross-certificates; X2 and YE cover the day
/// either one stops being served.
const String bundledRootsAssetPath = 'assets/certs/isrg_roots.pem';

/// True on every platform that builds its own trust store from the bundled
/// root. The web build declares false. Without a flag the two branches are
/// indistinguishable from the outside, because the fallback below returns the
/// same plain client the web implementation does.
const bool kUsesBundledRootCertificate = true;

@visibleForTesting
Future<Uint8List> loadBundledRootCertificate() async {
  final data = await rootBundle.load(bundledRootsAssetPath);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

/// Starts from whatever the platform already trusts and adds the bundled root.
///
/// [withTrustedRoots] keeps every other CA working, so nothing changes on
/// Android 8+ or iOS, where ISRG Root X1 is already present and this add is a
/// no-op. Throws [TlsException] if the bytes are not parseable certificates.
@visibleForTesting
SecurityContext buildSecurityContext(Uint8List rootCertificatePem) {
  final context = SecurityContext(withTrustedRoots: true);
  context.setTrustedCertificatesBytes(rootCertificatePem);
  return context;
}

/// An [IOClient] whose trust store includes the bundled root.
///
/// It exists as a named type so the fallback below is distinguishable: a plain
/// client is also an [IOClient] on the VM, which would make "did the bundled
/// root actually load?" unanswerable from the outside.
class TrustedRootHttpClient extends IOClient {
  TrustedRootHttpClient(HttpClient super.inner);
}

/// Built once per process by [AppHttpClient]; never call this per request.
Future<http.Client> buildTrustedHttpClient() async {
  try {
    final context = buildSecurityContext(await loadBundledRootCertificate());
    return TrustedRootHttpClient(HttpClient(context: context));
  } catch (error, stackTrace) {
    // A missing or unreadable asset must not take down HTTPS on the platforms
    // that never needed the bundled root in the first place.
    LoggerService().logError(
      'bundled_root_certificate_unavailable',
      error,
      stackTrace,
    );
    return http.Client();
  }
}
