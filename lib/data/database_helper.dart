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
    // 사용자 테이블
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    // 스케줄 테이블 (userId 외래키 포함)
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

  Future<int> updateUser(int id, String newName) async {
    Database db = await instance.database;
    return await db.update('user', {'name': newName}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    // 사용자를 삭제할 때 해당 사용자의 스케줄도 함께 삭제
    await db.delete('schedule', where: 'userId = ?', whereArgs: [id]);
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

  Future<int> updateSchedule(int id, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.update('schedule', row, where: 'id = ?', whereArgs: [id]);
  }
}
