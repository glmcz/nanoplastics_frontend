import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nanoplastics_app/config/backend_config.dart';

/// Gap between the suites' vault writes. Prod rate-limits per IP (burst 10, one
/// token back every 2 s, `build_router`), app startup spends part of the burst,
/// and a refused write reads as `addToTresor => false` or a vault row left over.
const writePace = Duration(seconds: 2);

/// Fails the suite when the backend is not answering, so a dead server or an
/// offline phone cannot turn into "no papers" and a green run.
Future<void> expectBackendHealthy() async {
  final url = '${BackendConfig.getBaseUrl()}/health';
  debugPrint('[TEST] Backend: $url');
  int? status;
  Object? error;
  try {
    final resp =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    status = resp.statusCode;
  } catch (e) {
    error = e;
  }
  expect(status, 200,
      reason: 'backend unhealthy at $url '
          '(${error ?? 'HTTP $status'}); check the phone is online '
          '(adb shell ping -c1 api.nanosolve.org) and the server is up');
}
