// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/medication_model.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  // --------------------------------------------------
  // 복약 알림 예약
  // --------------------------------------------------
  static Future<void> scheduleMedReminder(Medication med) async {
    await init();
    final scheduled = tz.TZDateTime.from(med.scheduledAt, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      med.id.hashCode,
      '💊 복약 시간입니다',
      '${med.timeLabel} 약(${med.name})을 드실 시간이에요.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminder',
          '복약 알림',
          channelDescription: '복약 시간 알림',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 미복약 경고 알림 (1시간 후)
  static Future<void> scheduleOverdueAlert(Medication med) async {
    await init();
    final alertTime = tz.TZDateTime.from(
      med.scheduledAt.add(const Duration(hours: 1)), tz.local);
    if (alertTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      med.id.hashCode + 1000000,
      '⚠️ 복약 확인이 필요합니다',
      '${med.timeLabel} 약(${med.name}) 복용 여부를 확인해 주세요.',
      alertTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_overdue',
          '미복약 경고',
          channelDescription: '미복약 경고 알림',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 특정 알림 취소 (복약 완료 시 호출)
  static Future<void> cancelReminder(String medId) async {
    await _plugin.cancel(medId.hashCode);
    await _plugin.cancel(medId.hashCode + 1000000);
  }

  // 모든 알림 취소
  static Future<void> cancelAll() => _plugin.cancelAll();
}
