import 'package:campus_mesh/models/timetable_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassAlertService {
  static const String _keyAlertEnabled = 'class_alert_enabled';
  static const String _keyAlertMinutesBefore = 'class_alert_minutes_before';

  // Get alert enabled status
  Future<bool> isAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAlertEnabled) ?? true; // Default enabled
  }

  // Set alert enabled status
  Future<void> setAlertEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlertEnabled, enabled);
  }

  // Get minutes before class to alert
  Future<int> getAlertMinutesBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAlertMinutesBefore) ?? 10; // Default 10 minutes
  }

  // Set minutes before class to alert
  Future<void> setAlertMinutesBefore(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAlertMinutesBefore, minutes);
  }

  // Check if should show alert for a class period
  Future<bool> shouldAlertForClass(ClassPeriod period) async {
    final enabled = await isAlertEnabled();
    if (!enabled) return false;

    final minutesBefore = await getAlertMinutesBefore();
    final now = DateTime.now();

    // Check if it's the right day
    final dayOfWeek = now.weekday;
    final currentDay = DayOfWeek.values[dayOfWeek - 1];
    if (currentDay != period.day) return false;

    // Parse class start time
    final startParts = period.startTime.split(':');
    final classStart = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    // Calculate alert time
    final alertTime = classStart.subtract(Duration(minutes: minutesBefore));

    // Check if now is within 1 minute of alert time
    final diff = now.difference(alertTime).abs();
    return diff.inMinutes == 0;
  }

  // Get next class from timetable
  ClassPeriod? getNextClass(TimetableModel timetable) {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final currentDay = DayOfWeek.values[dayOfWeek - 1];

    // Get today's periods
    final todayPeriods = timetable.getPeriodsForDay(currentDay);
    if (todayPeriods.isEmpty) return null;

    // Find next class
    for (final period in todayPeriods) {
      final startParts = period.startTime.split(':');
      final classStart = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      if (classStart.isAfter(now)) {
        return period;
      }
    }

    return null;
  }

  // Get current class from timetable
  ClassPeriod? getCurrentClass(TimetableModel timetable) {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final currentDay = DayOfWeek.values[dayOfWeek - 1];

    // Get today's periods
    final todayPeriods = timetable.getPeriodsForDay(currentDay);

    for (final period in todayPeriods) {
      if (period.isNow) {
        return period;
      }
    }

    return null;
  }
}
