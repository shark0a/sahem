import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/injection.dart';

import 'core/services/notification_service.dart';
import 'sahem_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 1. Init DI — handles Hive inside, registers all lazy singletons
  await configureDependencies();

  // 2. Init Notifications + schedule daily meal reminders
  await sl<NotificationService>().init();
  await sl<NotificationService>().scheduleMealNotifications();

  runApp(const SahemApp());
}
