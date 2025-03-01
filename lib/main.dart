import 'package:flutter/material.dart';

void main() {
  runApp(TimeTableApp());
}

// 전역에 요일 목록 선언
const List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

// 전역에 요일별 스케줄 데이터를 Map으로 선언
Map<String, List<ScheduleData>> scheduleMap = {
  '월': [
    ScheduleData(start: '08:40', end: '13:40', title: '학교', note: '정규 수업'),
    ScheduleData(start: '14:34', end: '15:15', title: '구몬학습', note: '온라인 학습'),
    ScheduleData(start: '16:00', end: '18:25', title: '늘푸른수학', note: '보충 수업'),
  ],
  '화': [
    ScheduleData(start: '09:00', end: '10:30', title: '수학', note: '문제 풀이'),
    ScheduleData(start: '11:00', end: '12:00', title: '영어', note: '독해'),
    ScheduleData(start: '13:30', end: '15:00', title: '과학', note: '실험'),
  ],
  '수': [
    ScheduleData(start: '08:50', end: '10:20', title: '음악', note: '연습'),
    ScheduleData(start: '10:30', end: '12:00', title: '미술', note: '그림'),
    ScheduleData(start: '13:00', end: '14:30', title: '체육', note: '운동'),
  ],
  '목': [
    ScheduleData(start: '09:10', end: '10:50', title: '국어', note: '독서'),
    ScheduleData(start: '11:00', end: '12:30', title: '역사', note: '토론'),
    ScheduleData(start: '13:20', end: '15:00', title: '사회', note: '프로젝트'),
  ],
  '금': [
    ScheduleData(start: '08:30', end: '10:00', title: '수학', note: '복습'),
    ScheduleData(start: '10:10', end: '11:40', title: '영어', note: '어휘'),
    ScheduleData(start: '12:00', end: '13:30', title: '과학', note: '퀴즈'),
  ],
  '토': [
    ScheduleData(start: '10:00', end: '12:00', title: '미술', note: '자유 활동'),
    ScheduleData(start: '13:00', end: '15:00', title: '체육', note: '축구'),
  ],
  '일': [
    ScheduleData(start: '11:00', end: '12:30', title: '독서', note: '자기계발'),
    ScheduleData(start: '14:00', end: '16:00', title: '영화', note: '가족과 함께'),
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

// 메인 화면을 StatefulWidget으로 변경하여 스케줄이 추가될 때 setState로 갱신
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
        // 각 요일별 스케줄을 동적으로 표시
        body: TabBarView(
          children: days
              .map((day) => DayScheduleView(schedules: scheduleMap[day] ?? []))
              .toList(),
        ),
        // FAB를 누르면 Bottom Sheet가 뜨고, 닫힌 후 setState를 호출하여 화면 갱신
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
                ).then((value) {
                  setState(() {}); // 저장 후 화면 갱신
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
/// 선택된 탭은 글씨 크기가 크게, 미선택 탭은 작게 표시됩니다.
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

/// 스케줄 데이터를 위한 모델 (특이사항 포함)
class ScheduleData {
  final String start;
  final String end;
  final String title;
  final String note;

  ScheduleData({
    required this.start,
    required this.end,
    required this.title,
    this.note = '',
  });
}

/// 각 요일의 스케줄을 ListView로 보여주는 위젯
class DayScheduleView extends StatelessWidget {
  final List<ScheduleData> schedules;
  DayScheduleView({required this.schedules});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return TimeTableItem(
          startTime: schedule.start,
          title: schedule.title,
          endTime: schedule.end,
          note: schedule.note,
        );
      },
    );
  }
}

/// 커스텀 스타일이 적용된 스케줄 항목 UI
/// [시작시간] [과목] / [종료시간] / [특이사항]
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

  @override
  Widget build(BuildContext context) {
    // 커스텀 컬러 정의
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
                "$startTime.",
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
            endTime,
            style: TextStyle(
              fontSize: 14,
              color: customEndTimeColor,
            ),
          ),
          SizedBox(height: 8),
          // 특이사항 (이탤릭)
          Text(
            note,
            style: TextStyle(
              fontSize: 16,
              color: customNoteColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// 스케줄 추가용 Bottom Sheet (요일 선택 포함)
/// 입력 후 "저장" 버튼을 누르면 해당 요일의 scheduleMap에 저장됩니다.
class AddScheduleBottomSheet extends StatefulWidget {
  @override
  _AddScheduleBottomSheetState createState() => _AddScheduleBottomSheetState();
}

class _AddScheduleBottomSheetState extends State<AddScheduleBottomSheet> {
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // 기본 선택 요일은 days 리스트의 첫 번째
  String _selectedDay = days.first;

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // 시작시간 입력
            TextField(
              controller: _startTimeController,
              decoration: InputDecoration(
                labelText: '시작시간',
                hintText: '예: 08:40',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // 종료시간 입력
            TextField(
              controller: _endTimeController,
              decoration: InputDecoration(
                labelText: '종료시간',
                hintText: '예: 13:40',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // 과목 입력
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: '과목',
                hintText: '예: 학교',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // 특이사항 입력
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: '특이사항',
                hintText: '예: 추가 메모',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // 저장 버튼: 입력한 스케줄을 선택한 요일의 scheduleMap에 저장
            ElevatedButton(
              onPressed: () {
                final newSchedule = ScheduleData(
                  start: _startTimeController.text,
                  end: _endTimeController.text,
                  title: _subjectController.text,
                  note: _noteController.text,
                );
                if (scheduleMap[_selectedDay] != null) {
                  scheduleMap[_selectedDay]!.add(newSchedule);
                } else {
                  scheduleMap[_selectedDay] = [newSchedule];
                }
                Navigator.of(context).pop();
              },
              child: Text('저장'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
