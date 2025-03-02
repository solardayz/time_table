import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:time_table/constants.dart';
import 'package:time_table/domain/models/user.dart';
import 'package:time_table/presentation/screens/request_notification_permission_screen.dart';
import 'package:time_table/presentation/widgets/animated_tab_bar_for_user.dart';
import 'package:time_table/presentation/widgets/day_schedule_view_for_user.dart';
import 'package:time_table/presentation/widgets/add_schedule_bottom_sheet.dart';
import 'alarm_settings_screen.dart';
import 'package:time_table/data/services/alarm_scheduler.dart'; // 알람 예약 로직

class TimetableScreen extends StatefulWidget {
  final User user;
  TimetableScreen({required this.user});
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 시 오늘의 알람 예약(필요에 따라 호출)
    scheduleAlarmsForToday(widget.user.id!);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: globalDays.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.user.name}의 시간표"),
          actions: [
            IconButton(
              icon: Icon(Icons.alarm),
              onPressed: () async {
                bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
                if (!isAllowed) {
                  // 알림 권한이 없으면 권한 요청 화면으로 이동
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestNotificationPermissionScreen(),
                    ),
                  );
                } else {
                  // 알림 권한이 있으면 알람 설정 화면으로 이동
                  final newAlarmOffset = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlarmSettingsScreen(userId: widget.user.id!),
                    ),
                  );
                  if (newAlarmOffset != null) {
                    // 사용자가 설정한 값에 따라 알람 재예약
                    print('새 알람 오프셋: $newAlarmOffset 분 전');
                    await scheduleAlarmsForToday(widget.user.id!);
                  }
                }
              },
            )
          ],
          bottom: AnimatedTabBarForUser(),
        ),
        body: TabBarView(
          children: globalDays
              .map((day) => DayScheduleViewForUser(day: day, userId: widget.user.id!))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => AddScheduleBottomSheet(userId: widget.user.id!),
            ).then((_) {
              setState(() {});
            });
          },
        ),
      ),
    );
  }
}
