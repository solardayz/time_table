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
    // 팝업 관련 onLongPress 제거
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Color(0xFFFFFDE7), Color(0xFFFFF9C4)], // 파스텔 노랑 그라데이션
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.brown),
                SizedBox(width: 8),
                Text(
                  "${formatTime(startHour, startMinute)} - ${formatTime(endHour, endMinute)}",
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                ),
                Spacer(),
                if (onEdit != null)
                  IconButton(icon: Icon(Icons.edit, color: Colors.green), onPressed: onEdit),
                if (onDelete != null)
                  IconButton(icon: Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: onDelete),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'NanumPen',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            if (note.isNotEmpty) ...[
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  note,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

  }
}
