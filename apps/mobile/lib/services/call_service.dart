import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:campus_mesh/services/local_call_log_database.dart';
import 'package:campus_mesh/services/mesh_network_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Simple 1:1 voice/video calling using WebRTC with mesh-based signaling.
class CallService {
  factory CallService() => _instance;
  CallService._internal();
  static final CallService _instance = CallService._internal();

  final _mesh = MeshNetworkService();
  final _callLogDb = LocalCallLogDatabase();

  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  final _callState = ValueNotifier<CallState>(CallState.idle);
  String? _currentPeerId;
  String? _currentCallId;

  ValueListenable<CallState> get callState => _callState;
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> initialize() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // Listen for mesh signaling
    _mesh.messageStream.listen((msg) async {
      try {
        if (!msg.type.startsWith('call.')) return;
        final type = msg.type;
        switch (type) {
          case 'call.offer':
            await _handleRemoteOffer(msg.senderId, msg.payload);
            break;
          case 'call.answer':
            await _handleRemoteAnswer(msg.payload);
            break;
          case 'call.ice':
            await _handleRemoteIce(msg.payload);
            break;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Call signaling error: $e');
        }
      }
    });
  }

  Future<void> dispose() async {
    await endCall();
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
  }

  Future<void> _createPeerConnection() async {
    if (_pc != null) return;
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };
    final constraints = {
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };
    _pc = await createPeerConnection(config, constraints);

    _pc!.onIceCandidate = (candidate) async {
      final peer = _currentPeerId;
      if (peer == null) return;
      final msg = MeshMessage(
        id: 'ice_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'me',
        type: 'call.ice',
        payload: candidate.toMap(),
      );
      try {
        await _mesh.sendMessage(peer, msg);
      } catch (_) {}
    };

    _pc!.onTrack = (event) async {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams.first;
      }
    };
  }

  Future<void> _ensureLocalStream({bool video = true}) async {
    if (_localStream != null) return;
    final media = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': video
          ? {
              'facingMode': 'user',
              'width': {'ideal': 640},
              'height': {'ideal': 480},
            }
          : false,
    });
    _localStream = media;
    _localRenderer.srcObject = media;
    for (final track in media.getTracks()) {
      await _pc?.addTrack(track, media);
    }
  }

  bool _isValidPeerId(String peerId) {
    if (peerId.isEmpty || peerId.length > 128) return false;
    final invalid = RegExp(r"[^a-zA-Z0-9_\-]{}");
    return !invalid.hasMatch(peerId);
  }

  Map<String, dynamic> _sanitizeSdpMap(Map<String, dynamic> m) {
    return {
      'sdp': (m['sdp'] as String?)?.substring(0, 4096),
      'type': m['type'],
    }..removeWhere((key, value) => value == null);
  }

  Future<void> startCall(String peerId, {bool video = true}) async {
    if (!_isValidPeerId(peerId)) {
      throw Exception('Invalid peer ID');
    }
    _currentPeerId = peerId;
    await _createPeerConnection();
    await _ensureLocalStream(video: video);

    _callState.value = CallState.calling;
    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);

    _currentCallId = 'call_${DateTime.now().millisecondsSinceEpoch}';
    await _callLogDb.logStart(
      id: _currentCallId!,
      peerId: peerId,
      isVideo: video,
      startedAt: DateTime.now().toIso8601String(),
    );

    final msg = MeshMessage(
      id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      type: 'call.offer',
      payload: _sanitizeSdpMap(offer.toMap()),
    );
    await _mesh.sendMessage(peerId, msg);
  }

  Future<void> _handleRemoteOffer(String peerId, Map<String, dynamic> sdp) async {
    _currentPeerId = peerId;
    await _createPeerConnection();
    await _ensureLocalStream(video: true);

  await _pc!.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
    final answer = await _pc!.createAnswer();
    await _pc!.setLocalDescription(answer);

    final msg = MeshMessage(
      id: 'answer_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      type: 'call.answer',
      payload: _sanitizeSdpMap(answer.toMap()),
    );
    await _mesh.sendMessage(peerId, msg);
    _callState.value = CallState.inCall;
  }

  Future<void> _handleRemoteAnswer(Map<String, dynamic> sdp) async {
    if (_pc == null) return;
    await _pc!.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
    _callState.value = CallState.inCall;
  }

  Future<void> _handleRemoteIce(Map<String, dynamic> ice) async {
    if (_pc == null) return;
    try {
      await _pc!.addCandidate(RTCIceCandidate(
        ice['candidate'] as String?,
        ice['sdpMid'] as String?,
        ice['sdpMLineIndex'] as int?,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding ICE: $e');
      }
    }
  }

  Future<void> endCall() async {
    _callState.value = CallState.ended;
    try {
      await _pc?.close();
    } catch (_) {}
    _pc = null;
    try {
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;
    try {
      if (_currentCallId != null) {
        await _callLogDb.logEnd(
          id: _currentCallId!,
          endedAt: DateTime.now().toIso8601String(),
          status: 'ended',
        );
      }
    } catch (_) {}
    _currentPeerId = null;
    _currentCallId = null;
  }
}

enum CallState { idle, calling, ringing, inCall, ended }
