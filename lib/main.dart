import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

void main() {
  runApp(TimeTableApp());
}

// 전역에 요일 목록 선언
const List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

// 전역에 요일별 스케줄 데이터를 Map으로 선언 (각 항목에 order 추가)
Map<String, List<ScheduleData>> scheduleMap = {
  '월': [
    ScheduleData(order: 1, start: '08:40', end: '13:40', title: '학교', note: '정규 수업'),
    ScheduleData(order: 2, start: '14:34', end: '15:15', title: '구몬학습', note: '온라인 학습'),
    ScheduleData(order: 3, start: '16:00', end: '18:25', title: '늘푸른수학', note: '보충 수업'),
  ],
  '화': [
    ScheduleData(order: 1, start: '09:00', end: '10:30', title: '수학', note: '문제 풀이'),
    ScheduleData(order: 2, start: '11:00', end: '12:00', title: '영어', note: '독해'),
    ScheduleData(order: 3, start: '13:30', end: '15:00', title: '과학', note: '실험'),
  ],
  '수': [
    ScheduleData(order: 1, start: '08:50', end: '10:20', title: '음악', note: '연습'),
    ScheduleData(order: 2, start: '10:30', end: '12:00', title: '미술', note: '그림'),
    ScheduleData(order: 3, start: '13:00', end: '14:30', title: '체육', note: '운동'),
  ],
  '목': [
    ScheduleData(order: 1, start: '09:10', end: '10:50', title: '국어', note: '독서'),
    ScheduleData(order: 2, start: '11:00', end: '12:30', title: '역사', note: '토론'),
    ScheduleData(order: 3, start: '13:20', end: '15:00', title: '사회', note: '프로젝트'),
  ],
  '금': [
    ScheduleData(order: 1, start: '08:30', end: '10:00', title: '수학', note: '복습'),
    ScheduleData(order: 2, start: '10:10', end: '11:40', title: '영어', note: '어휘'),
    ScheduleData(order: 3, start: '12:00', end: '13:30', title: '과학', note: '퀴즈'),
  ],
  '토': [
    ScheduleData(order: 1, start: '10:00', end: '12:00', title: '미술', note: '자유 활동'),
    ScheduleData(order: 2, start: '13:00', end: '15:00', title: '체육', note: '축구'),
  ],
  '일': [
    ScheduleData(order: 1, start: '11:00', end: '12:30', title: '독서', note: '자기계발'),
    ScheduleData(order: 2, start: '14:00', end: '16:00', title: '영화', note: '가족과 함께'),
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

// 메인 화면 (StatefulWidget으로 스케줄 추가 및 순서 변경 시 화면 갱신)
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
        // 각 요일별 스케줄을 동적으로 표시 (드래그 앤 드롭 지원)
        body: TabBarView(
          children: days.map((day) => DayScheduleView(day: day)).toList(),
        ),
        // FAB를 누르면 Bottom Sheet가 뜨고, 닫힌 후 setState 호출하여 화면 갱신
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
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

/// 애니메이션 효과가 적용된 TabBar 위젯
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
                    ? TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )
                    : TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54,
                ),
                child: Text(days[index]),
              ),
            );
          }),
        );
      },
    );
  }
}

/// 스케줄 데이터를 위한 모델 (order 필드 추가)
class ScheduleData {
  int order; // 순서값 (드래그 앤 드롭 시 업데이트)
  final String start;
  final String end;
  final String title;
  final String note;

  ScheduleData({
    required this.order,
    required this.start,
    required this.end,
    required this.title,
    this.note = '',
  });
}

/// 각 요일의 스케줄을 ReorderableListView로 보여주는 위젯
class DayScheduleView extends StatefulWidget {
  final String day;
  DayScheduleView({required this.day});
  @override
  _DayScheduleViewState createState() => _DayScheduleViewState();
}

class _DayScheduleViewState extends State<DayScheduleView> {
  late List<ScheduleData> _schedules;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() {
    _schedules = List<ScheduleData>.from(scheduleMap[widget.day] ?? []);
    _schedules.sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      padding: EdgeInsets.all(16.0),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final ScheduleData item = _schedules.removeAt(oldIndex);
          _schedules.insert(newIndex, item);
          // 업데이트된 순서 반영: 1부터 시작하는 순서로 재할당
          for (int i = 0; i < _schedules.length; i++) {
            _schedules[i].order = i + 1;
          }
          // 전역 scheduleMap에도 반영
          scheduleMap[widget.day] = _schedules;
        });
      },
      children: [
        for (int index = 0; index < _schedules.length; index++)
          Container(
            key: ValueKey(_schedules[index].order),
            child: TimeTableItem(
              startTime: _schedules[index].start,
              title: _schedules[index].title,
              endTime: _schedules[index].end,
              note: _schedules[index].note,
            ),
          ),
      ],
    );
  }
}

