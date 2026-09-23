// The web counterpart of app_http_client_test.dart. It runs only on the Chrome
// platform (flutter test --platform chrome), which is where CI exercises the
// web build, and pins the half of the conditional import the VM never sees.
@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nanoplastics_app/services/http/app_http_client.dart';

void main() {
  test('the web build does not take the bundled-root path', () {
    // A mis-selected conditional import would be invisible at runtime: the
    // io implementation's own fallback returns the same BrowserClient once
    // SecurityContext throws in the browser. This flag is the only difference.
    expect(AppHttpClient.usesBundledRootCertificate, isFalse);
  });

  test('the shared client is a plain browser client', () async {
    final client = await AppHttpClient.instance.delegateForTesting;
    expect(client, isA<http.Client>());
    expect(client.runtimeType.toString(), 'BrowserClient');
  });
}
