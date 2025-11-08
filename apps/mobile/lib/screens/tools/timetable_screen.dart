import 'dart:async';

import 'package:campus_mesh/models/timetable_model.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/class_alert_service.dart';
import 'package:campus_mesh/services/timetable_service.dart';
import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final _timetableService = TimetableService();
  final _authService = AuthService();
  final _alertService = ClassAlertService();

  TimetableModel? _timetable;
  DayOfWeek _selectedDay = DayOfWeek.monday;
  bool _isLoading = true;
  bool _alertEnabled = true;
  int _alertMinutesBefore = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _authService.initialize();
    final userId = _authService.currentUserId;

    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);

      // Load timetable based on user's department and shift
      if (profile != null && profile.department.isNotEmpty) {
        final timetable = await _timetableService.getTimetableByClass(
          profile.department,
          'Day', // Default shift
        );

        if (mounted) {
          setState(() {
            _timetable = timetable;
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    }

    // Load alert preferences
    unawaited(_loadAlertPreferences());
  }

  Future<void> _loadAlertPreferences() async {
    final enabled = await _alertService.isAlertEnabled();
    final minutes = await _alertService.getAlertMinutesBefore();

    if (mounted) {
      setState(() {
        _alertEnabled = enabled;
        _alertMinutesBefore = minutes;
      });
    }
  }

  void _showAlertSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Class Alert Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Enable Class Alerts'),
                subtitle: const Text('Get notified before classes start'),
                value: _alertEnabled,
                onChanged: (value) async {
                  await _alertService.setAlertEnabled(value);
                  setModalState(() => _alertEnabled = value);
                  setState(() => _alertEnabled = value);
                },
              ),
              const SizedBox(height: 16),
              if (_alertEnabled) ...[
                const Text('Alert time before class:'),
                Slider(
                  value: _alertMinutesBefore.toDouble(),
                  min: 5,
                  max: 30,
                  divisions: 5,
                  label: '$_alertMinutesBefore minutes',
                  onChanged: (value) {
                    setModalState(() => _alertMinutesBefore = value.toInt());
                  },
                  onChangeEnd: (value) async {
                    await _alertService.setAlertMinutesBefore(value.toInt());
                    setState(() => _alertMinutesBefore = value.toInt());
                  },
                ),
                Center(
                  child: Text(
                    '$_alertMinutesBefore minutes before class',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Auto-select current day
    final now = DateTime.now();
    if (_selectedDay == DayOfWeek.monday) {
      _selectedDay = DayOfWeek.values[now.weekday - 1];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Timetable'),
        actions: [
          IconButton(
            icon: Icon(
              _alertEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            onPressed: _showAlertSettings,
            tooltip: 'Alert Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _timetable == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No timetable available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Your class timetable will appear here once it\'s created by the admin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Day selector
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: DayOfWeek.values.length,
                        itemBuilder: (context, index) {
                          final day = DayOfWeek.values[index];
                          final isSelected = day == _selectedDay;
                          final isToday =
                              day == DayOfWeek.values[now.weekday - 1];

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_getDayShortName(day)),
                              selected: isSelected,
                              backgroundColor: isToday ? Colors.blue[50] : null,
                              onSelected: (selected) {
                                setState(() => _selectedDay = day);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // Classes list
                    Expanded(child: _buildDaySchedule(_selectedDay)),
                  ],
                ),
    );
  }

  Widget _buildDaySchedule(DayOfWeek day) {
    final periods = _timetable!.getPeriodsForDay(day);

    if (periods.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.free_breakfast, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No classes today',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: periods.length,
      itemBuilder: (context, index) {
        final period = periods[index];
        final isNow = period.isNow;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isNow ? Colors.green[50] : null,
          child: ListTile(
            leading: Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isNow ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    period.startTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'to',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    period.endTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              period.subject,
              style: TextStyle(
                fontWeight: isNow ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(period.teacherName),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.room, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Room ${period.room}'),
                  ],
                ),
                if (period.notes != null && period.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    period.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            trailing: isNow
                ? const Chip(
                    label: Text('NOW', style: TextStyle(fontSize: 12)),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  )
                : null,
          ),
        );
      },
    );
  }

  String _getDayShortName(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday:
        return 'Mon';
      case DayOfWeek.tuesday:
        return 'Tue';
      case DayOfWeek.wednesday:
        return 'Wed';
      case DayOfWeek.thursday:
        return 'Thu';
      case DayOfWeek.friday:
        return 'Fri';
      case DayOfWeek.saturday:
        return 'Sat';
      case DayOfWeek.sunday:
        return 'Sun';
    }
  }

  @override
  void dispose() {
    _timetableService.dispose();
    super.dispose();
  }
}
