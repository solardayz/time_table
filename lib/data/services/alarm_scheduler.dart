import 'package:time_table/constants.dart';
import 'package:time_table/domain/models/schedule_data.dart';
import 'package:time_table/data/database_helper.dart';
import 'package:time_table/data/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleAlarmsForToday(int userId) async {
  DateTime now = DateTime.now();
  // globalDays[0] = '월', globalDays[1] = '화', ...; DateTime.weekday: Monday=1, ...
  String today = globalDays[now.weekday - 1];

  // 오늘 요일에 해당하는 스케줄 조회
  List<Map<String, dynamic>> rows = await DatabaseHelper.instance.querySchedulesByDay(userId, today);
  List<ScheduleData> schedules = rows.map((row) => ScheduleData.fromMap(row)).toList();

  // 해당 사용자의 알람 오프셋(분) 조회 (기본 20분)
  int alarmOffset = await DatabaseHelper.instance.getAlarmOffset(userId);

  for (var schedule in schedules) {
    // 종료시간을 오늘 날짜로 계산 (실제 스케줄 날짜에 따라 조정 필요)
    DateTime endTime = DateTime(now.year, now.month, now.day, schedule.endHour, schedule.endMinute);
    // 알람 예약 시간은 종료 20분(또는 사용자 지정 분 전)
    DateTime alarmTime = endTime.subtract(Duration(minutes: alarmOffset));

    // 예약 시간이 현재 시간 이후라면 알림 예약
    if (alarmTime.isAfter(now)) {
      await NotificationService().scheduleAlarm(
        id: schedule.id ?? schedule.order,  // 고유 id로 사용 (필요에 따라 관리)
        title: "${schedule.title} 알람",
        body: "종료 $alarmOffset분 전입니다.",
        scheduledDate: alarmTime,
      );
    }
  }
}
