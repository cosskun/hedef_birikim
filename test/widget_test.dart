import 'package:flutter_test/flutter_test.dart';
import 'package:hedef_birikim/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Basic test to ensure HedefBirikimApp mounts properly
    await tester.pumpWidget(const HedefBirikimApp());
    expect(find.byType(HedefBirikimApp), findsOneWidget);
  });
}
