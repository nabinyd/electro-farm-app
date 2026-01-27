import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/telemetry_model.dart';
import '../services/socket_service.dart';

class TelemetryProvider extends ChangeNotifier {
  TelemetryProvider({required this.socketService}) {
    _init();
  }

  final SocketService socketService;

  Telemetry? latest;
  SocketStatus status = SocketStatus.disconnected;

  // Keep last N samples for charts
  final int maxSamples = 120; // ~12 seconds at 10Hz
  final ListQueue<Telemetry> history = ListQueue();

  void _init() {
    socketService.statusStream.listen((s) {
      status = s;
      notifyListeners();
    });

    socketService.telemetryStream.listen((json) {
      final t = Telemetry.fromJson(json);
      latest = t;

      history.addLast(t);
      while (history.length > maxSamples) {
        history.removeFirst();
      }
      notifyListeners();
    });
  }

  void connect() => socketService.connect();
  void disconnect() => socketService.disconnect();
}
