import 'package:campus_mesh/models/event_model.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/events_service.dart';
import 'package:flutter/material.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _eventsService = EventsService();
  final _authService = AuthService();

  UserModel? _currentUser;
  EventType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    await _authService.initialize();
    final userId = _authService.currentUserId;
    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);
      if (mounted) {
        setState(() => _currentUser = profile);
      }
    }
  }

  bool get _canCreateEvents {
    return _currentUser?.role == UserRole.admin ||
        _currentUser?.role == UserRole.teacher;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('College Events')),
      body: Column(
        children: [
          // Event type filters
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('All Events'),
                  selected: _selectedType == null,
                  onSelected: (selected) {
                    setState(() => _selectedType = null);
                  },
                ),
                const SizedBox(width: 8),
                ...EventType.values.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getTypeName(type)),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() => _selectedType = selected ? type : null);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Events list
          Expanded(
            child: _selectedType == null
                ? _buildAllEvents()
                : _buildTypeEvents(_selectedType!),
          ),
        ],
      ),
      floatingActionButton: _canCreateEvents
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Navigate to create event screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create event feature coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
            )
          : null,
    );
  }

  Widget _buildAllEvents() {
    return StreamBuilder<List<EventModel>>(
      stream: _eventsService.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: SelectableText('Error: ${snapshot.error}'));
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No events yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _buildEventCard(events[index]);
          },
        );
      },
    );
  }

  Widget _buildTypeEvents(EventType type) {
    return FutureBuilder<List<EventModel>>(
      future: _eventsService.getEventsByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: SelectableText('Error: ${snapshot.error}'));
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No ${_getTypeName(type).toLowerCase()} events',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _buildEventCard(events[index]);
          },
        );
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    final isUpcoming = event.isUpcoming;
    final isOngoing = event.isOngoing;
    final isPast = event.isPast;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showEventDetails(event);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  event.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.event, size: 48),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(event.type),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.typeDisplayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(event.startDate),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (isUpcoming) ...[
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'In ${event.daysUntilStart} days',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (isOngoing) ...[
                        const Icon(
                          Icons.play_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Ongoing',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (isPast) ...[
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (event.isRegistrationRequired &&
                          event.isRegistrationOpen) ...[
                        const Spacer(),
                        const Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.currentParticipants}/${event.maxParticipants ?? "∞"}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              if (event.imageUrl != null) const SizedBox(height: 16),
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getTypeColor(event.type),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  event.typeDisplayName,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                event.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Start Date', _formatDateTime(event.startDate)),
              _buildDetailRow('End Date', _formatDateTime(event.endDate)),
              _buildDetailRow('Venue', event.venue),
              _buildDetailRow('Organizer', event.organizer),
              if (event.isRegistrationRequired) ...[
                _buildDetailRow(
                  'Registration',
                  event.isRegistrationOpen ? 'Open' : 'Closed',
                ),
                if (event.maxParticipants != null)
                  _buildDetailRow(
                    'Participants',
                    '${event.currentParticipants}/${event.maxParticipants}',
                  ),
              ],
              const SizedBox(height: 24),
              if (event.isRegistrationRequired && event.isRegistrationOpen)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final success = await _eventsService.registerForEvent(
                        event.id,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Successfully registered!'
                                  : 'Registration failed',
                            ),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.how_to_reg),
                    label: const Text('Register for Event'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeName(EventType type) {
    switch (type) {
      case EventType.seminar:
        return 'Seminars';
      case EventType.workshop:
        return 'Workshops';
      case EventType.exam:
        return 'Exams';
      case EventType.sports:
        return 'Sports';
      case EventType.cultural:
        return 'Cultural';
      case EventType.other:
        return 'Other';
    }
  }

  Color _getTypeColor(EventType type) {
    switch (type) {
      case EventType.seminar:
        return Colors.blue;
      case EventType.workshop:
        return Colors.green;
      case EventType.exam:
        return Colors.red;
      case EventType.sports:
        return Colors.orange;
      case EventType.cultural:
        return Colors.purple;
      case EventType.other:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _eventsService.dispose();
    super.dispose();
  }
}
