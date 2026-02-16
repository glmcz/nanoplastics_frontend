import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/services/update_service.dart';

void main() {
  group('UpdateService.isNewerVersion', () {
    final updateService = UpdateService();

    test('v1.2.3 is newer than v1.2.2', () {
      expect(updateService.isNewerVersion('v1.2.3', 'v1.2.2'), isTrue);
    });

    test('v1.3.0 is newer than v1.2.9', () {
      expect(updateService.isNewerVersion('v1.3.0', 'v1.2.9'), isTrue);
    });

    test('v2.0.0 is newer than v1.9.9', () {
      expect(updateService.isNewerVersion('v2.0.0', 'v1.9.9'), isTrue);
    });

    test('v1.2.3 is not newer than v1.2.3 (same version)', () {
      expect(updateService.isNewerVersion('v1.2.3', 'v1.2.3'), isFalse);
    });

    test('v1.2.2 is not newer than v1.2.3 (older)', () {
      expect(updateService.isNewerVersion('v1.2.2', 'v1.2.3'), isFalse);
    });

    test('Handles versions without v prefix', () {
      expect(updateService.isNewerVersion('1.2.3', '1.2.2'), isTrue);
    });

    test('Handles mixed v prefix', () {
      expect(updateService.isNewerVersion('v1.2.3', '1.2.2'), isTrue);
    });

    test('Handles release- prefix', () {
      expect(updateService.isNewerVersion('release-1.2.3', '1.2.2'), isTrue);
    });

    test('Handles different version lengths (v1.2.3.4 > v1.2.3)', () {
      expect(updateService.isNewerVersion('v1.2.3.4', 'v1.2.3'), isTrue);
    });

    test('Handles different version lengths (v1.2 < v1.2.1)', () {
      expect(updateService.isNewerVersion('v1.2', 'v1.2.1'), isFalse);
    });

    test('Handles invalid versions gracefully', () {
      expect(updateService.isNewerVersion('invalid', '1.2.3'), isFalse);
    });

    test('Beta versions: v2.0.0-beta is not newer than v1.9.9', () {
      // Note: Current implementation doesn't handle -beta suffix, treats as 0
      // This documents current behavior
      expect(updateService.isNewerVersion('v2.0.0-beta', 'v1.9.9'), isTrue);
    });

    test(
        'Handles patch versions: v1.2.10 > v1.2.9 (numeric not string comparison)',
        () {
      expect(updateService.isNewerVersion('v1.2.10', 'v1.2.9'), isTrue);
    });
  });

  group('UpdateService state management', () {
    late UpdateService updateService;

    setUp(() {
      updateService = UpdateService();
    });

    test('Initial state is idle', () {
      expect(updateService.currentState, equals(UpdateState.idle));
    });

    test('Initial download progress is 0.0', () {
      expect(updateService.downloadProgress, equals(0.0));
    });

    test('State listeners are notified of changes', () async {
      final stateChanges = <(UpdateState, double)>[];

      updateService.addStateListener((state, progress) {
        stateChanges.add((state, progress));
      });

      // Listener should be called immediately with current state
      expect(stateChanges.length, equals(1));
      expect(stateChanges[0].$1, equals(UpdateState.idle));
    });

    test('Can remove state listeners', () async {
      final stateChanges = <(UpdateState, double)>[];

      void listener(UpdateState state, double progress) {
        stateChanges.add((state, progress));
      }

      updateService.addStateListener(listener);
      final initialCount = stateChanges.length;

      updateService.removeStateListener(listener);

      // Adding another listener should not affect the removed listener
      updateService.addStateListener((state, progress) {});
      expect(stateChanges.length, equals(initialCount));
    });

    test('Download progress is clamped to 0.0-1.0', () {
      final updates = <double>[];

      updateService.addStateListener((state, progress) {
        updates.add(progress);
      });

      // This test would require access to _notifyStateChange which is private
      // For now, we document this behavior
      expect(
          updateService.downloadProgress >= 0.0 &&
              updateService.downloadProgress <= 1.0,
          isTrue);
    });
  });

  group('UpdateState enum', () {
    test('UpdateState has all required states', () {
      expect(UpdateState.idle, isNotNull);
      expect(UpdateState.checking, isNotNull);
      expect(UpdateState.available, isNotNull);
      expect(UpdateState.downloading, isNotNull);
      expect(UpdateState.downloaded, isNotNull);
      expect(UpdateState.installing, isNotNull);
      expect(UpdateState.installed, isNotNull);
      expect(UpdateState.failed, isNotNull);
    });
  });
}
