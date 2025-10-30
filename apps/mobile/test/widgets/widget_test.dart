import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/main.dart';

void main() {
  testWidgets('App should display login screen on startup', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const CampusMeshApp());

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that login screen elements are present
    expect(find.text('RPI Communication'), findsOneWidget);
    expect(find.text('Rangpur Government Polytechnic Institute'), findsOneWidget);
  });

  testWidgets('App should show loading indicator initially', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const CampusMeshApp());

    // Initially should show a progress indicator while checking auth state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('App should use Material Design 3', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const CampusMeshApp());

    // Get the MaterialApp widget
    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify Material Design 3 is enabled
    expect(app.theme?.useMaterial3, true);
  });
}
