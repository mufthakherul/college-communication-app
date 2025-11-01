import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:campus_mesh/models/event_model.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/appwrite_config.dart';

class EventsService {
  final _appwrite = AppwriteService();
  final _authService = AuthService();

  StreamController<List<EventModel>>? _eventsController;
  Timer? _pollingTimer;

  String? get _currentUserId => _authService.currentUserId;

  // Get all events (polling-based stream)
  Stream<List<EventModel>> getEvents() {
    _eventsController ??= StreamController<List<EventModel>>.broadcast(
      onListen: () => _startPolling(),
      onCancel: () => _stopPolling(),
    );
    return _eventsController!.stream;
  }

  void _startPolling() {
    _fetchEvents();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _fetchEvents());
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchEvents() async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.eventsCollectionId,
        queries: [
          Query.orderDesc('start_date'),
          Query.limit(100),
        ],
      );

      final events =
          docs.documents.map((doc) => EventModel.fromJson(doc.data)).toList();

      _eventsController?.add(events);
    } catch (e) {
      debugPrint('Error fetching events: $e');
      _eventsController?.addError(e);
    }
  }

  // Get upcoming events
  Future<List<EventModel>> getUpcomingEvents() async {
    try {
      final now = DateTime.now().toIso8601String();

      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.eventsCollectionId,
        queries: [
          Query.greaterThan('start_date', now),
          Query.orderAsc('start_date'),
          Query.limit(50),
        ],
      );

      return docs.documents
          .map((doc) => EventModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching upcoming events: $e');
      return [];
    }
  }

  // Get events by type
  Future<List<EventModel>> getEventsByType(EventType type) async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.eventsCollectionId,
        queries: [
          Query.equal('type', type.name),
          Query.orderDesc('start_date'),
          Query.limit(100),
        ],
      );

      return docs.documents
          .map((doc) => EventModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching events by type: $e');
      return [];
    }
  }

  // Get single event
  Future<EventModel?> getEvent(String eventId) async {
    try {
      final doc = await _appwrite.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.eventsCollectionId,
        documentId: eventId,
      );

      return EventModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('Error fetching event: $e');
      return null;
    }
  }

  // Create event (teacher/admin only)
  Future<EventModel?> createEvent(EventModel event) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.eventsCollectionId,
        documentId: ID.unique(),
        data: event.toJson(),
      );

      _fetchEvents();

      return EventModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('Error creating event: $e');
      return null;
    }
  }

  // Update event (teacher/admin only)
  Future<bool> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.eventsCollectionId,
        documentId: eventId,
        data: updates,
      );

      _fetchEvents();

      return true;
    } catch (e) {
      debugPrint('Error updating event: $e');
      return false;
    }
  }

  // Delete event (admin only)
  Future<bool> deleteEvent(String eventId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _appwrite.databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.eventsCollectionId,
        documentId: eventId,
      );

      _fetchEvents();

      return true;
    } catch (e) {
      debugPrint('Error deleting event: $e');
      return false;
    }
  }

  // Register for event
  Future<bool> registerForEvent(String eventId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final event = await getEvent(eventId);
      if (event == null) return false;

      // Increment participant count
      await updateEvent(eventId, {
        'current_participants': event.currentParticipants + 1,
      });

      return true;
    } catch (e) {
      debugPrint('Error registering for event: $e');
      return false;
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    _eventsController?.close();
  }
}
