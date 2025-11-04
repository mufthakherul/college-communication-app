import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:campus_mesh/services/app_logger_service.dart';

/// WebRTC signaling message type
enum SignalingMessageType { offer, answer, candidate, bye }

/// WebRTC signaling message
class SignalingMessage {
  final String from;
  final String to;
  final SignalingMessageType type;
  final Map<String, dynamic> payload;

  SignalingMessage({
    required this.from,
    required this.to,
    required this.type,
    required this.payload,
  });

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'type': type.name,
        'payload': payload,
      };

  factory SignalingMessage.fromJson(Map<String, dynamic> json) =>
      SignalingMessage(
        from: json['from'] as String,
        to: json['to'] as String,
        type: SignalingMessageType.values.firstWhere(
          (t) => t.name == json['type'],
        ),
        payload: json['payload'] as Map<String, dynamic>,
      );
}

/// WebRTC connection state
enum WebRTCConnectionState {
  disconnected,
  connecting,
  connected,
  failed,
  closed,
}

/// WebRTC peer connection wrapper
class WebRTCPeerConnection {
  final String peerId;
  final RTCPeerConnection connection;
  final RTCDataChannel? dataChannel;
  WebRTCConnectionState state = WebRTCConnectionState.disconnected;
  DateTime? connectedAt;
  int bytesSent = 0;
  int bytesReceived = 0;

  WebRTCPeerConnection({
    required this.peerId,
    required this.connection,
    this.dataChannel,
  });

  Future<void> close() async {
    await dataChannel?.close();
    await connection.close();
    state = WebRTCConnectionState.closed;
  }
}

/// WebRTC signaling service for P2P connections
/// Provides reliable data channels for mesh networking
class WebRTCSignalingService {
  static final WebRTCSignalingService _instance =
      WebRTCSignalingService._internal();
  factory WebRTCSignalingService() => _instance;
  WebRTCSignalingService._internal();

  final Map<String, WebRTCPeerConnection> _connections = {};
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _signalingController = StreamController<SignalingMessage>.broadcast();
  final _connectionStateController =
      StreamController<Map<String, dynamic>>.broadcast();

  String? _localPeerId;
  bool _isInitialized = false;

  // WebRTC configuration
  final Map<String, dynamic> _rtcConfiguration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  // Data channel configuration
  final Map<String, dynamic> _dataChannelConfig = {
    'ordered': true,
    'maxRetransmitTime': 3000,
  };

  /// Stream of incoming messages from peers
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// Stream of signaling messages (for external transport)
  Stream<SignalingMessage> get signalingStream => _signalingController.stream;

  /// Stream of connection state changes
  Stream<Map<String, dynamic>> get connectionStateStream =>
      _connectionStateController.stream;

  /// List of connected peers
  List<String> get connectedPeers => _connections.entries
      .where((e) => e.value.state == WebRTCConnectionState.connected)
      .map((e) => e.key)
      .toList();

  /// Initialize WebRTC service
  Future<void> initialize(String localPeerId) async {
    if (_isInitialized) return;

    try {
      _localPeerId = localPeerId;
      _isInitialized = true;

      if (kDebugMode) {
        logger.info(
          'WebRTC signaling service initialized: $localPeerId',
          category: 'WebRTC',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error initializing WebRTC service',
          category: 'WebRTC',
          error: e,
        );
      }
      rethrow;
    }
  }

