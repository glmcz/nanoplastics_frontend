import 'package:http/http.dart' as http;

/// See the io implementation: the browser owns the trust store, so nothing is
/// bundled here.
const bool kUsesBundledRootCertificate = false;

/// Web build of [buildTrustedHttpClient].
///
/// The browser owns TLS here: XHR/fetch use the browser's own trust store, and
/// the socket APIs this would otherwise need do not exist on the web platform.
/// The default client is therefore both correct and the only option.
Future<http.Client> buildTrustedHttpClient() async => http.Client();
