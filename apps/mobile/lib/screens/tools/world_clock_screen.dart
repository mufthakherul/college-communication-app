import 'package:flutter/material.dart';
import 'dart:async';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  final List<TimeZoneInfo> _timeZones = [
    TimeZoneInfo('Dhaka', 'Asia/Dhaka', 6, '🇧🇩'),
    TimeZoneInfo('London', 'Europe/London', 0, '🇬🇧'),
    TimeZoneInfo('New York', 'America/New_York', -5, '🇺🇸'),
    TimeZoneInfo('Los Angeles', 'America/Los_Angeles', -8, '🇺🇸'),
    TimeZoneInfo('Tokyo', 'Asia/Tokyo', 9, '🇯🇵'),
    TimeZoneInfo('Sydney', 'Australia/Sydney', 11, '🇦🇺'),
    TimeZoneInfo('Dubai', 'Asia/Dubai', 4, '🇦🇪'),
    TimeZoneInfo('Singapore', 'Asia/Singapore', 8, '🇸🇬'),
    TimeZoneInfo('Paris', 'Europe/Paris', 1, '🇫🇷'),
    TimeZoneInfo('Moscow', 'Europe/Moscow', 3, '🇷🇺'),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime _getTimeForZone(TimeZoneInfo zone) {
    // Simple UTC offset calculation (doesn't account for DST)
    final utcTime = _currentTime.toUtc();
    return utcTime.add(Duration(hours: zone.utcOffset));
  }

  String _getTimeOfDay(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }

  IconData _getTimeIcon(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) return Icons.wb_sunny;
    if (hour >= 12 && hour < 17) return Icons.wb_sunny_outlined;
    if (hour >= 17 && hour < 21) return Icons.wb_twilight;
    return Icons.nightlight_round;
  }

  Color _getTimeColor(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) return Colors.orange;
    if (hour >= 12 && hour < 17) return Colors.amber;
    if (hour >= 17 && hour < 21) return Colors.deepOrange;
    return Colors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
      ),
      body: Column(
        children: [
          // Local Time Display
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Local Time (Dhaka)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(_currentTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_currentTime),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Time Zones List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _timeZones.length,
              itemBuilder: (context, index) {
                final zone = _timeZones[index];
                final zoneTime = _getTimeForZone(zone);
                final timeOfDay = _getTimeOfDay(zoneTime);
                final icon = _getTimeIcon(zoneTime);
                final color = _getTimeColor(zoneTime);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      child: Icon(icon, color: color),
                    ),
                    title: Row(
                      children: [
                        Text(
                          zone.flag,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          zone.city,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '$timeOfDay • UTC${zone.utcOffset >= 0 ? '+' : ''}${zone.utcOffset}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(zoneTime),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatShortDate(zoneTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _formatDate(DateTime time) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${days[time.weekday - 1]}, ${months[time.month - 1]} ${time.day}, ${time.year}';
  }

  String _formatShortDate(DateTime time) {
    return '${time.day}/${time.month}/${time.year}';
  }
}

class TimeZoneInfo {
  final String city;
  final String timezone;
  final int utcOffset;
  final String flag;

  TimeZoneInfo(this.city, this.timezone, this.utcOffset, this.flag);
}
