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
    return Card(
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
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
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
              style: TextStyle(
                fontSize: 18,
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            // 세 번째 행: 특이사항 (오른쪽 정렬)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                note,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
