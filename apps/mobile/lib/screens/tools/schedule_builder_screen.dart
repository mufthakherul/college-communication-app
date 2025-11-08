import 'package:flutter/material.dart';

class ScheduleBuilderScreen extends StatefulWidget {
  const ScheduleBuilderScreen({super.key});

  @override
  State<ScheduleBuilderScreen> createState() => _ScheduleBuilderScreenState();
}

class _ScheduleBuilderScreenState extends State<ScheduleBuilderScreen> {
  final List<ScheduleClass> _schedule = [];
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedDay = 'Monday';
  String _selectedTime = '09:00 AM';
  String _selectedDuration = '1 Hour';

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  final List<String> _times = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];
  final List<String> _durations = ['30 Min', '1 Hour', '1.5 Hours', '2 Hours'];

  void _addClass() {
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter subject name')),
      );
      return;
    }

    setState(() {
      _schedule.add(
        ScheduleClass(
          subject: _subjectController.text,
          day: _selectedDay,
          time: _selectedTime,
          duration: _selectedDuration,
          location: _locationController.text,
          color: _getColorForDay(_selectedDay),
        ),
      );
      _subjectController.clear();
      _locationController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Class added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteClass(int index) {
    setState(() => _schedule.removeAt(index));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Class removed')));
  }

  Color _getColorForDay(String day) {
    const colors = {
      'Monday': Color(0xFFFF6B6B),
      'Tuesday': Color(0xFF4ECDC4),
      'Wednesday': Color(0xFFFFE66D),
      'Thursday': Color(0xFF95E1D3),
      'Friday': Color(0xFFC7CEEA),
      'Saturday': Color(0xFFB19CD9),
    };
    return colors[day] ?? Colors.blue;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Builder'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add class section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Class',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Subject name
                    TextField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject Name',
                        hintText: 'e.g., Mathematics',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.book),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Location
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location/Room',
                        hintText: 'e.g., A-101',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Day, Time, Duration
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            'Day',
                            _selectedDay,
                            _days,
                            (value) => setState(() => _selectedDay = value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            'Time',
                            _selectedTime,
                            _times,
                            (value) => setState(() => _selectedTime = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      'Duration',
                      _selectedDuration,
                      _durations,
                      (value) => setState(() => _selectedDuration = value),
                    ),
                    const SizedBox(height: 16),

                    // Add button
                    ElevatedButton.icon(
                      onPressed: _addClass,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Class'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Schedule view
            if (_schedule.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No classes scheduled',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                'Your Schedule (${_schedule.length} classes)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._buildScheduleView(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScheduleView() {
    final grouped = <String, List<ScheduleClass>>{};
    for (final cls in _schedule) {
      grouped.putIfAbsent(cls.day, () => []).add(cls);
    }

    return _days
        .where((day) => grouped.containsKey(day))
        .map((day) => _buildDaySection(day, grouped[day]!))
        .toList();
  }

  Widget _buildDaySection(String day, List<ScheduleClass> classes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ...classes.asMap().entries.map((entry) {
          final index = entry.key;
          final cls = entry.value;
          return _buildClassCard(cls, index);
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildClassCard(ScheduleClass cls, int index) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: cls.color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Icon(Icons.class_, color: cls.color)),
        ),
        title: Text(
          cls.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${cls.time} • ${cls.duration}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (cls.location.isNotEmpty)
              Text(
                '📍 ${cls.location}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteClass(_schedule.indexOf(cls)),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }
}

class ScheduleClass {
  final String subject;
  final String day;
  final String time;
  final String duration;
  final String location;
  final Color color;

  ScheduleClass({
    required this.subject,
    required this.day,
    required this.time,
    required this.duration,
    required this.location,
    required this.color,
  });
}
