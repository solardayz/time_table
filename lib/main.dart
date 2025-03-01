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
/// 디자인:
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
