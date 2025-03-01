import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:numberpicker/numberpicker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initializeDatabase();
  runApp(TimeTableApp());
}

class TimeTableApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '타임테이블 앱',
      home: TimeTableHome(),
    );
  }
}

// 전역에 요일 목록 선언
const List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

// 전역 변수 (global)로 스케줄 데이터를 관리 (초기 데이터는 DB에 미리 삽입한 것으로 가정)
Map<String, List<ScheduleData>> globalScheduleMap = {
  '월': [
    ScheduleData(order: 1, startHour: 8, startMinute: 40, endHour: 13, endMinute: 40, title: '학교', note: '정규 수업', day: '월'),
    ScheduleData(order: 2, startHour: 14, startMinute: 34, endHour: 15, endMinute: 15, title: '구몬학습', note: '온라인 학습', day: '월'),
    ScheduleData(order: 3, startHour: 16, startMinute: 0, endHour: 18, endMinute: 25, title: '늘푸른수학', note: '보충 수업', day: '월'),
  ],
  '화': [
    ScheduleData(order: 1, startHour: 9, startMinute: 0, endHour: 10, endMinute: 30, title: '수학', note: '문제 풀이', day: '화'),
    ScheduleData(order: 2, startHour: 11, startMinute: 0, endHour: 12, endMinute: 0, title: '영어', note: '독해', day: '화'),
    ScheduleData(order: 3, startHour: 13, startMinute: 30, endHour: 15, endMinute: 0, title: '과학', note: '실험', day: '화'),
  ],
  '수': [
    ScheduleData(order: 1, startHour: 8, startMinute: 50, endHour: 10, endMinute: 20, title: '음악', note: '연습', day: '수'),
    ScheduleData(order: 2, startHour: 10, startMinute: 30, endHour: 12, endMinute: 0, title: '미술', note: '그림', day: '수'),
    ScheduleData(order: 3, startHour: 13, startMinute: 0, endHour: 14, endMinute: 30, title: '체육', note: '운동', day: '수'),
  ],
  '목': [
    ScheduleData(order: 1, startHour: 9, startMinute: 10, endHour: 10, endMinute: 50, title: '국어', note: '독서', day: '목'),
    ScheduleData(order: 2, startHour: 11, startMinute: 0, endHour: 12, endMinute: 30, title: '역사', note: '토론', day: '목'),
    ScheduleData(order: 3, startHour: 13, startMinute: 20, endHour: 15, endMinute: 0, title: '사회', note: '프로젝트', day: '목'),
  ],
  '금': [
    ScheduleData(order: 1, startHour: 8, startMinute: 30, endHour: 10, endMinute: 0, title: '수학', note: '복습', day: '금'),
    ScheduleData(order: 2, startHour: 10, startMinute: 10, endHour: 11, endMinute: 40, title: '영어', note: '어휘', day: '금'),
    ScheduleData(order: 3, startHour: 12, startMinute: 0, endHour: 13, endMinute: 30, title: '과학', note: '퀴즈', day: '금'),
  ],
  '토': [
    ScheduleData(order: 1, startHour: 10, startMinute: 0, endHour: 12, endMinute: 0, title: '미술', note: '자유 활동', day: '토'),
    ScheduleData(order: 2, startHour: 13, startMinute: 0, endHour: 15, endMinute: 0, title: '체육', note: '축구', day: '토'),
  ],
  '일': [
    ScheduleData(order: 1, startHour: 11, startMinute: 0, endHour: 12, endMinute: 30, title: '독서', note: '자기계발', day: '일'),
    ScheduleData(order: 2, startHour: 14, startMinute: 0, endHour: 16, endMinute: 0, title: '영화', note: '가족과 함께', day: '일'),
  ],
};

