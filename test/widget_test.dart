import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahem/core/di/injection.dart';
import 'package:sahem/core/services/notification_service.dart';
import 'package:sahem/sahem_app.dart';

void main() {
  testWidgets('App smoke test - verifies app starts without crashing', (WidgetTester tester) async {
    // Initialize dependencies
    await configureDependencies();
    await sl<NotificationService>().init();

    // Build our app.
    await tester.pumpWidget(const SahemApp());

    // Verify app builds without errors - at least one widget should be present
    expect(find.byType(SahemApp), findsOneWidget);
  });
}
