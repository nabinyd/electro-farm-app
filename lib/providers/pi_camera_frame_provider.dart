import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/socket_service.dart';

class PiCameraFrameProvider extends ChangeNotifier {
  PiCameraFrameProvider({required this.socketService}) {
    _init();
  }

  final SocketService socketService;

  String? _latestFrameBase64;
  Uint8List? _latestFrameBytes;

  String? get latestFrameBase64 => _latestFrameBase64;
  Uint8List? get latestFrameBytes => _latestFrameBytes;

  // Keep last N frames if needed
  final int maxFrames = 10;
  final ListQueue<Uint8List> _history = ListQueue();

  List<Uint8List> get history => List.unmodifiable(_history);

  void _init() {
    socketService.piCameraStream.listen((base64Str) {
      _latestFrameBase64 = base64Str;
      _latestFrameBytes = base64Decode(base64Str);

      _history.addLast(_latestFrameBytes!);
      while (_history.length > maxFrames) {
        _history.removeFirst();
      }

      notifyListeners();
    });
  }

  void connect() => socketService.connect();
  void disconnect() => socketService.disconnect();
}
