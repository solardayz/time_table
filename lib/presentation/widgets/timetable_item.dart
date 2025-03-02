// presentation/widgets/timetable_item.dart
import 'package:flutter/material.dart';

class TimeTableItem extends StatelessWidget {
  final int startHour;
  final int startMinute;
  final String title;
  final int endHour;
  final int endMinute;
  final String note;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  TimeTableItem({
    required this.startHour,
    required this.startMinute,
    required this.title,
    required this.endHour,
    required this.endMinute,
    required this.note,
    this.onDelete,
    this.onEdit,
  });

  String formatTime(int hour, int minute) {
    return hour.toString().padLeft(2, '0') + ":" + minute.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              '상세 정보',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('시작시간: ${formatTime(startHour, startMinute)}',
                    style: TextStyle(fontSize: 20)),
                Text('종료시간: ${formatTime(endHour, endMinute)}',
                    style: TextStyle(fontSize: 20)),
                Text('과목: $title', style: TextStyle(fontSize: 20)),
                Text('특이사항: $note', style: TextStyle(fontSize: 20)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('닫기', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      },
      child: Card(
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
              // 첫 번째 행: 시작시간, 과목, 우측 수정/삭제 버튼
              Row(
                children: [
                  Text(
                    formatTime(startHour, startMinute),
                    style: TextStyle(fontSize: 22, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: onEdit,
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
                style: TextStyle(fontSize: 18, color: Colors.deepPurpleAccent, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              // 세 번째 행: 특이사항 (오른쪽 정렬)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  note,
                  style: TextStyle(fontSize: 16, color: Colors.orange, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