  /// Create offer for peer connection
  Future<RTCSessionDescription?> createOffer(String peerId) async {
    if (!_isInitialized) {
      throw Exception('WebRTC service not initialized');
    }

    try {
      // Create peer connection
      final peerConnection = await createPeerConnection(_rtcConfiguration);

      // Create data channel
      final dataChannel = await peerConnection.createDataChannel(
        'data',
        RTCDataChannelInit()
          ..ordered = _dataChannelConfig['ordered']
          ..maxRetransmitTime = _dataChannelConfig['maxRetransmitTime'],
      );

      // Setup data channel handlers
      _setupDataChannelHandlers(dataChannel, peerId);

      // Store connection
      _connections[peerId] = WebRTCPeerConnection(
        peerId: peerId,
        connection: peerConnection,
        dataChannel: dataChannel,
      );

      // Setup connection handlers
      _setupConnectionHandlers(peerConnection, peerId);

      // Create offer
      final offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);

      if (kDebugMode) {
        logger.debug('Created offer for peer: $peerId', category: 'WebRTC');
      }

      // Send offer via signaling
      _signalingController.add(
        SignalingMessage(
          from: _localPeerId!,
          to: peerId,
          type: SignalingMessageType.offer,
          payload: {'sdp': offer.toMap()},
        ),
      );

      return offer;
    } catch (e) {
      if (kDebugMode) {
        logger.error('Error creating offer', category: 'WebRTC', error: e);
      }
      return null;
    }
  }

  /// Handle incoming signaling message
  Future<void> handleSignalingMessage(SignalingMessage message) async {
    if (!_isInitialized || message.to != _localPeerId) return;

    try {
      switch (message.type) {
        case SignalingMessageType.offer:
          await _handleOffer(message);
          break;
        case SignalingMessageType.answer:
          await _handleAnswer(message);
          break;
        case SignalingMessageType.candidate:
          await _handleCandidate(message);
          break;
        case SignalingMessageType.bye:
          await _handleBye(message);
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error handling signaling message',
          category: 'WebRTC',
          error: e,
        );
      }
    }
  }

  /// Handle offer
  Future<void> _handleOffer(SignalingMessage message) async {
    final peerId = message.from;

    try {
      // Create peer connection
      final peerConnection = await createPeerConnection(_rtcConfiguration);

      // Store connection
      _connections[peerId] = WebRTCPeerConnection(
        peerId: peerId,
        connection: peerConnection,
      );

      // Setup connection handlers
      _setupConnectionHandlers(peerConnection, peerId);

      // Setup data channel handler
      peerConnection.onDataChannel = (channel) {
        _setupDataChannelHandlers(channel, peerId);
      };

      // Set remote description
      final sdp = message.payload['sdp'] as Map<String, dynamic>;
      await peerConnection.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );

      // Create answer
      final answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);

      // Send answer via signaling
      _signalingController.add(
        SignalingMessage(
          from: _localPeerId!,
          to: peerId,
          type: SignalingMessageType.answer,
          payload: {'sdp': answer.toMap()},
        ),
      );

      if (kDebugMode) {
        logger.debug('Created answer for peer: $peerId', category: 'WebRTC');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error('Error handling offer', category: 'WebRTC', error: e);
      }
    }
  }

  /// Handle answer
  Future<void> _handleAnswer(SignalingMessage message) async {
    final peerId = message.from;
    final peerConnection = _connections[peerId]?.connection;

    if (peerConnection == null) return;

    try {
      final sdp = message.payload['sdp'] as Map<String, dynamic>;
      await peerConnection.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );

      if (kDebugMode) {
        logger.debug('Set answer from peer: $peerId', category: 'WebRTC');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error('Error handling answer', category: 'WebRTC', error: e);
      }
    }
  }

  /// Handle ICE candidate
  Future<void> _handleCandidate(SignalingMessage message) async {
    final peerId = message.from;
    final peerConnection = _connections[peerId]?.connection;

    if (peerConnection == null) return;

    try {
      final candidateMap = message.payload['candidate'] as Map<String, dynamic>;
      final candidate = RTCIceCandidate(
        candidateMap['candidate'],
        candidateMap['sdpMid'],
        candidateMap['sdpMLineIndex'],
      );

      await peerConnection.addCandidate(candidate);

      if (kDebugMode) {
        logger.debug(
          'Added ICE candidate from peer: $peerId',
          category: 'WebRTC',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error('Error handling candidate', category: 'WebRTC', error: e);
      }
    }
  }

  /// Handle bye (disconnect)
  Future<void> _handleBye(SignalingMessage message) async {
    final peerId = message.from;
    await disconnectPeer(peerId);
  }

  /// Setup connection handlers
  void _setupConnectionHandlers(RTCPeerConnection connection, String peerId) {
    connection.onIceCandidate = (candidate) {
      // Send ICE candidate via signaling
      _signalingController.add(
        SignalingMessage(
          from: _localPeerId!,
          to: peerId,
          type: SignalingMessageType.candidate,
          payload: {'candidate': candidate.toMap()},
        ),
      );
    };

    connection.onIceConnectionState = (state) {
      if (kDebugMode) {
        logger.debug(
          'ICE connection state for $peerId: $state',
          category: 'WebRTC',
        );
      }

      WebRTCConnectionState newState;
      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
          newState = WebRTCConnectionState.connected;
          _connections[peerId]?.connectedAt = DateTime.now();
          break;
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          newState = WebRTCConnectionState.failed;
          break;
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          newState = WebRTCConnectionState.closed;
          break;
        case RTCIceConnectionState.RTCIceConnectionStateChecking:
          newState = WebRTCConnectionState.connecting;
          break;
        default:
          newState = WebRTCConnectionState.disconnected;
      }

      if (_connections[peerId] != null) {
        _connections[peerId]!.state = newState;
        _connectionStateController.add({
          'peerId': peerId,
          'state': newState.name,
        });
      }
    };
  }

  /// Setup data channel handlers
  void _setupDataChannelHandlers(RTCDataChannel channel, String peerId) {
    channel.onMessage = (RTCDataChannelMessage message) {
      try {
        if (_connections[peerId] != null) {
          _connections[peerId]!.bytesReceived += message.text.length;
        }

        final data = jsonDecode(message.text) as Map<String, dynamic>;
        data['from'] = peerId;
        _messageController.add(data);

        if (kDebugMode) {
          logger.debug(
            'Received message from $peerId: ${message.text.length} bytes',
            category: 'WebRTC',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          logger.error(
            'Error processing message',
            category: 'WebRTC',
            error: e,
          );
        }
      }
    };

    channel.onDataChannelState = (state) {
      if (kDebugMode) {
        logger.debug(
          'Data channel state for $peerId: $state',
          category: 'WebRTC',
        );
      }
    };
  }

  /// Send message to peer
  Future<bool> sendMessage(String peerId, Map<String, dynamic> message) async {
    final connection = _connections[peerId];

    if (connection == null ||
        connection.state != WebRTCConnectionState.connected ||
        connection.dataChannel == null) {
      return false;
    }

    try {
      final jsonMessage = jsonEncode(message);
      await connection.dataChannel!.send(RTCDataChannelMessage(jsonMessage));

      connection.bytesSent += jsonMessage.length;

      if (kDebugMode) {
        logger.debug(
          'Sent message to $peerId: ${jsonMessage.length} bytes',
          category: 'WebRTC',
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error sending message to $peerId',
          category: 'WebRTC',
          error: e,
        );
      }
      return false;
    }
  }

  /// Broadcast message to all connected peers
  Future<int> broadcastMessage(Map<String, dynamic> message) async {
    int successCount = 0;

    for (final peerId in connectedPeers) {
      if (await sendMessage(peerId, message)) {
        successCount++;
      }
    }

    return successCount;
  }

  /// Disconnect from peer
  Future<void> disconnectPeer(String peerId) async {
    final connection = _connections[peerId];

    if (connection != null) {
      // Send bye message
      _signalingController.add(
        SignalingMessage(
          from: _localPeerId!,
          to: peerId,
          type: SignalingMessageType.bye,
          payload: {},
        ),
      );

      await connection.close();
      _connections.remove(peerId);

      if (kDebugMode) {
        logger.info('Disconnected from peer: $peerId', category: 'WebRTC');
      }
    }
  }

  /// Disconnect all peers
  Future<void> disconnectAll() async {
    final peerIds = _connections.keys.toList();

    for (final peerId in peerIds) {
      await disconnectPeer(peerId);
    }
  }

  /// Get connection statistics
  Map<String, dynamic> getStatistics() {
    final stats = {
      'totalConnections': _connections.length,
      'connectedPeers': connectedPeers.length,
      'totalBytesSent': 0,
      'totalBytesReceived': 0,
      'connectionStates': <String, int>{},
    };

    for (final conn in _connections.values) {
      stats['totalBytesSent'] =
          (stats['totalBytesSent'] as int) + conn.bytesSent;
      stats['totalBytesReceived'] =
          (stats['totalBytesReceived'] as int) + conn.bytesReceived;

      final stateKey = conn.state.name;
      final stateMap = stats['connectionStates'] as Map<String, int>;
      stateMap[stateKey] = (stateMap[stateKey] ?? 0) + 1;
    }

    return stats;
  }

  /// Get connection info
  Map<String, dynamic>? getConnectionInfo(String peerId) {
    final conn = _connections[peerId];

    if (conn == null) return null;

    return {
      'peerId': peerId,
      'state': conn.state.name,
      'connectedAt': conn.connectedAt?.toIso8601String(),
      'bytesSent': conn.bytesSent,
      'bytesReceived': conn.bytesReceived,
    };
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnectAll();
    await _messageController.close();
    await _signalingController.close();
    await _connectionStateController.close();
    _isInitialized = false;
  }
}
