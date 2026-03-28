import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../services/socket_service.dart';

class VisionProcessorProvider extends ChangeNotifier {
  VisionProcessorProvider({required this.socketService}) {
    _init();
  }

  final SocketService socketService;

  // Latest result
  Map<String, dynamic>? _latestResult;

  Map<String, dynamic>? get latestResult => _latestResult;

  // Parsed fields for easy UI usage
  String plantHealth = "unknown";
  int totalDetections = 0;
  List<Map<String, dynamic>> issues = [];
  List<String> recommendationTags = [];

  bool success = false;
  String? error;

  // Optional: history
  final int maxHistory = 10;
  final ListQueue<Map<String, dynamic>> _history = ListQueue();

  List<Map<String, dynamic>> get history => List.unmodifiable(_history);

  void _init() {
    socketService.visionStream.listen((data) {
      _latestResult = data;

      // Parse fields safely
      plantHealth = data["plant_health"] ?? "unknown";
      totalDetections = data["total_detections"] ?? 0;
      issues =
          (data["issues"] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];

      recommendationTags =
          (data["recommendation_tags"] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      success = data["success"] ?? false;
      error = data["error"];

      // Maintain history
      _history.addLast(data);
      while (_history.length > maxHistory) {
        _history.removeFirst();
      }

      notifyListeners();
    });
  }

  void connect() => socketService.connect();
  void disconnect() => socketService.disconnect();
}
