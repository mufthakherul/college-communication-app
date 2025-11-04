import 'dart:async';
import 'package:flutter/material.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isPomodoroMode = true;

  // Pomodoro settings
  int _workMinutes = 25;
  int _breakMinutes = 5;
  bool _isWorkSession = true;
  int _completedPomodoros = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;

        // Check if Pomodoro session completed
        if (_isPomodoroMode) {
          final targetSeconds =
              _isWorkSession ? _workMinutes * 60 : _breakMinutes * 60;

          if (_seconds >= targetSeconds) {
            _completeSession();
          }
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_isWorkSession) {
        _completedPomodoros++;
      }
      _isWorkSession = !_isWorkSession;
      _seconds = 0;
    });

    // Show notification
    _showSessionCompleteDialog();
  }

  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _isWorkSession ? 'Break Complete!' : 'Work Session Complete!',
        ),
        content: Text(
          _isWorkSession
              ? 'Great job! Time for a break.'
              : 'Break over! Ready to focus again?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startTimer();
            },
            child: const Text('Start Next Session'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mode toggle
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Pomodoro'),
                  icon: Icon(Icons.timer),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Stopwatch'),
                  icon: Icon(Icons.access_time),
                ),
              ],
              selected: {_isPomodoroMode},
              onSelectionChanged: (Set<bool> newSelection) {
                if (!_isRunning) {
                  setState(() {
                    _isPomodoroMode = newSelection.first;
                    _resetTimer();
                  });
                }
              },
            ),
            const SizedBox(height: 48),

            // Session indicator for Pomodoro
            if (_isPomodoroMode) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _isWorkSession ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _isWorkSession ? 'Work Session' : 'Break Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isWorkSession ? Colors.red : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Completed Pomodoros: $_completedPomodoros',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],

            // Timer display
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 8,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_seconds),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isPomodoroMode) ...[
                      const SizedBox(height: 8),
                      Text(
                        _isWorkSession
                            ? 'of $_workMinutes min'
                            : 'of $_breakMinutes min',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow, size: 32),
                    label: const Text('Start', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause, size: 32),
                    label: const Text('Pause', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh, size: 32),
                  label: const Text('Reset', style: TextStyle(fontSize: 18)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pomodoro Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Work Duration'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_workMinutes > 5) {
                        setState(() => _workMinutes -= 5);
                      }
                    },
                  ),
                  Text('$_workMinutes min'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_workMinutes < 60) {
                        setState(() => _workMinutes += 5);
                      }
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Break Duration'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_breakMinutes > 5) {
                        setState(() => _breakMinutes -= 5);
                      }
                    },
                  ),
                  Text('$_breakMinutes min'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_breakMinutes < 30) {
                        setState(() => _breakMinutes += 5);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
