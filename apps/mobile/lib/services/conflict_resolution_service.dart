import 'package:flutter/foundation.dart';

/// Conflict resolution strategy
enum ConflictStrategy {
  serverWins, // Server version always wins
  clientWins, // Client version always wins
  newerWins, // Newer timestamp wins
  merge, // Merge both versions
  manual, // Require manual resolution
}

/// Represents a data conflict
class DataConflict<T> {
  final String documentId;
  final T serverVersion;
  final T clientVersion;
  final DateTime serverTimestamp;
  final DateTime clientTimestamp;
  final String conflictType; // 'edit', 'delete', 'create'

  DataConflict({
    required this.documentId,
    required this.serverVersion,
    required this.clientVersion,
    required this.serverTimestamp,
    required this.clientTimestamp,
    required this.conflictType,
  });
}

/// Service to handle simultaneous edit conflicts
/// Note: This is a stub implementation. Full conflict resolution would require
/// custom Appwrite Functions or client-side logic
class ConflictResolutionService {
  static final ConflictResolutionService _instance =
      ConflictResolutionService._internal();
  factory ConflictResolutionService() => _instance;
  ConflictResolutionService._internal();

  final List<DataConflict> _unresolvedConflicts = [];

  /// Default conflict resolution strategy
  ConflictStrategy _defaultStrategy = ConflictStrategy.newerWins;

  /// Get list of unresolved conflicts
  List<DataConflict> get unresolvedConflicts =>
      List.unmodifiable(_unresolvedConflicts);

  /// Set default conflict resolution strategy
  void setDefaultStrategy(ConflictStrategy strategy) {
    _defaultStrategy = strategy;
    if (kDebugMode) {
      print('Default conflict strategy set to: ${strategy.name}');
    }
  }

  /// Update document with conflict detection
  Future<void> updateWithConflictDetection({
    required String collection,
    required String documentId,
    required Map<String, dynamic> updates,
    required DateTime clientTimestamp,
    ConflictStrategy? strategy,
  }) async {
    try {
      // Stub implementation - would implement with Appwrite
      if (kDebugMode) {
        print('Updating document with conflict detection (stub): $collection/$documentId');
        print('Strategy: ${(strategy ?? _defaultStrategy).name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in conflict detection update: $e');
      }
      rethrow;
    }
  }

  /// Resolve conflict based on strategy
  Future<Map<String, dynamic>?> _resolveConflict({
    required String documentId,
    required Map<String, dynamic> serverData,
    required Map<String, dynamic> clientUpdates,
    required DateTime serverTimestamp,
    required DateTime clientTimestamp,
    required ConflictStrategy strategy,
  }) async {
    switch (strategy) {
      case ConflictStrategy.serverWins:
        // Keep server version, discard client updates
        return null; // No updates needed

      case ConflictStrategy.clientWins:
        // Use client updates
        return clientUpdates;

      case ConflictStrategy.newerWins:
        // Use newer timestamp
        if (clientTimestamp.isAfter(serverTimestamp)) {
          return clientUpdates;
        } else {
          return null; // Server is newer
        }

      case ConflictStrategy.merge:
        // Merge both versions (field-level merge)
        return _mergeUpdates(serverData, clientUpdates);

      case ConflictStrategy.manual:
        // Require manual resolution
        return null;
    }
  }

  /// Merge updates at field level
  Map<String, dynamic> _mergeUpdates(
    Map<String, dynamic> serverData,
    Map<String, dynamic> clientUpdates,
  ) {
    final merged = <String, dynamic>{...serverData};

    for (final entry in clientUpdates.entries) {
      final key = entry.key;
      final clientValue = entry.value;

      if (!merged.containsKey(key)) {
        // New field from client
        merged[key] = clientValue;
      } else if (clientValue is Map && merged[key] is Map) {
        // Recursively merge nested maps
        merged[key] = _mergeUpdates(
          merged[key] as Map<String, dynamic>,
          clientValue as Map<String, dynamic>,
        );
      } else if (clientValue is List && merged[key] is List) {
        // Merge lists (combine and deduplicate)
        final serverList = merged[key] as List;
        final clientList = clientValue;
        merged[key] = {...serverList, ...clientList}.toList();
      } else {
        // Use client value for scalar fields
        merged[key] = clientValue;
      }
    }

    return merged;
  }

  /// Manually resolve a conflict
  Future<void> resolveConflict({
    required String documentId,
    required Map<String, dynamic> resolvedData,
  }) async {
    try {
      // Find the conflict
      final conflictIndex = _unresolvedConflicts.indexWhere(
        (c) => c.documentId == documentId,
      );

      if (conflictIndex == -1) {
        throw Exception('Conflict not found: $documentId');
      }

      // Apply resolved data
      // Note: The collection would need to be tracked in DataConflict for this to work
      // For now, this is a placeholder

      // Remove from unresolved list
      _unresolvedConflicts.removeAt(conflictIndex);

      if (kDebugMode) {
        print('Manually resolved conflict for $documentId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resolving conflict: $e');
      }
      rethrow;
    }
  }

  /// Discard a conflict (keep server version)
  void discardConflict(String documentId) {
    _unresolvedConflicts.removeWhere((c) => c.documentId == documentId);

    if (kDebugMode) {
      print('Discarded conflict for $documentId');
    }
  }

  /// Clear all unresolved conflicts
  void clearUnresolvedConflicts() {
    _unresolvedConflicts.clear();

    if (kDebugMode) {
      print('Cleared all unresolved conflicts');
    }
  }

  /// Create versioned update (with optimistic locking)
  Future<void> versionedUpdate({
    required String collection,
    required String documentId,
    required Map<String, dynamic> updates,
    required int expectedVersion,
  }) async {
    try {
      // Stub implementation - would implement with Appwrite
      if (kDebugMode) {
        print('Versioned update (stub) for $documentId, expected version: $expectedVersion');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Versioned update failed: $e');
      }
      rethrow;
    }
  }

  /// Get conflict statistics
  Map<String, dynamic> getStatistics() {
    final conflictsByType = <String, int>{};

    for (final conflict in _unresolvedConflicts) {
      conflictsByType[conflict.conflictType] =
          (conflictsByType[conflict.conflictType] ?? 0) + 1;
    }

    return {
      'unresolvedCount': _unresolvedConflicts.length,
      'conflictsByType': conflictsByType,
      'defaultStrategy': _defaultStrategy.name,
    };
  }
}
