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

  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  String today = globalDays[now.weekday - 1];

  // 오늘 요일에 해당하는 스케줄 조회
  List<Map<String, dynamic>> rows = await DatabaseHelper.instance.querySchedulesByDay(userId, today);
  List<ScheduleData> schedules = rows.map((row) => ScheduleData.fromMap(row)).toList();

  // 사용자 알람 오프셋(분) 조회 (기본값 20분)
  int alarmOffset = await DatabaseHelper.instance.getAlarmOffset(userId);

  for (var schedule in schedules) {
    // 종료시간을 오늘 날짜로 계산 (Asia/Seoul 기준)
    final tz.TZDateTime endTime = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, schedule.endHour, schedule.endMinute);
    // 알람 예약 시간은 오프셋이 0이면 종료시간 그대로, 아니면 종료시간에서 오프셋을 뺀 시간
    final tz.TZDateTime alarmTime = (alarmOffset == 0)
        ? endTime
        : endTime.subtract(Duration(minutes: alarmOffset));

    // 예약 시간이 현재 시간 이후라면 알람 예약
    if (alarmTime.isAfter(now)) {
      await NotificationService().scheduleAlarm(
        id: schedule.id ?? schedule.order,
        title: schedule.title,
        body: (alarmOffset == 0)
            ? "종료시간에 알람이 울립니다. 스케줄 테이블에서 '${schedule.title}'을(를) 확인하세요."
            : "종료 ${alarmOffset}분 전입니다. 스케줄 테이블에서 '${schedule.title}'을(를) 확인하세요.",
        scheduledDate: alarmTime.toLocal(),
      );
    }
  }
}
