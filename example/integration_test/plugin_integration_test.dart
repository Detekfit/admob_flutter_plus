// Basic integration test for admob_flutter_plus.
//
// Runs on a device/emulator and exercises the native SDK version call.
// See https://flutter.dev/to/integration-testing

import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getVersion returns a non-empty string', (tester) async {
    final version = await MobileAds.instance.getVersion();
    expect(version.isNotEmpty, true);
  });
}
