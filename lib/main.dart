import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

void main() {
  runApp(TimeTableApp());
}

// Global day list
const List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

// Global schedule map with time split into hours and minutes.
Map<String, List<ScheduleData>> scheduleMap = {
  '월': [
    ScheduleData(
      order: 1,
      startHour: 8,
      startMinute: 40,
      endHour: 13,
      endMinute: 40,
      title: '학교',
      note: '정규 수업',
    ),
    ScheduleData(
      order: 2,
      startHour: 14,
      startMinute: 34,
      endHour: 15,
      endMinute: 15,
      title: '구몬학습',
      note: '온라인 학습',
    ),
    ScheduleData(
      order: 3,
      startHour: 16,
      startMinute: 0,
      endHour: 18,
      endMinute: 25,
      title: '늘푸른수학',
      note: '보충 수업',
    ),
  ],
  '화': [
    ScheduleData(
      order: 1,
      startHour: 9,
      startMinute: 0,
      endHour: 10,
      endMinute: 30,
      title: '수학',
      note: '문제 풀이',
    ),
    ScheduleData(
      order: 2,
      startHour: 11,
      startMinute: 0,
      endHour: 12,
      endMinute: 0,
      title: '영어',
      note: '독해',
    ),
    ScheduleData(
      order: 3,
      startHour: 13,
      startMinute: 30,
      endHour: 15,
      endMinute: 0,
      title: '과학',
      note: '실험',
    ),
  ],
  '수': [
    ScheduleData(
      order: 1,
      startHour: 8,
      startMinute: 50,
      endHour: 10,
      endMinute: 20,
      title: '음악',
      note: '연습',
    ),
    ScheduleData(
      order: 2,
      startHour: 10,
      startMinute: 30,
      endHour: 12,
      endMinute: 0,
      title: '미술',
      note: '그림',
    ),
    ScheduleData(
      order: 3,
      startHour: 13,
      startMinute: 0,
      endHour: 14,
      endMinute: 30,
      title: '체육',
      note: '운동',
    ),
  ],
  '목': [
    ScheduleData(
      order: 1,
      startHour: 9,
      startMinute: 10,
      endHour: 10,
      endMinute: 50,
      title: '국어',
      note: '독서',
    ),
    ScheduleData(
      order: 2,
      startHour: 11,
      startMinute: 0,
      endHour: 12,
      endMinute: 30,
      title: '역사',
      note: '토론',
    ),
    ScheduleData(
      order: 3,
      startHour: 13,
      startMinute: 20,
      endHour: 15,
      endMinute: 0,
      title: '사회',
      note: '프로젝트',
    ),
  ],
  '금': [
    ScheduleData(
      order: 1,
      startHour: 8,
      startMinute: 30,
      endHour: 10,
      endMinute: 0,
      title: '수학',
      note: '복습',
    ),
    ScheduleData(
      order: 2,
      startHour: 10,
      startMinute: 10,
      endHour: 11,
      endMinute: 40,
      title: '영어',
      note: '어휘',
    ),
    ScheduleData(
      order: 3,
      startHour: 12,
      startMinute: 0,
      endHour: 13,
      endMinute: 30,
      title: '과학',
      note: '퀴즈',
    ),
  ],
  '토': [
    ScheduleData(
      order: 1,
      startHour: 10,
      startMinute: 0,
      endHour: 12,
      endMinute: 0,
      title: '미술',
      note: '자유 활동',
    ),
    ScheduleData(
      order: 2,
      startHour: 13,
      startMinute: 0,
      endHour: 15,
      endMinute: 0,
      title: '체육',
      note: '축구',
    ),
  ],
  '일': [
    ScheduleData(
      order: 1,
      startHour: 11,
      startMinute: 0,
      endHour: 12,
      endMinute: 30,
      title: '독서',
      note: '자기계발',
    ),
    ScheduleData(
      order: 2,
      startHour: 14,
      startMinute: 0,
      endHour: 16,
      endMinute: 0,
      title: '영화',
      note: '가족과 함께',
    ),
  ],
};

class TimeTableApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '타임테이블 앱',
      home: TimeTableHome(),
    );
  }
}

// Main screen that uses setState to update the UI when schedules change.
class TimeTableHome extends StatefulWidget {
  @override
  _TimeTableHomeState createState() => _TimeTableHomeState();
}

class _TimeTableHomeState extends State<TimeTableHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('타임테이블'),
          bottom: AnimatedTabBar(),
        ),
        body: TabBarView(
          // Create each day view using the day string.
          children: days.map<Widget>((day) => DayScheduleView(day: day)).toList(),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                // Show bottom sheet and refresh UI after it's closed.
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return AddScheduleBottomSheet();
                  },
                ).then((_) {
                  setState(() {});
                });
              },
            );
          },
        ),
      ),
    );
  }
}

/// AnimatedTabBar: Displays day tabs with animated text size.
class AnimatedTabBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(48.0);
  @override
  Widget build(BuildContext context) {
    final TabController tabController = DefaultTabController.of(context)!;
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return TabBar(
          indicatorColor: Colors.red,
          tabs: List.generate(days.length, (index) {
            bool selected = tabController.index == index;
            return Tab(
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: selected
                    ? TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)
                    : TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black54),
                child: Text(days[index]),
              ),
            );
          }),
        );
      },
    );
  }
}

/// ScheduleData model (with time split into hours and minutes and an order field).
class ScheduleData {
  int order;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String title;
  final String note;

  ScheduleData({
    required this.order,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.title,
    this.note = '',
  });
}

/// DayScheduleView: Displays schedules for a day in a reorderable list.
class DayScheduleView extends StatefulWidget {
  final String day;
  DayScheduleView({required this.day});
  @override
  _DayScheduleViewState createState() => _DayScheduleViewState();
}

class _DayScheduleViewState extends State<DayScheduleView> {
  @override
  Widget build(BuildContext context) {
    // Always compute the sorted schedules from the global map.
    List<ScheduleData> sortedSchedules = List<ScheduleData>.from(scheduleMap[widget.day] ?? []);
    sortedSchedules.sort((a, b) => a.order.compareTo(b.order));
    return ReorderableListView(
      padding: EdgeInsets.all(16.0),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = sortedSchedules.removeAt(oldIndex);
          sortedSchedules.insert(newIndex, item);
          for (int i = 0; i < sortedSchedules.length; i++) {
            sortedSchedules[i].order = i + 1;
          }
          scheduleMap[widget.day] = sortedSchedules;
        });
      },
      children: [
        for (int i = 0; i < sortedSchedules.length; i++)
          Container(
            key: ValueKey(sortedSchedules[i].order),
            child: TimeTableItem(
              startHour: sortedSchedules[i].startHour,
              startMinute: sortedSchedules[i].startMinute,
              title: sortedSchedules[i].title,
              endHour: sortedSchedules[i].endHour,
              endMinute: sortedSchedules[i].endMinute,
              note: sortedSchedules[i].note,
            ),
          ),
      ],
    );
  }
}

/// TimeTableItem: UI for a schedule item with formatted time and right-aligned note.
class TimeTableItem extends StatelessWidget {
  final int startHour;
  final int startMinute;
  final String title;
  final int endHour;
  final int endMinute;
  final String note;

  TimeTableItem({
    required this.startHour,
    required this.startMinute,
    required this.title,
    required this.endHour,
    required this.endMinute,
    required this.note,
  });

