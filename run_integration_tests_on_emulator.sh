#!/bin/bash
flutter test integration_test/ --flavor full -d emulator-5554
flutter test integration_test/ --flavor lite -d emulator-5554
