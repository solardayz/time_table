import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      'resource://mipmap/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'alarm_channel',
          channelName: '알람 채널',
          channelDescription: '스케줄 알람 채널',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          channelShowBadge: true,
        )
      ],
      debug: true,
    );

    // 알림 권한 확인 및 요청
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // 사용자가 거부했거나 아직 요청하지 않은 경우 권한 요청
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'alarm_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  Future<void> cancelAlarm(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAllAlarms() async {
    await AwesomeNotifications().cancelAll();
  }
}
