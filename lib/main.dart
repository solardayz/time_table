import 'package:flutter/material.dart';
import 'data/database_helper.dart';
import 'data/services/notification_service.dart';
import 'presentation/screens/user_select_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initializeDatabase();
  await NotificationService().initialize(); // awesome_notifications 초기화
  runApp(const TimeTableApp());
}

class TimeTableApp extends StatelessWidget {
  const TimeTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '말랑 시간표',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'NanumPen', // pubspec.yaml에 등록해둬야 함
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink.shade100, // 말랑 파스텔 핑크
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 20),
          labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: UserSelectScreen(),
    );
  }
}
