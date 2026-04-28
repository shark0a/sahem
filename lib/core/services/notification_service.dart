import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/app_strings.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    DartPluginRegistrant.ensureInitialized();

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    final notification = _notificationForTask(task);
    if (notification == null) {
      return true;
    }

    await plugin.show(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      notificationDetails: _details(),
      payload: notification.payload,
    );

    return true;
  });
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _workmanagerInitialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleMealNotifications() async {
    if (!_workmanagerInitialized) {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      _workmanagerInitialized = true;
    }

    await _registerTask(
      uniqueName: AppStrings.workBreakfast,
      taskName: AppStrings.workBreakfast,
      hour: 8,
    );
    await _registerTask(
      uniqueName: AppStrings.workLunch,
      taskName: AppStrings.workLunch,
      hour: 14,
    );
    await _registerTask(
      uniqueName: AppStrings.workDinner,
      taskName: AppStrings.workDinner,
      hour: 19,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Hook router navigation here if needed.
  }

  Future<void> _registerTask({
    required String uniqueName,
    required String taskName,
    required int hour,
  }) async {
    await Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntil(hour),
      constraints: Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  Duration _delayUntil(int hour) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, 0);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(now);
  }
}

class _MealNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  const _MealNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

_MealNotification? _notificationForTask(String task) {
  switch (task) {
    case AppStrings.workBreakfast:
      return const _MealNotification(
        id: 1,
        title: AppStrings.breakfastNotificationTitle,
        body: AppStrings.breakfastNotificationBody,
        payload: 'breakfast',
      );
    case AppStrings.workLunch:
      return const _MealNotification(
        id: 2,
        title: AppStrings.lunchNotificationTitle,
        body: AppStrings.lunchNotificationBody,
        payload: 'lunch',
      );
    case AppStrings.workDinner:
      return const _MealNotification(
        id: 3,
        title: AppStrings.dinnerNotificationTitle,
        body: AppStrings.dinnerNotificationBody,
        payload: 'dinner',
      );
    default:
      return null;
  }
}

NotificationDetails _details() {
  return const NotificationDetails(
    android: AndroidNotificationDetails(
      AppStrings.notificationChannelId,
      AppStrings.notificationChannelName,
      channelDescription: AppStrings.notificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
}
