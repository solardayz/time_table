import 'package:flutter/material.dart';
import 'package:time_table/domain/models/user.dart';
import 'package:time_table/presentation/widgets/animated_tab_bar_for_user.dart';
import 'package:time_table/presentation/widgets/day_schedule_view_for_user.dart';
import 'package:time_table/presentation/widgets/add_schedule_bottom_sheet.dart';

import '../../constants.dart';

class TimetableScreen extends StatefulWidget {
  final User user;
  TimetableScreen({required this.user});
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: globalDays.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.user.name}의 시간표"),
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
