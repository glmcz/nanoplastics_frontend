#!/bin/bash
flutter test integration_test/ --flavor full -d emulator-5554
# `flutter test integration_test/ -d <device>` installs and launches but never
# attaches. Drive each target instead.
for t in integration_test/*_test.dart; do
  flutter drive --driver=test_driver/integration_test.dart --target="$t" \
    --flavor full -d emulator-5554 --profile --keep-app-running || exit 1
done
