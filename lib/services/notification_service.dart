import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _permissionsGranted = false;

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('America/New_York'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request notification permission on Android 13+ (API 33+)
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      _permissionsGranted = granted ?? false;
      debugPrint('🔔 Notification permission: $_permissionsGranted');
    }
  }

  /// Request exact alarm permission — call from a user-triggered action (e.g. settings)
  static Future<void> requestExactAlarmPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  static Future<void> showInstant({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'lifeflow_instant_v2',
        'Instant Notifications',
        channelDescription: 'LifeFlow instant notifications',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      ),
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool isAlarm = false,
  }) async {
    try {
      // Convert to TZDateTime and ensure it's in the future
      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);
      final now = tz.TZDateTime.now(tz.local);
      if (!tzScheduled.isAfter(now)) {
        debugPrint('⚠️ Skipping "$title" — time $tzScheduled is not in the future');
        return;
      }

      final androidDetails = AndroidNotificationDetails(
        isAlarm ? 'lifeflow_alarm_v2' : 'lifeflow_reminders_v2',
        isAlarm ? 'Deadline Alarms' : 'Task Reminders',
        channelDescription: isAlarm
            ? 'Alarm notifications for deadlines'
            : 'Scheduled task reminders',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        fullScreenIntent: isAlarm,
        category: isAlarm ? AndroidNotificationCategory.alarm : null,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        autoCancel: true,
      );

      final details = NotificationDetails(android: androidDetails);

      debugPrint('📅 Scheduling id=$id "$title" at $tzScheduled');

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('✅ Scheduled id=$id OK');
    } catch (e) {
      debugPrint('❌ Failed to schedule notification id=$id: $e');
    }
  }

  /// Schedule goal notifications: 1 day before, 1 hour before, 10 min before, and at deadline
  static Future<void> scheduleGoalNotifications({
    required String goalId,
    required String goalTitle,
    required DateTime targetDate,
  }) async {
    final baseId = goalId.hashCode.abs() % 100000;
    final now = DateTime.now();

    // 1 day before
    final oneDayBefore = targetDate.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(now)) {
      await scheduleNotification(
        id: baseId,
        title: '📅 Goal Reminder',
        body: '"$goalTitle" deadline is tomorrow!',
        scheduledDate: oneDayBefore,
        payload: 'goal_$goalId',
      );
    }

    // 1 hour before
    final oneHourBefore = targetDate.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(now)) {
      await scheduleNotification(
        id: baseId + 1,
        title: '⏰ Goal Deadline Approaching',
        body: '"$goalTitle" is due in 1 hour!',
        scheduledDate: oneHourBefore,
        payload: 'goal_$goalId',
      );
    }

    // 10 minutes before
    final tenMinBefore = targetDate.subtract(const Duration(minutes: 10));
    if (tenMinBefore.isAfter(now)) {
      await scheduleNotification(
        id: baseId + 2,
        title: '🚨 Goal Almost Due!',
        body: '"$goalTitle" deadline in 10 minutes!',
        scheduledDate: tenMinBefore,
        payload: 'goal_$goalId',
      );
    }

    // At exact deadline — alarm-like
    if (targetDate.isAfter(now)) {
      await scheduleNotification(
        id: baseId + 3,
        title: '🔔 DEADLINE REACHED',
        body: '"$goalTitle" deadline is NOW!',
        scheduledDate: targetDate,
        payload: 'goal_$goalId',
        isAlarm: true,
      );
    }
  }

  static Future<void> cancelGoalNotifications(String goalId) async {
    final baseId = goalId.hashCode.abs() % 100000;
    for (int i = 0; i < 4; i++) {
      await _plugin.cancel(baseId + i);
    }
  }

  static Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    final id = taskId.hashCode.abs() % 100000 + 10000;
    final now = DateTime.now();

    // 30 minutes before
    final thirtyMinBefore = deadline.subtract(const Duration(minutes: 30));
    if (thirtyMinBefore.isAfter(now)) {
      await scheduleNotification(
        id: id,
        title: '📋 Task Reminder',
        body: '"$taskTitle" is due in 30 minutes',
        scheduledDate: thirtyMinBefore,
        payload: 'task_$taskId',
      );
    }

    // 5 minutes before
    final fiveMinBefore = deadline.subtract(const Duration(minutes: 5));
    if (fiveMinBefore.isAfter(now)) {
      await scheduleNotification(
        id: id + 1,
        title: '🚨 Task Almost Due!',
        body: '"$taskTitle" is due in 5 minutes!',
        scheduledDate: fiveMinBefore,
        payload: 'task_$taskId',
      );
    }

    // At exact deadline — alarm style
    if (deadline.isAfter(now)) {
      await scheduleNotification(
        id: id + 2,
        title: '⏰ Task Due Now!',
        body: '"$taskTitle" deadline reached!',
        scheduledDate: deadline,
        payload: 'task_$taskId',
        isAlarm: true,
      );
    }
  }

  static Future<void> cancelTaskNotifications(String taskId) async {
    final id = taskId.hashCode.abs() % 100000 + 10000;
    await _plugin.cancel(id);
    await _plugin.cancel(id + 1);
    await _plugin.cancel(id + 2);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Test notification — fires in 5 seconds to verify the system works
  static Future<void> testScheduledNotification() async {
    final testTime = DateTime.now().add(const Duration(seconds: 5));
    await scheduleNotification(
      id: 888888,
      title: '🔔 Test Notification',
      body: 'If you see this, scheduled notifications are working!',
      scheduledDate: testTime,
    );
  }

  /// Get list of pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>> getPending() async {
    return await _plugin.pendingNotificationRequests();
  }
}
