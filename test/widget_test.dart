import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_attendnce_2/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
  });
}
