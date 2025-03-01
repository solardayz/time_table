import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:numberpicker/numberpicker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initializeDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '타임테이블 앱',
      home: UserSelectScreen(),
    );
  }
}

// ----------------------
// Global Variables
// ----------------------
const List<String> globalDays = ['월', '화', '수', '목', '금', '토', '일'];
// 전역 변수: 사용자와 스케줄 데이터(초기 데이터는 DB에 미리 삽입된 것으로 가정)
// (실제 앱에서는 사용자가 직접 추가하는 방식으로 관리)
Map<String, List<ScheduleData>> globalScheduleMap = {
  '월': [
    ScheduleData(order: 1, startHour: 8, startMinute: 40, endHour: 13, endMinute: 40, title: '학교', note: '정규 수업', day: '월', userId: 0),
    ScheduleData(order: 2, startHour: 14, startMinute: 34, endHour: 15, endMinute: 15, title: '구몬학습', note: '온라인 학습', day: '월', userId: 0),
    ScheduleData(order: 3, startHour: 16, startMinute: 0, endHour: 18, endMinute: 25, title: '늘푸른수학', note: '보충 수업', day: '월', userId: 0),
  ],
  '화': [
    ScheduleData(order: 1, startHour: 9, startMinute: 0, endHour: 10, endMinute: 30, title: '수학', note: '문제 풀이', day: '화', userId: 0),
    ScheduleData(order: 2, startHour: 11, startMinute: 0, endHour: 12, endMinute: 0, title: '영어', note: '독해', day: '화', userId: 0),
    ScheduleData(order: 3, startHour: 13, startMinute: 30, endHour: 15, endMinute: 0, title: '과학', note: '실험', day: '화', userId: 0),
  ],
  '수': [
    ScheduleData(order: 1, startHour: 8, startMinute: 50, endHour: 10, endMinute: 20, title: '음악', note: '연습', day: '수', userId: 0),
    ScheduleData(order: 2, startHour: 10, startMinute: 30, endHour: 12, endMinute: 0, title: '미술', note: '그림', day: '수', userId: 0),
    ScheduleData(order: 3, startHour: 13, startMinute: 0, endHour: 14, endMinute: 30, title: '체육', note: '운동', day: '수', userId: 0),
  ],
  '목': [
    ScheduleData(order: 1, startHour: 9, startMinute: 10, endHour: 10, endMinute: 50, title: '국어', note: '독서', day: '목', userId: 0),
    ScheduleData(order: 2, startHour: 11, startMinute: 0, endHour: 12, endMinute: 30, title: '역사', note: '토론', day: '목', userId: 0),
    ScheduleData(order: 3, startHour: 13, startMinute: 20, endHour: 15, endMinute: 0, title: '사회', note: '프로젝트', day: '목', userId: 0),
  ],
  '금': [
    ScheduleData(order: 1, startHour: 8, startMinute: 30, endHour: 10, endMinute: 0, title: '수학', note: '복습', day: '금', userId: 0),
    ScheduleData(order: 2, startHour: 10, startMinute: 10, endHour: 11, endMinute: 40, title: '영어', note: '어휘', day: '금', userId: 0),
    ScheduleData(order: 3, startHour: 12, startMinute: 0, endHour: 13, endMinute: 30, title: '과학', note: '퀴즈', day: '금', userId: 0),
  ],
  '토': [
    ScheduleData(order: 1, startHour: 10, startMinute: 0, endHour: 12, endMinute: 0, title: '미술', note: '자유 활동', day: '토', userId: 0),
    ScheduleData(order: 2, startHour: 13, startMinute: 0, endHour: 15, endMinute: 0, title: '체육', note: '축구', day: '토', userId: 0),
  ],
  '일': [
    ScheduleData(order: 1, startHour: 11, startMinute: 0, endHour: 12, endMinute: 30, title: '독서', note: '자기계발', day: '일', userId: 0),
    ScheduleData(order: 2, startHour: 14, startMinute: 0, endHour: 16, endMinute: 0, title: '영화', note: '가족과 함께', day: '일', userId: 0),
  ],
};

