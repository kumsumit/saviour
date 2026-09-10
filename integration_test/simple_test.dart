import 'package:flutter_test/flutter_test.dart';
import 'package:saviour/services/saviour_api.dart';
import 'package:saviour/src/rust/api/simple.dart';
import 'package:saviour/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => RustLib.init());
  testWidgets('Rust bridge is available', (_) async {
    expect(greet(name: 'Tom'), 'Hello, Tom!');
  });
  testWidgets('QUIC server health', (_) async {
    final health = await SaviourApi.instance.health();
    expect(health['status'], 'ok');
  }, skip: !const bool.fromEnvironment('SAVIOUR_LIVE_TEST'));
}
