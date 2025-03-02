import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

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
    // 사용자 알람 설정 테이블 생성
    await db.execute('''
      CREATE TABLE user_alarm (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        alarmOffset INTEGER NOT NULL DEFAULT 20,
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

  Future<int> updateUser(int id, String newName) async {
    Database db = await instance.database;
    return await db.update('user', {'name': newName}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    // 사용자 삭제 시 해당 사용자의 시간표 및 알람도 함께 삭제
    await db.delete('schedule', where: 'userId = ?', whereArgs: [id]);
    await db.delete('user_alarm', where: 'userId = ?', whereArgs: [id]);
    return await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertSchedule(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('schedule', row);
  }

  Future<List<Map<String, dynamic>>> querySchedulesByDay(int userId, String day) async {
    Database db = await instance.database;
    return await db.query('schedule',
        where: 'userId = ? AND day = ?',
        whereArgs: [userId, day],
        orderBy: 'scheduleOrder ASC');
  }

  Future<int> updateScheduleOrder(int id, int newOrder) async {
    Database db = await instance.database;
    return await db.update('schedule', {'scheduleOrder': newOrder}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateSchedule(int id, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.update('schedule', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSchedule(int id) async {
    Database db = await instance.database;
    return await db.delete('schedule', where: 'id = ?', whereArgs: [id]);
  }

  // 사용자 알람 설정 관련 메서드
  Future<int> insertOrUpdateAlarm(int userId, int alarmOffset) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> rows = await db.query(
      'user_alarm',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (rows.isEmpty) {
      return await db.insert('user_alarm', {
        'userId': userId,
        'alarmOffset': alarmOffset,
      });
    } else {
      int id = rows.first['id'];
      return await db.update('user_alarm', {'alarmOffset': alarmOffset},
          where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<int> getAlarmOffset(int userId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> rows = await db.query(
      'user_alarm',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (rows.isNotEmpty) {
      return rows.first['alarmOffset'];
    }
    return 20; // 기본값 20분 전
  }

  Future initializeDatabase() async {
    await database;
  }
}
