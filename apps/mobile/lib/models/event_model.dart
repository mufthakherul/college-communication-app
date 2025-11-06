enum EventType { seminar, workshop, exam, sports, cultural, other }

class EventModel { // 'all', 'students', 'teachers', specific departments

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.venue,
    required this.organizer,
    this.imageUrl,
    this.isRegistrationRequired = false,
    this.maxParticipants,
    this.currentParticipants = 0,
    this.registrationLink,
    required this.createdAt,
    this.updatedAt,
    this.targetAudience = const ['all'],
  });

  factory EventModel.fromJson(Map<String, dynamic> data) {
    return EventModel(
      id: data['id'] ?? data[r'$id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: _parseType(data['type']),
      startDate: DateTime.parse(data['start_date']),
      endDate: DateTime.parse(data['end_date']),
      venue: data['venue'] ?? '',
      organizer: data['organizer'] ?? '',
      imageUrl: data['image_url'],
      isRegistrationRequired: data['is_registration_required'] ?? false,
      maxParticipants: data['max_participants'],
      currentParticipants: data['current_participants'] ?? 0,
      registrationLink: data['registration_link'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
      targetAudience: data['target_audience'] != null
          ? List<String>.from(data['target_audience'])
          : ['all'],
    );
  }
  final String id;
  final String title;
  final String description;
  final EventType type;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final String organizer;
  final String? imageUrl;
  final bool isRegistrationRequired;
  final int? maxParticipants;
  final int currentParticipants;
  final String? registrationLink;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>
      targetAudience;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'venue': venue,
      'organizer': organizer,
      'image_url': imageUrl,
      'is_registration_required': isRegistrationRequired,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'registration_link': registrationLink,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'target_audience': targetAudience,
    };
  }

  static EventType _parseType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'seminar':
        return EventType.seminar;
      case 'workshop':
        return EventType.workshop;
      case 'exam':
        return EventType.exam;
      case 'sports':
        return EventType.sports;
      case 'cultural':
        return EventType.cultural;
      default:
        return EventType.other;
    }
  }

  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isPast => DateTime.now().isAfter(endDate);
  bool get isRegistrationOpen =>
      isRegistrationRequired &&
      (maxParticipants == null || currentParticipants < maxParticipants!);

  String get typeDisplayName {
    switch (type) {
      case EventType.seminar:
        return 'Seminar';
      case EventType.workshop:
        return 'Workshop';
      case EventType.exam:
        return 'Exam';
      case EventType.sports:
        return 'Sports';
      case EventType.cultural:
        return 'Cultural';
      case EventType.other:
        return 'Other';
    }
  }

  int get daysUntilStart => startDate.difference(DateTime.now()).inDays;
}
