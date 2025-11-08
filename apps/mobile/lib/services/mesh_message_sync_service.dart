import 'dart:async';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/local_message_database.dart';
import 'package:campus_mesh/services/mesh_network_service.dart';
import 'package:flutter/foundation.dart';

/// Syncs pending P2P messages over the mesh network when peers are nearby.
class MeshMessageSyncService {
  factory MeshMessageSyncService() => _instance;
  MeshMessageSyncService._internal();
  static final MeshMessageSyncService _instance =
      MeshMessageSyncService._internal();

  final _mesh = MeshNetworkService();
  final _localDb = LocalMessageDatabase();
  final _auth = AuthService();

  final _recentlySent = <String, DateTime>{};
  Timer? _timer;
  StreamSubscription<MeshMessage>? _meshSub;

  Future<void> initialize() async {
    // Listen for incoming mesh chat messages
    _meshSub = _mesh.messageStream.listen(
      _handleIncomingMeshMessage,
      onError: (e) {
        if (kDebugMode) {
          debugPrint('Mesh message stream error: $e');
        }
      },
    );

    // Periodically try sending pending messages
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        await _sendPendingToNearby();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Mesh pending send error: $e');
        }
      }
    });
  }

  Future<void> dispose() async {
    await _meshSub?.cancel();
    _meshSub = null;
    _timer?.cancel();
    _timer = null;
    _recentlySent.clear();
  }

  void _handleIncomingMeshMessage(MeshMessage msg) async {
    try {
      if (msg.type != 'chat.message') return;
      final me = _auth.currentUserId;
      if (me == null) return;

      final payload = msg.payload;
      final recipientId = payload['recipient_id'] as String?;
      if (recipientId != me) return; // Not for me

      // Save to local DB so it appears in conversation even offline
      await _localDb.saveMessage({
        'id': payload['id'] as String? ?? msg.id,
        'sender_id': payload['sender_id'] as String? ?? msg.senderId,
        'recipient_id': recipientId,
        'content': payload['content'] as String? ?? '',
        'type': payload['type'] as String? ?? 'text',
        'is_group_message': 0,
        'group_id': null,
        'created_at':
            payload['created_at'] as String? ?? msg.timestamp.toIso8601String(),
        'sync_status': 'pending', // still needs server sync later
        'approval_status': null,
        'retry_count': 0,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to handle incoming mesh message: $e');
      }
    }
  }

  Future<void> _sendPendingToNearby() async {
    if (!_mesh.isActive) return;
    final me = _auth.currentUserId;
    if (me == null) return;

    // Get nearby connected nodes
    final nodes = _mesh.connectedNodes;
    if (nodes.isEmpty) return;

    final pending = await _localDb.getPendingMessages();
    for (final m in pending) {
      // Only P2P messages
      final isGroup = (m['is_group_message'] as int? ?? 0) == 1;
      if (isGroup) continue;

      final recipientId = m['recipient_id'] as String?;
      if (recipientId == null) continue;

      // Skip if not connected to recipient
      final node = nodes.firstWhere(
        (n) => n.id == recipientId,
        orElse: () => null as dynamic,
      );
      if (node == null) continue;

      final id =
          m['id'] as String? ?? '${DateTime.now().millisecondsSinceEpoch}';

      // Throttle duplicate sends
      final last = _recentlySent[id];
      if (last != null &&
          DateTime.now().difference(last) < const Duration(minutes: 2)) {
        continue;
      }

      final meshMsg = MeshMessage(
        id: id,
        senderId: me,
        type: 'chat.message',
        payload: {
          'id': id,
          'sender_id': me,
          'recipient_id': recipientId,
          'content': m['content'],
          'type': m['type'],
          'created_at': m['created_at'],
        },
      );

      try {
        await _mesh.sendMessage(recipientId, meshMsg);
        _recentlySent[id] = DateTime.now();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to send mesh message $id: $e');
        }
      }
    }
  }
}
