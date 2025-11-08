import 'package:campus_mesh/services/call_service.dart';
import 'package:flutter/material.dart';

/// Basic voice/video call screen using CallService renderers.
class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.peerId, this.video = true});
  final String peerId;
  final bool video;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _callService = CallService();
  bool _initialized = false;
  bool _started = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _callService.initialize();
      setState(() => _initialized = true);
      await _callService.startCall(widget.peerId, video: widget.video);
      setState(() => _started = true);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _callService.endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Call'),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Call setup failed',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: widget.video
                      ? _callService.remoteRenderer.textureId != null
                          ? _buildRTCVideo(_callService.remoteRenderer)
                          : _buildStatus('Waiting for remote video...')
                      : _buildStatus('Voice call in progress'),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  width: 120,
                  height: 160,
                  child: widget.video
                      ? _callService.localRenderer.textureId != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildRTCVideo(_callService.localRenderer),
                            )
                          : _buildMiniStatus()
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: 'end',
                        backgroundColor: Colors.red,
                        onPressed: () async {
                          await _callService.endCall();
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Icon(Icons.call_end),
                      ),
                    ],
                  ),
                ),
                if (!_initialized || !_started)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildProgress(),
                  ),
              ],
            ),
    );
  }

  Widget _buildRTCVideo(dynamic renderer) {
    return Texture(textureId: renderer.textureId!);
  }

  Widget _buildStatus(String text) => Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70),
        ),
      );

  Widget _buildMiniStatus() => Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Local',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );

  Widget _buildProgress() => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.black54,
        child: const LinearProgressIndicator(minHeight: 2),
      );
}
