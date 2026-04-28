import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sahem/core/di/injection.dart';
import 'package:sahem/core/router/app_router.dart';
import 'package:sahem/sahem_app.dart';

void main() {
  testWidgets('App smoke test - verifies app starts without crashing',
      (WidgetTester tester) async {
    // Ensure Flutter binding is initialized before any async work
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive (required for DI) but skip opening boxes to avoid
    // file I/O in tests which can hang in FakeAsync zone
    await Hive.initFlutter();

    // Register only what's strictly necessary for the app to build
    if (!sl.isRegistered<HiveInterface>()) {
      sl.registerSingleton<HiveInterface>(Hive);
    }

    // Register AppRouter as lazy singleton - it will be created when needed
    if (!sl.isRegistered<AppRouter>()) {
      sl.registerLazySingleton<AppRouter>(AppRouter.new);
    }

    // Build our app.
    await tester.pumpWidget(const SahemApp());

    // Verify app builds without errors - at least one widget should be present
    expect(find.byType(SahemApp), findsOneWidget);
  });
}
