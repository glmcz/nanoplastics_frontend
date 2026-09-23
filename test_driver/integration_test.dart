import 'package:integration_test/integration_test_driver.dart';

// `flutter test integration_test/… -d <device>` installs and launches the app
// but never attaches — the run sits at "+0: loading" forever. Driving it is the
// only way these run on a physical phone:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/<file>.dart -d <device> --profile
Future<void> main() => integrationDriver();
