import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sahem/core/constants/app_strings.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final notificationPlugin = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await notificationPlugin.initialize(initSettings);

    String title;
    String body;
    int id;

    switch (task) {
      case AppStrings.workBreakfast:
        title = AppStrings.breakfastNotificationTitle;
        body = AppStrings.breakfastNotificationBody;
        id = 1;
        break;
      case AppStrings.workLunch:
        title = AppStrings.lunchNotificationTitle;
        body = AppStrings.lunchNotificationBody;
        id = 2;
        break;
      case AppStrings.workDinner:
        title = AppStrings.dinnerNotificationTitle;
        body = AppStrings.dinnerNotificationBody;
        id = 3;
        break;
      default:
        return Future.value(true);
    }

    await notificationPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppStrings.notificationChannelId,
          AppStrings.notificationChannelName,
          channelDescription: AppStrings.notificationChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          // color: Color(0xFFF4A226),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    return Future.value(true);
  });
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 13+ permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigate to home or specific recipe — handled via GoRouter
  }

  Future<void> scheduleMealNotifications() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    // Breakfast at 08:00 — daily periodic
    await Workmanager().registerPeriodicTask(
      AppStrings.workBreakfast,
      AppStrings.workBreakfast,
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntil(hour: 8),
      constraints: Constraints(networkType: NetworkType.not_required),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    // Lunch at 14:00 — daily periodic
    await Workmanager().registerPeriodicTask(
      AppStrings.workLunch,
      AppStrings.workLunch,
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntil(hour: 14),
      constraints: Constraints(networkType: NetworkType.not_required),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    // Dinner at 19:00 — daily periodic
    await Workmanager().registerPeriodicTask(
      AppStrings.workDinner,
      AppStrings.workDinner,
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntil(hour: 19),
      constraints: Constraints(networkType: NetworkType.not_required),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Calculates the delay from now until the next occurrence of [hour]:00
  Duration _delayUntil({required int hour}) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, 0);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(now);
  }
}

// Needed for Android color reference in background isolate
class Color {
  final int value;
  const Color(this.value);
}
