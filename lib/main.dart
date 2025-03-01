import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
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

// Global day list
const List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

// DatabaseHelper: SQFlite를 사용하여 데이터베이스 및 schedule 테이블을 관리
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
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
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
}

// ScheduleData 모델 (시간 세분화 및 순서, 요일 포함)
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

// 메인 화면: 각 요일별 스케줄을 DB에서 불러와 표시하고, 새로운 스케줄 추가 후 setState로 UI 갱신
class TimeTableHome extends StatefulWidget {
  @override
  _TimeTableHomeState createState() => _TimeTableHomeState();
}

class _TimeTableHomeState extends State<TimeTableHome> {
  @override
  void initState() {
    super.initState();
    // Initialize the database
    DatabaseHelper.instance.database;
  }

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
                  builder: (BuildContext context) {
                    return AddScheduleBottomSheet();
                  },
                ).then((_) {
                  setState(() {}); // Refresh UI after adding a schedule.
                });
              },
            );
          },
        ),
      ),
    );
  }
}

/// AnimatedTabBar: 탭 텍스트 애니메이션 효과 (선택 시 크게)
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

/// DayScheduleView: Fetches schedules for a given day from DB and displays them in a reorderable list.
class DayScheduleView extends StatefulWidget {
  final String day;
  DayScheduleView({required this.day});
  @override
  _DayScheduleViewState createState() => _DayScheduleViewState();
}

class _DayScheduleViewState extends State<DayScheduleView> {
  late Future<List<ScheduleData>> _futureSchedules;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  void _fetchSchedules() {
    _futureSchedules = DatabaseHelper.instance.querySchedulesByDay(widget.day).then(
          (rows) => rows.map((row) => ScheduleData.fromMap(row)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScheduleData>>(
      future: _futureSchedules,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));

        List<ScheduleData> schedules = snapshot.data ?? [];
        schedules.sort((a, b) => a.order.compareTo(b.order));
        return ReorderableListView(
          padding: EdgeInsets.all(16.0),
          onReorder: (oldIndex, newIndex) async {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = schedules.removeAt(oldIndex);
              schedules.insert(newIndex, item);
              for (int i = 0; i < schedules.length; i++) {
                schedules[i].order = i + 1;
                // Update order in DB.
                if (schedules[i].id != null)
                  DatabaseHelper.instance.updateScheduleOrder(schedules[i].id!, i + 1);
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
                ),
              ),
          ],
        );
      },
    );
  }
}

/// TimeTableItem: UI for a schedule item (displays time as "HH:MM" and right-aligns the note)
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
          // Start time and title.
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
          // Note (right-aligned).
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
                      order: 0, // Will be updated later.
                      startHour: int.parse(_startHourController.text),
                      startMinute: int.parse(_startMinuteController.text),
                      endHour: int.parse(_endHourController.text),
                      endMinute: int.parse(_endMinuteController.text),
                      title: _subjectController.text,
                      note: _noteController.text,
                      day: _selectedDay,
                    );
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
