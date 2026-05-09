import 'package:flutter_test/flutter_test.dart';
import 'package:snapbooth_mobile/main.dart';

void main() {
  testWidgets('Home page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SnapBoothApp());

    // Verify that our home page text exists.
    expect(find.text('Welcome to SnapBooth'), findsOneWidget);
    expect(find.text('Enter Booth'), findsOneWidget);
  });
}
