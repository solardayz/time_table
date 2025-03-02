import 'package:flutter/material.dart';
import 'package:time_table/constants.dart';
import 'package:time_table/data/database_helper.dart';
import 'package:time_table/domain/models/schedule_data.dart';

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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newSchedule = ScheduleData(
                      order: 0,
                      startHour: int.parse(_startHourController.text),
                      startMinute: int.parse(_startMinuteController.text),
                      endHour: int.parse(_endHourController.text),
                      endMinute: int.parse(_endMinuteController.text),
                      title: _subjectController.text,
                      note: _noteController.text,
                      day: _selectedDay,
                      userId: widget.userId,
                    );
                    List<ScheduleData> currentSchedules =
                    List<ScheduleData>.from(globalScheduleMap[_selectedDay] ?? []);
                    newSchedule.order = currentSchedules.length + 1;
                    currentSchedules.add(newSchedule);
                    globalScheduleMap[_selectedDay] = currentSchedules;
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