  String formatTime(int hour, int minute) {
    return hour.toString().padLeft(2, '0') + ":" + minute.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final Color customBorderColor = Colors.deepPurpleAccent;
    final Color customBackgroundColor = Colors.white;
    final Color customStartTimeColor = Colors.blue;
    final Color customSubjectColor = Colors.black;
    final Color customEndTimeColor = Colors.grey;
    final Color customNoteColor = Colors.orange;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: customBackgroundColor,
        border: Border.all(color: customBorderColor, width: 2),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(color: customBorderColor.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for start time and title.
          Row(
            children: [
              Text(
                "${formatTime(startHour, startMinute)}.",
                style: TextStyle(fontSize: 22, color: customStartTimeColor, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(fontSize: 22, color: customSubjectColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          // End time.
          Text(
            formatTime(endHour, endMinute),
            style: TextStyle(fontSize: 14, color: customEndTimeColor),
          ),
          SizedBox(height: 8),
          // Note, right-aligned.
          Text(
            note,
            style: TextStyle(fontSize: 16, color: customNoteColor, fontStyle: FontStyle.italic),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

/// AddScheduleBottomSheet: Form for adding a new schedule with text input for hours and minutes.
class AddScheduleBottomSheet extends StatefulWidget {
  @override
  _AddScheduleBottomSheetState createState() => _AddScheduleBottomSheetState();
}

class _AddScheduleBottomSheetState extends State<AddScheduleBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _startHourController = TextEditingController();
  final TextEditingController _startMinuteController = TextEditingController();
  final TextEditingController _endHourController = TextEditingController();
  final TextEditingController _endMinuteController = TextEditingController();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedDay = days.first;

  @override
  void dispose() {
    _startHourController.dispose();
    _startMinuteController.dispose();
    _endHourController.dispose();
    _endMinuteController.dispose();
    _subjectController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 16),
              // Day dropdown
              DropdownButtonFormField<String>(
                value: _selectedDay,
                items: days.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDay = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: '요일',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 16),
              // Start time input (hour and minute)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startHourController,
                      decoration: InputDecoration(
                        labelText: '시작시간 (시)',
                        hintText: '예: 8',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return '시작시간(시)을 입력하세요.';
                        final hour = int.tryParse(value);
                        if (hour == null || hour < 1 || hour > 24) return '1부터 24 사이의 숫자를 입력하세요.';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _startMinuteController,
                      decoration: InputDecoration(
                        labelText: '시작시간 (분)',
                        hintText: '예: 40',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return '시작시간(분)을 입력하세요.';
                        final minute = int.tryParse(value);
                        if (minute == null || minute < 0 || minute > 59) return '0부터 59 사이의 숫자를 입력하세요.';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // End time input (hour and minute)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _endHourController,
                      decoration: InputDecoration(
                        labelText: '종료시간 (시)',
                        hintText: '예: 13',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return '종료시간(시)을 입력하세요.';
                        final hour = int.tryParse(value);
                        if (hour == null || hour < 1 || hour > 24) return '1부터 24 사이의 숫자를 입력하세요.';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endMinuteController,
                      decoration: InputDecoration(
                        labelText: '종료시간 (분)',
                        hintText: '예: 30',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return '종료시간(분)을 입력하세요.';
                        final minute = int.tryParse(value);
                        if (minute == null || minute < 0 || minute > 59) return '0부터 59 사이의 숫자를 입력하세요.';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Subject input
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: '과목',
                  hintText: '예: 학교',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '과목을 입력하세요.';
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Note input
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: '특이사항',
                  hintText: '예: 추가 메모',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '특이사항을 입력하세요.';
                  return null;
                },
              ),
              SizedBox(height: 16),
              Divider(thickness: 2),
              SizedBox(height: 16),
              // Save button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newSchedule = ScheduleData(
                      order: 0, // will be updated below
                      startHour: int.parse(_startHourController.text),
                      startMinute: int.parse(_startMinuteController.text),
                      endHour: int.parse(_endHourController.text),
                      endMinute: int.parse(_endMinuteController.text),
                      title: _subjectController.text,
                      note: _noteController.text,
                    );
                    if (scheduleMap[_selectedDay] != null) {
                      newSchedule.order = scheduleMap[_selectedDay]!.length + 1;
                      scheduleMap[_selectedDay]!.add(newSchedule);
                    } else {
                      newSchedule.order = 1;
                      scheduleMap[_selectedDay] = [newSchedule];
                    }
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  '저장',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
