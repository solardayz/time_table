import 'package:time_table/constants.dart';
import 'package:time_table/domain/models/schedule_data.dart';
import 'package:time_table/data/database_helper.dart';
import 'package:time_table/data/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;

Future<void> scheduleAlarmsForToday(int userId) async {
  // 타임존 초기화 (앱 시작 시 한 번만 호출하면 됩니다)
  tzData.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  // 오늘 날짜를 tz.TZDateTime으로 계산
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  String today = globalDays[now.weekday - 1]; // globalDays: ['월','화','수','목','금','토','일']
  print("[ALARM_CHECK_LOG] Today: $today, Now: $now");

  // 오늘 요일에 해당하는 스케줄 조회
  List<Map<String, dynamic>> rows =
  await DatabaseHelper.instance.querySchedulesByDay(userId, today);
  List<ScheduleData> schedules =
  rows.map((row) => ScheduleData.fromMap(row)).toList();

  // DB에서 사용자 알람 오프셋(분) 조회 (기본값은 20분)
  int alarmOffset = await DatabaseHelper.instance.getAlarmOffset(userId);
  print("[ALARM_CHECK_LOG] User Alarm Offset: $alarmOffset minutes");

  for (var schedule in schedules) {
    // 종료시간을 오늘 날짜로 계산 (Asia/Seoul 기준)
    final tz.TZDateTime endTime = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, schedule.endHour, schedule.endMinute);
    // 예약할 알람 시간은 종료시간에서 오프셋(분)을 뺀 값
    final tz.TZDateTime computedAlarmTime =
    endTime.subtract(Duration(minutes: alarmOffset));
    print("[ALARM_CHECK_LOG] Schedule '${schedule.title}': endTime = $endTime, computed alarmTime = $computedAlarmTime");

    // 예약 시간이 현재 시간 이후라면 예약
    if (computedAlarmTime.isAfter(now)) {
      await NotificationService().scheduleAlarm(
        id: schedule.id ?? schedule.order,
        title: "${schedule.title} 알람",
        body: (alarmOffset == 0)
            ? "종료 시간에 알람이 울립니다."
            : "종료 $alarmOffset분 전 알람입니다.",
        scheduledDate: (alarmOffset == 0)
            ? endTime.toLocal()
            : computedAlarmTime.toLocal(),
      );
      print("[ALARM_CHECK_LOG] Alarm scheduled for '${schedule.title}' at ${(alarmOffset == 0) ? endTime : computedAlarmTime}");
    } else {
      // 예약 시간이 과거라면 알람 예약 안 함.
      print("[ALARM_CHECK_LOG] No alarm scheduled for '${schedule.title}' because computed alarmTime $computedAlarmTime is not after now ($now)");
    }
  }
}
