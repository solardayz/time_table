import 'package:flutter/material.dart';
import 'package:time_table/constants.dart';
import 'package:time_table/data/database_helper.dart';

class AlarmSettingsScreen extends StatefulWidget {
  final int userId;
  AlarmSettingsScreen({required this.userId});
  @override
  _AlarmSettingsScreenState createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  int alarmOffset = 20; // 기본값 20분 전

  @override
  void initState() {
    super.initState();
    _loadAlarmOffset();
  }

  // DB에서 저장된 알람 오프셋을 불러옵니다.
  void _loadAlarmOffset() async {
    int offset = await DatabaseHelper.instance.getAlarmOffset(widget.userId);
    setState(() {
      alarmOffset = offset;
    });
  }

  // 사용자가 선택한 알람 오프셋을 DB에 저장하고, Snackbar로 메시지를 표시합니다.
  void _saveAlarmOffset() async {
    await DatabaseHelper.instance.insertOrUpdateAlarm(widget.userId, alarmOffset);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$alarmOffset 분전에 울림으로 변경되어 있습니다.')),
    );
    // 잠시 후 화면을 닫으며 값을 반환합니다.
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop(alarmOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("알람 설정"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '종료 몇 분 전에 알람을 울릴까요?',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Slider(
              value: alarmOffset.toDouble(),
              min: 0,
              max: 60,
              divisions: 60,
              label: '$alarmOffset 분 전',
              onChanged: (value) {
                setState(() {
                  alarmOffset = value.toInt();
                });
              },
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                '$alarmOffset 분 전',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _saveAlarmOffset,
                child: Text('저장', style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
