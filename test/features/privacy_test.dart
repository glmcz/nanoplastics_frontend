// Reads a .dart source file off disk with dart:io, which the Chrome
// platform (flutter test --platform chrome) does not provide.
@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/services/service_locator.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  setUp(() async => await setupServiceLocator());

  test('the analytics switch actually stops collection', () async {
    final events = ServiceLocator().eventService;
    events.setEnabled(true);
    events.log('screen_opened');
    expect(events.debugQueueLength, 1);

    events.setEnabled(false);
    expect(events.debugQueueLength, 0,
        reason: 'off must discard what was already queued');
    events.log('screen_opened');
    expect(events.debugQueueLength, 0);
  });

  // The app and the website show one policy, from the web ARB files.
  String policy() =>
      File('assets/l10n_web/web_en.arb').readAsStringSync().toLowerCase();

  test('the policy names usage events, retention and deletion', () {
    final source = policy();
    expect(source, contains('180 days'));
    expect(source, contains('usage statistics'));
    expect(source, contains('outside your country'));
    expect(source, contains('delete a submission'));
  });

  test('the policy names what the daily digest stores and who sends it', () {
    final source = policy();
    expect(source, contains('daily research digest'));
    expect(source, contains('time zone'));
    expect(source, contains('push token'));
    expect(source, contains('firebase cloud messaging'));
    expect(source, contains('apple push notification'));
    expect(source, contains('resend'));
    expect(source, contains('support@nanosolve.org'));
    expect(source, isNot(contains('support@nanosolve.com')));
    // The app deletes the server account itself now (DigestService.deleteAccount).
    expect(source, contains('erases your account from our servers'));
    expect(source, contains('6-digit code'));
  });
}