/// 스케줄 항목 UI (시간 포맷 "00:00", 특이사항 우측 정렬)
class TimeTableItem extends StatelessWidget {
  final String startTime;
  final String title;
  final String endTime;
  final String note;

  TimeTableItem({
    required this.startTime,
    required this.title,
    required this.endTime,
    required this.note,
  });

  String formatTime(String time) {
    if (time.contains(":")) {
      List<String> parts = time.split(":");
      if (parts.length == 2) {
        String hour = parts[0].padLeft(2, '0');
        String minute = parts[1].padLeft(2, '0');
        return "$hour:$minute";
      }
      return time;
    } else {
      final int? hour = int.tryParse(time);
      if (hour == null) return time;
      return hour.toString().padLeft(2, '0') + ":00";
    }
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
          BoxShadow(
            color: customBorderColor.withOpacity(0.2),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시작시간과 과목 (크게 표시)
          Row(
            children: [
              Text(
                "${formatTime(startTime)}.",
                style: TextStyle(
                  fontSize: 22,
                  color: customStartTimeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  color: customSubjectColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // 종료시간 (작게 표시)
          Text(
            formatTime(endTime),
            style: TextStyle(
              fontSize: 14,
              color: customEndTimeColor,
            ),
          ),
          SizedBox(height: 8),
          // 특이사항 (우측 정렬)
          Text(
            note,
            style: TextStyle(
              fontSize: 16,
              color: customNoteColor,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

/// 스케줄 추가용 Bottom Sheet (요일 선택, 다이얼로 시간 선택, 밸리데이션 포함)
class AddScheduleBottomSheet extends StatefulWidget {
  @override
  _AddScheduleBottomSheetState createState() => _AddScheduleBottomSheetState();
}

class _AddScheduleBottomSheetState extends State<AddScheduleBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _startTime = 1;
  int _endTime = 1;

  String _selectedDay = days.first;

  @override
  void dispose() {
    _subjectController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime(BuildContext context) async {
    int currentValue = _startTime;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("시작시간 선택"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return NumberPicker(
                minValue: 1,
                maxValue: 24,
                value: currentValue,
                onChanged: (value) {
                  setState(() => currentValue = value);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _startTime = currentValue;
                });
                Navigator.of(context).pop();
              },
              child: Text("선택"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectEndTime(BuildContext context) async {
    int currentValue = _endTime;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("종료시간 선택"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return NumberPicker(
                minValue: 1,
                maxValue: 24,
                value: currentValue,
                onChanged: (value) {
                  setState(() => currentValue = value);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _endTime = currentValue;
                });
                Navigator.of(context).pop();
              },
              child: Text("선택"),
            ),
          ],
        );
      },
    );
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
              // 상단 드래그 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 16),
              // 요일 선택 드롭다운
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // 시작시간과 종료시간 Row (다이얼 선택)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartTime(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '시작시간',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _startTime.toString().padLeft(2, '0') + ":00",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndTime(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '종료시간',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _endTime.toString().padLeft(2, '0') + ":00",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // 과목 입력
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: '과목',
                  hintText: '예: 학교',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '과목을 입력하세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // 특이사항 입력
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: '특이사항',
                  hintText: '예: 추가 메모',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '특이사항을 입력하세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Divider(thickness: 2),
              SizedBox(height: 16),
              // 저장 버튼
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newSchedule = ScheduleData(
                      order: 0, // 새 항목은 순서를 나중에 ReorderableListView에서 재정렬 시 업데이트
                      start: _startTime.toString().padLeft(2, '0') + ":00",
                      end: _endTime.toString().padLeft(2, '0') + ":00",
                      title: _subjectController.text,
                      note: _noteController.text,
                    );
                    if (scheduleMap[_selectedDay] != null) {
                      // 새 항목의 order는 현재 리스트 길이 + 1
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '저장',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
