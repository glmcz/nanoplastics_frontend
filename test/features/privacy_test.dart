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

  test('the policy names usage events, retention and deletion', () {
    final source = File('lib/screens/user_settings/privacy_policy_screen.dart')
        .readAsStringSync()
        .toLowerCase();
    expect(source, contains('180 days'));
    expect(source, contains('usage statistics'));
    expect(source, contains('outside your country'));
    expect(source, contains('delete a submission'));
  });
}
