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

// 메인 화면을 StatefulWidget으로 변경하여 스케줄 추가 시 setState로 갱신
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
/// 커스텀 스타일이 적용된 스케줄 항목 UI
/// [시작시간] [과목] / [종료시간] / [특이사항] (특이사항은 우측 정렬)
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

    // 시간을 "00:00" 형태로 포맷하는 헬퍼 함수
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


/// 스케줄 추가용 Bottom Sheet (요일 선택 포함)
/// 입력 후 "저장" 버튼을 누르면 밸리데이션을 체크한 후 해당 요일의 scheduleMap에 저장됩니다.
class AddScheduleBottomSheet extends StatefulWidget {
  @override
  _AddScheduleBottomSheetState createState() => _AddScheduleBottomSheetState();
}

class _AddScheduleBottomSheetState extends State<AddScheduleBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // 기본 선택 요일은 전역 days 리스트의 첫 번째
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 드래그 핸들 (작은 회색 막대)
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
              // 첫 번째 행: 시작시간과 종료시간 (나란히 배치)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      decoration: InputDecoration(
                        labelText: '시작시간',
                        hintText: '예: 8',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '시작시간을 입력하세요.';
                        }
                        final hour = int.tryParse(value);
                        if (hour == null || hour < 1 || hour > 24) {
                          return '1부터 24 사이의 숫자를 입력하세요.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      decoration: InputDecoration(
                        labelText: '종료시간',
                        hintText: '예: 13',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '종료시간을 입력하세요.';
                        }
                        final hour = int.tryParse(value);
                        if (hour == null || hour < 1 || hour > 24) {
                          return '1부터 24 사이의 숫자를 입력하세요.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // 두 번째 행: 과목
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
              // 세 번째 행: 특이사항
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
