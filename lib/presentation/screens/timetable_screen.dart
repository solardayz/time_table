import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:time_table/constants.dart';
import 'package:time_table/domain/models/user.dart';
import 'package:time_table/presentation/screens/request_notification_permission_screen.dart';
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
  @override
  void initState() {
    super.initState();
    scheduleAlarmsForToday(widget.user.id!);
  }

  @override
  Widget build(BuildContext context) {
    final pastelBackgrounds = [
      [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
      [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
      [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
      [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
    ];
    final dateSeed = DateTime.now().weekday + widget.user.id!;
    final gradient = pastelBackgrounds[dateSeed % pastelBackgrounds.length];

    return DefaultTabController(
      length: globalDays.length,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text("${widget.user.name}의 시간표", style: TextStyle(color: Colors.black87)),
            actions: [
              IconButton(
                icon: Icon(Icons.alarm, color: Colors.black87),
                onPressed: () async {
                  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
                  if (!isAllowed) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestNotificationPermissionScreen(),
                      ),
                    );
                  } else {
                    final newAlarmOffset = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlarmSettingsScreen(userId: widget.user.id!),
                      ),
                    );
                    if (newAlarmOffset != null) {
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
            backgroundColor: Colors.deepPurpleAccent,
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
      ),
    );
  }
}