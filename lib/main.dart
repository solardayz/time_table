import 'package:flutter/material.dart';

void main() {
  runApp(TimeTableApp());
}

class TimeTableApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '타임테이블 앱',
      home: DefaultTabController(
        length: 5, // 월, 화, 수, 목, 금
        child: Scaffold(
          appBar: AppBar(
            title: Text('타임테이블'),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: '월'),
                Tab(text: '화'),
                Tab(text: '수'),
                Tab(text: '목'),
                Tab(text: '금'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // 월요일 스케줄
              DayScheduleView(
                schedules: [
                  ScheduleData(start: '08:40', end: '13:40', title: '학교'),
                  ScheduleData(start: '14:34', end: '15:15', title: '구몬학습'),
                  ScheduleData(start: '16:00', end: '18:25', title: '늘푸른수학'),
                ],
              ),
              // 화요일 스케줄 (랜덤 데이터)
              DayScheduleView(
                schedules: [
                  ScheduleData(start: '09:00', end: '10:30', title: '수학'),
                  ScheduleData(start: '11:00', end: '12:00', title: '영어'),
                  ScheduleData(start: '13:30', end: '15:00', title: '과학'),
                ],
              ),
              // 수요일 스케줄 (랜덤 데이터)
              DayScheduleView(
                schedules: [
                  ScheduleData(start: '08:50', end: '10:20', title: '음악'),
                  ScheduleData(start: '10:30', end: '12:00', title: '미술'),
                  ScheduleData(start: '13:00', end: '14:30', title: '체육'),
                ],
              ),
              // 목요일 스케줄 (랜덤 데이터)
              DayScheduleView(
                schedules: [
                  ScheduleData(start: '09:10', end: '10:50', title: '국어'),
                  ScheduleData(start: '11:00', end: '12:30', title: '역사'),
                  ScheduleData(start: '13:20', end: '15:00', title: '사회'),
                ],
              ),
              // 금요일 스케줄 (랜덤 데이터)
              DayScheduleView(
                schedules: [
                  ScheduleData(start: '08:30', end: '10:00', title: '수학'),
                  ScheduleData(start: '10:10', end: '11:40', title: '영어'),
                  ScheduleData(start: '12:00', end: '13:30', title: '과학'),
                ],
              ),
            ],
          ),
          // Builder를 사용해 올바른 context를 얻음
          floatingActionButton: Builder(
            builder: (context) {
              return FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  // FAB 클릭 시 Bottom Sheet 표시
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return AddScheduleBottomSheet();
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// 스케줄 데이터를 위한 모델 클래스
class ScheduleData {
  final String start;
  final String end;
  final String title;

  ScheduleData({
    required this.start,
    required this.end,
    required this.title,
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
        );
      },
    );
  }
}

/// 하나의 스케줄 항목 UI
/// --------------------------------------
/// 08:40.     학교
/// 13:40
///          13:40 전후 하교
/// --------------------------------------
class TimeTableItem extends StatelessWidget {
  final String startTime;
  final String title;
  final String endTime;

  TimeTableItem({
    required this.startTime,
    required this.title,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // 외곽선 효과
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 구분선
          Divider(color: Colors.grey, thickness: 1),
          // 첫 번째 행: 시작 시간과 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Text(
                  "$startTime.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8.0),
                Text(
                  title,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // 두 번째 행: 종료 시간 (왼쪽 정렬)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Row(
              children: [
                Text(
                  endTime,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // 세 번째 행: 종료 시간 + "전후 하교" (오른쪽 정렬)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "$endTime 전후 하교",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          // 하단 구분선
          Divider(color: Colors.grey, thickness: 1),
        ],
      ),
    );
  }
}

/// Bottom Sheet에 표시할 스케줄 추가 폼 위젯 (요일 필드 추가)
class AddScheduleBottomSheet extends StatefulWidget {
  @override
  _AddScheduleBottomSheetState createState() => _AddScheduleBottomSheetState();
}

class _AddScheduleBottomSheetState extends State<AddScheduleBottomSheet> {
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // 추가: 요일 선택을 위한 변수 (기본값은 '월')
  String _selectedDay = '월';

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
            // 요일 선택 필드 (드롭다운)
            DropdownButtonFormField<String>(
              value: _selectedDay,
              items: <String>['월', '화', '수', '목', '금']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
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
            // 저장 버튼
            ElevatedButton(
              onPressed: () {
                // TODO: 저장 로직 구현 (예: 선택한 요일에 해당하는 스케줄 추가)
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
