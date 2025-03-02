class ScheduleData {
  int? id;
  int order;
  final int startHour, startMinute, endHour, endMinute;
  final String title, note, day;
  final int userId;
  ScheduleData({
    this.id,
    required this.order,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.title,
    this.note = '',
    required this.day,
    required this.userId,
  });
  factory ScheduleData.fromMap(Map<String, dynamic> map) => ScheduleData(
    id: map['id'],
    userId: map['userId'],
    day: map['day'],
    order: map['scheduleOrder'],
    startHour: map['startHour'],
    startMinute: map['startMinute'],
    endHour: map['endHour'],
    endMinute: map['endMinute'],
    title: map['title'],
    note: map['note'],
  );
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'day': day,
    'startHour': startHour,
    'startMinute': startMinute,
    'endHour': endHour,
    'endMinute': endMinute,
    'title': title,
    'note': note,
    'scheduleOrder': order,
    if (id != null) 'id': id,
  };
}
