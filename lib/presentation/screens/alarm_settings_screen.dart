import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // DB에서 저장된 알람 오프셋을 불러옵니다.
  void _loadAlarmOffset() async {
    int offset = await DatabaseHelper.instance.getAlarmOffset(widget.userId);
    setState(() {
      alarmOffset = offset;
      _textController.text = alarmOffset.toString();
    });
  }

  // 사용자가 선택한 알람 오프셋을 DB에 저장하고, Snackbar로 메시지를 표시 후 화면을 닫습니다.
  void _saveAlarmOffset() async {
    await DatabaseHelper.instance.insertOrUpdateAlarm(widget.userId, alarmOffset);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$alarmOffset 분전에 울림으로 변경되어 있습니다.')),
    );
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop(alarmOffset);
    });
  }

  // 텍스트 필드의 값이 변경될 때, 값을 1~60 사이로 클램핑하여 슬라이더와 변수 업데이트
  void _updateAlarmOffsetFromText(String value) {
    int? parsed = int.tryParse(value);
    if (parsed != null) {
      // 클램핑: 최소 1, 최대 60
      int clamped = parsed.clamp(1, 60) as int;
      setState(() {
        alarmOffset = clamped;
        // 텍스트 필드에 클램핑된 값을 다시 반영
        _textController.text = clamped.toString();
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
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
          '$alarmOffset 분전에 울림',
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
            // 슬라이더
            Slider(
              value: alarmOffset.toDouble(),
              min: 1, // 최소 1분부터 선택
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
            // 가운데 구분선과 함께 알람 오프셋을 표시하는 위젯
            buildAlarmOffsetDisplay(),
            SizedBox(height: 16),
            // 하단 텍스트 필드 (1~60 범위의 숫자만 입력 가능)
            TextFormField(
              controller: _textController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