// DatabaseHelper: SQFlite를 이용하여 DB 및 schedule 테이블 관리
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'timetable.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day TEXT NOT NULL,
        startHour INTEGER NOT NULL,
        startMinute INTEGER NOT NULL,
        endHour INTEGER NOT NULL,
        endMinute INTEGER NOT NULL,
        title TEXT NOT NULL,
        note TEXT NOT NULL,
        scheduleOrder INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertSchedule(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('schedule', row);
  }

  Future<List<Map<String, dynamic>>> querySchedulesByDay(String day) async {
    Database db = await instance.database;
    return await db.query(
      'schedule',
      where: 'day = ?',
      whereArgs: [day],
      orderBy: 'scheduleOrder ASC',
    );
  }

  Future<int> updateScheduleOrder(int id, int newOrder) async {
    Database db = await instance.database;
    return await db.update(
      'schedule',
      {'scheduleOrder': newOrder},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSchedule(int id) async {
    Database db = await instance.database;
    return await db.delete('schedule', where: 'id = ?', whereArgs: [id]);
  }

  Future initializeDatabase() async {
    await database;
  }
}

/// ScheduleData 모델 (시간 세분화, 요일 및 순서 포함)
class ScheduleData {
  int? id;
  int order;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String title;
  final String note;
  final String day;

  ScheduleData({
    this.id,
    required this.order,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.title,
    this.note = '',
    required this.day,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'day': day,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'title': title,
      'note': note,
      'scheduleOrder': order,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory ScheduleData.fromMap(Map<String, dynamic> map) {
    return ScheduleData(
      id: map['id'],
      day: map['day'],
      order: map['scheduleOrder'],
      startHour: map['startHour'],
      startMinute: map['startMinute'],
      endHour: map['endHour'],
      endMinute: map['endMinute'],
      title: map['title'],
      note: map['note'],
    );
  }
}

/// TimeTableHome: 메인 화면 – 각 요일 탭과 해당 스케줄을 DB에서 불러와 표시
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
          children: days.map<Widget>((day) => DayScheduleView(day: day)).toList(),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddScheduleBottomSheet(),
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

/// AnimatedTabBar: 각 요일 탭을 애니메이션 효과와 함께 표시
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

/// DayScheduleView: FutureBuilder를 통해 DB에서 해당 요일의 스케줄을 불러오고,
/// ReorderableListView 및 삭제 버튼으로 항목의 순서 변경 및 삭제를 지원
class DayScheduleView extends StatefulWidget {
  final String day;
  DayScheduleView({required this.day});
  @override
  _DayScheduleViewState createState() => _DayScheduleViewState();
}

class _DayScheduleViewState extends State<DayScheduleView> {
  Future<List<ScheduleData>> _fetchSchedules() async {
    List<Map<String, dynamic>> rows = await DatabaseHelper.instance.querySchedulesByDay(widget.day);
    List<ScheduleData> schedules = rows.map((row) => ScheduleData.fromMap(row)).toList();
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

        List<ScheduleData> schedules = snapshot.data ?? [];
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
                child: Row(
                  children: [
                    Expanded(
                      child: TimeTableItem(
                        startHour: schedules[i].startHour,
                        startMinute: schedules[i].startMinute,
                        title: schedules[i].title,
                        endHour: schedules[i].endHour,
                        endMinute: schedules[i].endMinute,
                        note: schedules[i].note,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
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
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// TimeTableItem: 스케줄 항목 UI (시간은 "HH:MM" 형식, 특이사항은 우측 정렬)
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
    return hour.toString().padLeft(2, '0') +
        ":" +
        minute.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final Color customBorderColor = Colors.deepPurpleAccent;
    final Color customBackgroundColor = Colors.white;
    final Color customStartTimeColor = Colors.blue;
    final Color customSubjectColor = Colors.black;
    final Color customEndTimeColor = Colors.deepPurpleAccent;
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
              blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시작시간과 제목
          Row(
            children: [
              Text(
                "${formatTime(startHour, startMinute)}",
                style: TextStyle(
                    fontSize: 22,
                    color: customStartTimeColor,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                    fontSize: 22,
                    color: customSubjectColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          // 종료시간
          Text(
            formatTime(endHour, endMinute),
            style: TextStyle(fontSize: 18, color: customEndTimeColor, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          // 특이사항 (우측 정렬)
          Text(
            note,
            style: TextStyle(
                fontSize: 16,
                color: customNoteColor,
                fontStyle: FontStyle.italic),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

/// AddScheduleBottomSheet: 스케줄 추가 폼 (요일 선택, 텍스트 입력으로 시간 입력, 밸리데이션 포함)
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
              // Note input (선택사항이므로 validator 주석 처리)
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: '특이사항',
                  hintText: '예: 추가 메모',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                // validator: (value) {
                //   if (value == null || value.isEmpty) return '특이사항을 입력하세요.';
                //   return null;
                // },
              ),
              SizedBox(height: 16),
              Divider(thickness: 2),
              SizedBox(height: 16),
              // Save button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newSchedule = ScheduleData(
                      order: 0, // order will be updated below.
                      startHour: int.parse(_startHourController.text),
                      startMinute: int.parse(_startMinuteController.text),
                      endHour: int.parse(_endHourController.text),
                      endMinute: int.parse(_endMinuteController.text),
                      title: _subjectController.text,
                      note: _noteController.text,
                      day: _selectedDay,
                    );
                    // Retrieve current schedules from globalScheduleMap.
                    List<ScheduleData> currentSchedules =
                    List<ScheduleData>.from(globalScheduleMap[_selectedDay] ?? []);
                    newSchedule.order = currentSchedules.length + 1;
                    currentSchedules.add(newSchedule);
                    globalScheduleMap[_selectedDay] = currentSchedules;
                    // Insert new schedule into the database.
                    DatabaseHelper.instance.insertSchedule(newSchedule.toMap());
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
