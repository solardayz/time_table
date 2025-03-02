import 'package:flutter/material.dart';
import 'package:time_table/data/database_helper.dart';
import 'package:time_table/domain/models/schedule_data.dart';
import 'package:time_table/presentation/widgets/timetable_item.dart';
import 'package:time_table/presentation/widgets/edit_schedule_bottom_sheet.dart';

class DayScheduleViewForUser extends StatefulWidget {
  final String day;
  final int userId;
  DayScheduleViewForUser({required this.day, required this.userId});
  @override
  _DayScheduleViewForUserState createState() => _DayScheduleViewForUserState();
}

class _DayScheduleViewForUserState extends State<DayScheduleViewForUser> {
  Future<List<ScheduleData>> _fetchSchedules() async {
    final rows = await DatabaseHelper.instance.querySchedulesByDay(widget.userId, widget.day);
    final schedules = rows.map((row) => ScheduleData.fromMap(row)).toList();
    schedules.sort((a, b) => a.order.compareTo(b.order));
    return schedules;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScheduleData>>(
      future: _fetchSchedules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));

        final schedules = snapshot.data ?? [];
        return ReorderableListView(
          padding: EdgeInsets.all(16.0),
          onReorder: (oldIndex, newIndex) async {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = schedules.removeAt(oldIndex);
              schedules.insert(newIndex, item);
              for (int i = 0; i < schedules.length; i++) {
                schedules[i].order = i + 1;
                if (schedules[i].id != null) {
                  DatabaseHelper.instance.updateScheduleOrder(schedules[i].id!, i + 1);
                }
              }
            });
          },
          children: [
            for (int i = 0; i < schedules.length; i++)
              Container(
                key: ValueKey(schedules[i].id),
                child: TimeTableItem(
                  startHour: schedules[i].startHour,
                  startMinute: schedules[i].startMinute,
                  title: schedules[i].title,
                  endHour: schedules[i].endHour,
                  endMinute: schedules[i].endMinute,
                  note: schedules[i].note,
                  onDelete: () async {
                    bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("삭제하시겠습니까?"),
                        content: Text("해당 스케줄을 삭제하시겠습니까?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("아니요")),
                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("예")),
                        ],
                      ),
                    );
                    if (confirm && schedules[i].id != null) {
                      await DatabaseHelper.instance.deleteSchedule(schedules[i].id!);
                      setState(() {});
                    }
                  },
                  onEdit: () async {
                    // 수정 다이얼로그(또는 BottomSheet) 호출
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => EditScheduleBottomSheet(schedule: schedules[i]),
                    );
                    setState(() {}); // 수정 후 갱신
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
