import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nanoplastics_app/services/event_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('queued events are posted as one batch', () async {
    late String body;
    final service = EventService()
      ..client = MockClient((req) async {
        body = req.body;
        return http.Response('{"accepted":2}', 200);
      });
    await service.init(enabled: true);
    service.log('footprint_started', props: {'mode': 'story'});
    service.log('footprint_result', props: {'mode': 'story'});
    await service.flush();

    final sent = jsonDecode(body) as List;
    expect(sent, hasLength(2));
    expect(sent.first['name'], 'footprint_started');
    expect(sent.first['install_id'], isNotEmpty);
    expect(sent.first['props'], {'mode': 'story'});
  });

  test('nothing is queued or sent when usage statistics are off', () async {
    var called = false;
    final service = EventService()
      ..client = MockClient((req) async {
        called = true;
        return http.Response('{}', 200);
      });
    await service.init(enabled: false);
    service.log('footprint_started');
    await service.flush();
    expect(called, isFalse);
    expect(service.debugQueueLength, 0,
        reason: 'off must mean nothing is collected, not merely nothing sent');
  });

  test('turning it off mid-session drops whatever was queued', () async {
    final service = EventService()
      ..client = MockClient((req) async => http.Response('{}', 200));
    await service.init(enabled: true);
    service.log('footprint_started');
    expect(service.debugQueueLength, 1);
    service.setEnabled(false);
    expect(service.debugQueueLength, 0);
  });

  test('the install id is a v4 uuid and is stable across restarts', () async {
    final a = EventService();
    await a.init(enabled: true);
    final first = a.installId;
    final b = EventService();
    await b.init(enabled: true);
    expect(b.installId, first);
    expect(
      RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
          .hasMatch(first),
      isTrue,
      reason: 'the backend refuses anything that is not a uuid',
    );
  });

  test('a server error is recognised as a failure, not a silent success',
      () async {
    // http returns a 500 normally rather than throwing, so a bare try/catch
    // would treat it as success and this test would pass for the wrong
    // reason. The status code has to be checked.
    final service = EventService()
      ..client = MockClient((req) async => http.Response('boom', 500));
    await service.init(enabled: true);
    service.log('footprint_result');
    await service.flush();
    expect(service.lastFlushSucceeded, isFalse);
    expect(service.debugQueueLength, 0,
        reason: 'a growing queue would eventually post a month at once');
  });

  test('a thrown network error also drops the batch', () async {
    final service = EventService()
      ..client = MockClient((req) async => throw const SocketException('down'));
    await service.init(enabled: true);
    service.log('footprint_result');
    await service.flush();
    expect(service.lastFlushSucceeded, isFalse);
    expect(service.debugQueueLength, 0);
  });

  test('a 2xx is recognised as success', () async {
    final service = EventService()
      ..client =
          MockClient((req) async => http.Response('{"accepted":1}', 200));
    await service.init(enabled: true);
    service.log('footprint_result');
    await service.flush();
    expect(service.lastFlushSucceeded, isTrue);
  });

  test('the queue is capped so a loop cannot grow it without bound', () async {
    final service = EventService()
      ..client = MockClient((req) async => http.Response('{}', 200));
    await service.init(enabled: true);
    for (var i = 0; i < 200; i++) {
      service.log('footprint_chapter', props: {'index': i});
    }
    expect(service.debugQueueLength, lessThanOrEqualTo(50),
        reason: 'the backend rejects a batch over fifty');
  });

  test('flushing an empty queue makes no request', () async {
    var called = false;
    final service = EventService()
      ..client = MockClient((req) async {
        called = true;
        return http.Response('{}', 200);
      });
    await service.init(enabled: true);
    await service.flush();
    expect(called, isFalse);
  });
}
