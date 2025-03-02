import 'package:flutter/material.dart';
import 'package:time_table/constants.dart';
import 'package:time_table/domain/models/user.dart';
import 'package:time_table/presentation/widgets/animated_tab_bar_for_user.dart';
import 'package:time_table/presentation/widgets/day_schedule_view_for_user.dart';
import 'package:time_table/presentation/widgets/add_schedule_bottom_sheet.dart';
import 'alarm_settings_screen.dart';
import 'package:time_table/data/services/alarm_scheduler.dart';

class TimetableScreen extends StatefulWidget {
  final User user;
  TimetableScreen({required this.user});
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  // 예시: 화면 시작 시 오늘의 알람을 예약하도록 호출
  @override
  void initState() {
    super.initState();
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
                final newAlarmOffset = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlarmSettingsScreen(userId: widget.user.id!),
                  ),
                );
                // 사용자가 알람 오프셋을 변경하면 알람 예약을 다시 호출
                if (newAlarmOffset != null) {
                  scheduleAlarmsForToday(widget.user.id!);
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
