import 'package:flutter/material.dart';
import 'data/database_helper.dart';
import 'presentation/screens/user_select_screen.dart';

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
