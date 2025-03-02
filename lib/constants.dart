import 'package:time_table/domain/models/schedule_data.dart';

const List<String> globalDays = ['월', '화', '수', '목', '금', '토', '일'];

Map<String, List<ScheduleData>> globalScheduleMap = {
  '월': [
    ScheduleData(order: 1, startHour: 8, startMinute: 40, endHour: 13, endMinute: 40, title: '학교', note: '정규 수업', day: '월', userId: 0),
    ScheduleData(order: 2, startHour: 14, startMinute: 34, endHour: 15, endMinute: 15, title: '구몬학습', note: '온라인 학습', day: '월', userId: 0),
    ScheduleData(order: 3, startHour: 16, startMinute: 0, endHour: 18, endMinute: 25, title: '늘푸른수학', note: '보충 수업', day: '월', userId: 0),
  ],
  '화': [
    ScheduleData(order: 1, startHour: 9, startMinute: 0, endHour: 10, endMinute: 30, title: '수학', note: '문제 풀이', day: '화', userId: 0),
    ScheduleData(order: 2, startHour: 11, startMinute: 0, endHour: 12, endMinute: 0, title: '영어', note: '독해', day: '화', userId: 0),
    ScheduleData(order: 3, startHour: 13, startMinute: 30, endHour: 15, endMinute: 0, title: '과학', note: '실험', day: '화', userId: 0),
  ],
  '수': [
    ScheduleData(order: 1, startHour: 8, startMinute: 50, endHour: 10, endMinute: 20, title: '음악', note: '연습', day: '수', userId: 0),
    ScheduleData(order: 2, startHour: 10, startMinute: 30, endHour: 12, endMinute: 0, title: '미술', note: '그림', day: '수', userId: 0),
    ScheduleData(order: 3, startHour: 13, startMinute: 0, endHour: 14, endMinute: 30, title: '체육', note: '운동', day: '수', userId: 0),
  ],
  '목': [
    ScheduleData(order: 1, startHour: 9, startMinute: 10, endHour: 10, endMinute: 50, title: '국어', note: '독서', day: '목', userId: 0),
    ScheduleData(order: 2, startHour: 11, startMinute: 0, endHour: 12, endMinute: 30, title: '역사', note: '토론', day: '목', userId: 0),
    ScheduleData(order: 3, startHour: 13, startMinute: 20, endHour: 15, endMinute: 0, title: '사회', note: '프로젝트', day: '목', userId: 0),
  ],
  '금': [
    ScheduleData(order: 1, startHour: 8, startMinute: 30, endHour: 10, endMinute: 0, title: '수학', note: '복습', day: '금', userId: 0),
    ScheduleData(order: 2, startHour: 10, startMinute: 10, endHour: 11, endMinute: 40, title: '영어', note: '어휘', day: '금', userId: 0),
    ScheduleData(order: 3, startHour: 12, startMinute: 0, endHour: 13, endMinute: 30, title: '과학', note: '퀴즈', day: '금', userId: 0),
  ],
  '토': [
    ScheduleData(order: 1, startHour: 10, startMinute: 0, endHour: 12, endMinute: 0, title: '미술', note: '자유 활동', day: '토', userId: 0),
    ScheduleData(order: 2, startHour: 13, startMinute: 0, endHour: 15, endMinute: 0, title: '체육', note: '축구', day: '토', userId: 0),
  ],
  '일': [
    ScheduleData(order: 1, startHour: 11, startMinute: 0, endHour: 12, endMinute: 30, title: '독서', note: '자기계발', day: '일', userId: 0),
    ScheduleData(order: 2, startHour: 14, startMinute: 0, endHour: 16, endMinute: 0, title: '영화', note: '가족과 함께', day: '일', userId: 0),
  ],
};
