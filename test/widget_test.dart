import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saviour/main.dart';

void main() {
  testWidgets('shows the login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: VitalReserveApp()));

    expect(find.text('Vital Reserve'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.text('Register as a new donor'), findsOneWidget);
  });
}
