enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class TimetableModel {

  TimetableModel({
    required this.id,
    required this.className,
    required this.department,
    required this.shift,
    required this.periods,
    required this.createdAt,
    this.updatedAt,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> data) {
    final periodsData = data['periods'] as List<dynamic>? ?? [];
    final periods = periodsData
        .map((p) => ClassPeriod.fromJson(p as Map<String, dynamic>))
        .toList();

    return TimetableModel(
      id: data['id'] ?? data[r'$id'] ?? '',
      className: data['class_name'] ?? '',
      department: data['department'] ?? '',
      shift: data['shift'] ?? '',
      periods: periods,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
    );
  }
  final String id;
  final String className; // e.g., "Computer 3rd Year"
  final String department;
  final String shift;
  final List<ClassPeriod> periods;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_name': className,
      'department': department,
      'shift': shift,
      'periods': periods.map((p) => p.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  List<ClassPeriod> getPeriodsForDay(DayOfWeek day) {
    return periods.where((p) => p.day == day).toList();
  }
}

class ClassPeriod {

  ClassPeriod({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.teacherName,
    required this.room,
    this.notes,
  });

  factory ClassPeriod.fromJson(Map<String, dynamic> data) {
    return ClassPeriod(
      day: _parseDay(data['day']),
      startTime: data['start_time'] ?? '',
      endTime: data['end_time'] ?? '',
      subject: data['subject'] ?? '',
      teacherName: data['teacher_name'] ?? '',
      room: data['room'] ?? '',
      notes: data['notes'],
    );
  }
  final DayOfWeek day;
  final String startTime; // e.g., "09:00"
  final String endTime; // e.g., "10:00"
  final String subject;
  final String teacherName;
  final String room;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'day': day.name,
      'start_time': startTime,
      'end_time': endTime,
      'subject': subject,
      'teacher_name': teacherName,
      'room': room,
      'notes': notes,
    };
  }

  static DayOfWeek _parseDay(String? dayStr) {
    switch (dayStr?.toLowerCase()) {
      case 'monday':
        return DayOfWeek.monday;
      case 'tuesday':
        return DayOfWeek.tuesday;
      case 'wednesday':
        return DayOfWeek.wednesday;
      case 'thursday':
        return DayOfWeek.thursday;
      case 'friday':
        return DayOfWeek.friday;
      case 'saturday':
        return DayOfWeek.saturday;
      case 'sunday':
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }

  String get dayName {
    switch (day) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }

  bool get isNow {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;

    // Map weekday to DayOfWeek enum (Monday = 1, Sunday = 7)
    final currentDay = DayOfWeek.values[dayOfWeek - 1];

    if (currentDay != day) return false;

    // Parse time
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    final start = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );
    final end = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    return now.isAfter(start) && now.isBefore(end);
  }
}
