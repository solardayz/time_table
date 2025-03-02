import 'package:flutter/material.dart';
import 'package:time_table/data/database_helper.dart';

class AlarmSettingsScreen extends StatefulWidget {
  final int userId;
  AlarmSettingsScreen({required this.userId});
  @override
  _AlarmSettingsScreenState createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  int alarmOffset = 20; // 기본값 20분 전
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _loadAlarmOffset();
    _textController = TextEditingController(text: alarmOffset.toString());
  }

  void _loadAlarmOffset() async {
    int offset = await DatabaseHelper.instance.getAlarmOffset(widget.userId);
    setState(() {
      alarmOffset = offset;
      _textController.text = alarmOffset.toString();
    });
  }

  void _saveAlarmOffset() async {
    await DatabaseHelper.instance.insertOrUpdateAlarm(widget.userId, alarmOffset);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$alarmOffset 분전에 울림으로 변경되어 있습니다.')),
    );
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop(alarmOffset);
    });
  }

  void _updateAlarmOffsetFromText(String value) {
    int? parsed = int.tryParse(value);
    if (parsed != null && parsed >= 1 && parsed <= 60) {
      setState(() {
        alarmOffset = parsed;
      });
    }
  }

  Widget buildAlarmOffsetDisplay() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            endIndent: 8,
          ),
        ),
        Text(
          '$alarmOffset 분전',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 8,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
              min: 1,
              max: 60,
              divisions: 60,
              label: '$alarmOffset 분 전',
              onChanged: (value) {
                setState(() {
                  alarmOffset = value.toInt();
                  _textController.text = alarmOffset.toString();
                });
              },
            ),
            SizedBox(height: 16),
            // 여기서 buildAlarmOffsetDisplay 위젯 사용
            buildAlarmOffsetDisplay(),
            SizedBox(height: 16),
            TextField(
              controller: _textController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '알람 시간(분 전)',
                border: OutlineInputBorder(),
              ),
              onChanged: _updateAlarmOffsetFromText,
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
