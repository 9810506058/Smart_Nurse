import 'package:flutter_test/flutter_test.dart';
import 'package:smartnurse/main.dart';

void main() {
  testWidgets('Nurse Dashboard loads and navigation works', (
    WidgetTester tester,
  ) async {
    // Load the app
    await tester.pumpWidget(NursePatientManagementApp());

    // Verify "Nurse Dashboard" is displayed
    expect(find.text('Nurse Dashboard'), findsOneWidget);

    // Tap the "Add Patient" button
    await tester.tap(find.text('Add Patient'));
    await tester.pumpAndSettle();

    // Verify navigation to "Add Patient" screen
    expect(find.text('Add Patient'), findsWidgets);
  });
}