// ----------------------
// DatabaseHelper: DB 및 테이블 관리
// ----------------------
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
    String path = p.join(await getDatabasesPath(), 'timetable.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // 사용자 테이블 생성
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    // 스케줄 테이블 생성 (userId 외래키 포함)
    await db.execute('''
      CREATE TABLE schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        day TEXT NOT NULL,
        startHour INTEGER NOT NULL,
        startMinute INTEGER NOT NULL,
        endHour INTEGER NOT NULL,
        endMinute INTEGER NOT NULL,
        title TEXT NOT NULL,
        note TEXT NOT NULL,
        scheduleOrder INTEGER NOT NULL,
        FOREIGN KEY(userId) REFERENCES user(id)
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('user', row);
  }

  Future<List<Map<String, dynamic>>> queryUsers() async {
    Database db = await instance.database;
    return await db.query('user', orderBy: 'id ASC');
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    // 먼저 해당 사용자의 시간표 데이터를 모두 삭제
    await db.delete('schedule', where: 'userId = ?', whereArgs: [id]);
    // 그 후에 사용자를 삭제
    return await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }


  Future<int> insertSchedule(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('schedule', row);
  }

  Future<List<Map<String, dynamic>>> querySchedulesByDay(int userId, String day) async {
    Database db = await instance.database;
    return await db.query(
      'schedule',
      where: 'userId = ? AND day = ?',
      whereArgs: [userId, day],
      orderBy: 'scheduleOrder ASC',
    );
  }

  Future<int> updateScheduleOrder(int id, int newOrder) async {
    Database db = await instance.database;
    return await db.update('schedule', {'scheduleOrder': newOrder},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSchedule(int id) async {
    Database db = await instance.database;
    return await db.delete('schedule', where: 'id = ?', whereArgs: [id]);
  }

  Future initializeDatabase() async {
    await database;
  }
}

// ----------------------
// ScheduleData 모델: 시간, 요일, 순서, 사용자 포함
// ----------------------
class ScheduleData {
  int? id;
  int order;
  int startHour;
  int startMinute;
  int endHour;
  int endMinute;
  String title;
  String note;
  String day;
  int userId;

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
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'userId': userId,
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
      userId: map['userId'],
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

// ----------------------
// User 모델
// ----------------------
class User {
  int? id;
  String name;
  User({this.id, required this.name});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'name': name};
    if (id != null) map['id'] = id;
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'], name: map['name']);
  }
}

// ----------------------
// UserSelectScreen: 첫 화면 사용자 선택 및 추가
// ----------------------

// DatabaseHelper와 User, TimetableScreen 등은 기존 코드와 동일하게 유지합니다.
// 여기서는 UserSelectScreen의 UI 스타일링 부분만 수정한 예제를 보여드립니다.

class UserSelectScreen extends StatefulWidget {
  @override
  _UserSelectScreenState createState() => _UserSelectScreenState();
}

class _UserSelectScreenState extends State<UserSelectScreen> {
  final TextEditingController _userController = TextEditingController();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    List<Map<String, dynamic>> rows = await DatabaseHelper.instance.queryUsers();
    return rows.map((row) => User.fromMap(row)).toList();
  }

  void _addUser() async {
    if (_userController.text.trim().isEmpty) return;
    await DatabaseHelper.instance.insertUser({'name': _userController.text.trim()});
    _userController.clear();
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  void _deleteUser(User user) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("삭제하시겠습니까?"),
        content: Text("해당 사용자의 시간표도 삭제되며 복구 불가능합니다. 그래도 삭제하시겠어요?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("아니요")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("예")),
        ],
      ),
    );
    if (confirm && user.id != null) {
      await DatabaseHelper.instance.deleteUser(user.id!);
      setState(() {
        _usersFuture = _fetchUsers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("누가 사용할거에요?"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 사용자 이름 입력란과 추가 버튼
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      labelText: "이름 입력",
                      hintText: "사용자 이름을 입력하세요",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addUser,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Text(
                    "추가",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(
              thickness: 2,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            // 사용자 리스트
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text("Error: ${snapshot.error}"));
                  List<User> users = snapshot.data ?? [];
                  if (users.isEmpty) {
                    return Center(child: Text("등록된 사용자가 없습니다."));
                  }
                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      User user = users[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.person, color: Colors.deepPurple),
                          title: Text(
                            user.name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          // 우측에 삭제 버튼과 선택 아이콘 함께 배치
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUser(user),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 18),
                            ],
                          ),
                          onTap: () {
                            // 사용자를 선택하면 해당 사용자의 시간표 화면으로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TimetableScreen(user: user),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ----------------------
// TimetableScreen: 선택한 사용자의 시간표 화면
// ----------------------
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

// ----------------------
// AnimatedTabBarForUser: 사용자의 시간표 탭
// ----------------------
class AnimatedTabBarForUser extends StatelessWidget implements PreferredSizeWidget {
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
          tabs: List.generate(globalDays.length, (index) {
            bool selected = tabController.index == index;
            return Tab(
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: selected
                    ? TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)
                    : TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black54),
                child: Text(globalDays[index]),
              ),
            );
          }),
        );
      },
    );
  }
}

// ----------------------
// DayScheduleViewForUser: DB에서 해당 사용자의 특정 요일 스케줄 조회 및 삭제/순서 변경
// ----------------------
class DayScheduleViewForUser extends StatefulWidget {
  final String day;
  final int userId;
  DayScheduleViewForUser({required this.day, required this.userId});
  @override
  _DayScheduleViewForUserState createState() => _DayScheduleViewForUserState();
}

class _DayScheduleViewForUserState extends State<DayScheduleViewForUser> {
  Future<List<ScheduleData>> _fetchSchedules() async {
    List<Map<String, dynamic>> rows =
    await DatabaseHelper.instance.querySchedulesByDay(widget.userId, widget.day);
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
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text("아니요"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text("예"),
                          ),
                        ],
                      ),
                    );
                    if (confirm && schedules[i].id != null) {
                      await DatabaseHelper.instance.deleteSchedule(schedules[i].id!);
                      setState(() {});
                    }
                  },
                ),
              ),
          ],
        );

      },
    );
  }
}

// ----------------------
// TimeTableItem: 각 스케줄 항목을 Card 위젯으로 이쁘게 표시 (디자인 변경)
// ----------------------
class TimeTableItem extends StatelessWidget {
  final int startHour;
  final int startMinute;
  final String title;
  final int endHour;
  final int endMinute;
  final String note;
  final VoidCallback? onDelete;

  TimeTableItem({
    required this.startHour,
    required this.startMinute,
    required this.title,
    required this.endHour,
    required this.endMinute,
    required this.note,
    this.onDelete,
  });

  String formatTime(int hour, int minute) {
    return hour.toString().padLeft(2, '0') + ":" + minute.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 첫 번째 행: 시작시간, 과목, 그리고 우측 삭제 버튼
            Row(
              children: [
                Text(
                  formatTime(startHour, startMinute),
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
            SizedBox(height: 8),
            // 두 번째 행: 종료시간
            Text(
              formatTime(endHour, endMinute),
              style: TextStyle(
                fontSize: 18,
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            // 세 번째 행: 특이사항 (우측 정렬)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                note,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ----------------------
// AddScheduleBottomSheet: 스케줄 추가 폼 (요일 선택, 텍스트 입력으로 시간 입력, 유효성 검사 포함)
// ----------------------
class AddScheduleBottomSheet extends StatefulWidget {
  final int userId;
  AddScheduleBottomSheet({required this.userId});
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

  String _selectedDay = globalDays.first;

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
                items: globalDays.map((String day) {
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
              // Note input (optional)
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: '특이사항',
                  hintText: '예: 추가 메모',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
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
                      userId: widget.userId,
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
