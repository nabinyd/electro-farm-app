import 'dart:async';
// ignore: library_prefixes
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum SocketStatus { disconnected, connecting, connected, reconnecting, error }

class SocketService {
  SocketService({required this.baseUrl});

  final String baseUrl;
  late IO.Socket _socket;

  // Telemetry data stream
  final _telemetryController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get telemetryStream =>
      _telemetryController.stream;

  // Connection status stream
  final _statusController = StreamController<SocketStatus>.broadcast();
  Stream<SocketStatus> get statusStream => _statusController.stream;

  // Camera stream (base64 images)
  final _piCameraController =
      StreamController<String>.broadcast(); // base64 strings
  Stream<String> get piCameraStream => _piCameraController.stream;

  // Camera stream (base64 images)
  final _espCameraController =
      StreamController<String>.broadcast(); // base64 strings
  Stream<String> get espCameraStream => _espCameraController.stream;

  // Vision data stream (e.g., object detection results)
  final _visionController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get visionStream => _visionController.stream;

  final _inspectionController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get inspectionStream =>
      _inspectionController.stream;

  final _inspectionStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get inspectionStatusStream =>
      _inspectionStatusController.stream;

  final _inspectionErrorController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get inspectionErrorStream =>
      _inspectionErrorController.stream;

  // Current connection status
  SocketStatus _status = SocketStatus.disconnected;
  SocketStatus get status => _status;

  Timer? _healthTimer;
  DateTime? _lastTelemetryTime;

  void connect() {
    _setStatus(SocketStatus.connecting);

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setTimeout(5000)
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      _setStatus(SocketStatus.connected);
      _startHealthCheck();
    });

    _socket.onDisconnect((_) {
      _setStatus(SocketStatus.disconnected);
    });

    _socket.onReconnect((_) {
      _setStatus(SocketStatus.connected);
    });

    _socket.onReconnectAttempt((_) {
      _setStatus(SocketStatus.reconnecting);
    });

    _socket.onConnectError((err) {
      _setStatus(SocketStatus.error);
    });

    _socket.onError((err) {
      _setStatus(SocketStatus.error);
    });

    _socket.on("telemetry", (data) {
      if (data is Map) {
        final json = data.cast<String, dynamic>();
        _lastTelemetryTime = DateTime.now();
        _telemetryController.add(json);
      }
    });

    _socket.on("camera", (data) {
      if (data is Map) {
        final imageBase64 = data['image'] as String?;
        if (imageBase64 != null) {
          _piCameraController.add(imageBase64);
        }
      }
    });
    _socket.on("espcamera", (data) {
      if (data is Map) {
        final imageBase64 = data['image'] as String?;
        if (imageBase64 != null) {
          _espCameraController.add(imageBase64);
        }
      }
    });

    _socket.on("vision_results", (data) {
      if (data is Map) {
        final json = data.cast<String, dynamic>();
        _visionController.add(json);
      }
    });

    _socket.on("inspection_started", (data) {
      if (data is Map) {
        _inspectionController.add(data.cast<String, dynamic>());
      }
    });

    _socket.on("inspection_stopped", (data) {
      if (data is Map) {
        _inspectionController.add(data.cast<String, dynamic>());
      }
    });

    _socket.on("inspection_status", (data) {
      if (data is Map) {
        _inspectionStatusController.add(data.cast<String, dynamic>());
      }
    });

    _socket.on("inspection_error", (data) {
      if (data is Map) {
        _inspectionErrorController.add(data.cast<String, dynamic>());
      }
    });
  }

  void _startHealthCheck() {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_status == SocketStatus.connected) {
        final last = _lastTelemetryTime;
        if (last == null) return;

        final diff = DateTime.now().difference(last);
        // be more tolerant
        if (diff.inSeconds >= 12) {
          _setStatus(SocketStatus.reconnecting);
        }
      }
    });
  }

  void _setStatus(SocketStatus status) {
    _status = status;
    _statusController.add(status);
  }

  void disconnect() {
    _healthTimer?.cancel();
    _socket.dispose();
    _setStatus(SocketStatus.disconnected);
  }

  void sendCmdVel({
    required String robotId,
    required double vx,
    required double wz,
  }) {
    if (_status != SocketStatus.connected) return;

    _socket.emit("cmd_vel", {
      "robot_id": robotId,
      "ts": DateTime.now().millisecondsSinceEpoch / 1000.0,
      "mode": "manual",
      "cmd_vel": {"vx": vx, "vy": 0.0, "wz": wz},
    });
  }

  void startInspection({
    required String robotId,
    required String fieldId,
    int totalFrames = 0,
  }) {
    if (_status != SocketStatus.connected) return;

    _socket.emit("start_inspection", {
      "robot_id": robotId,
      "field_id": fieldId,
      "total_frames": totalFrames,
    });
  }

  void stopInspection({required String robotId}) {
    if (_status != SocketStatus.connected) return;

    _socket.emit("stop_inspection", {"robot_id": robotId});
  }

  void getInspectionStatus({String? runId, String? robotId}) {
    if (_status != SocketStatus.connected) return;

    _socket.emit("get_inspection_status", {
      if (runId != null) "run_id": runId,
      if (robotId != null) "robot_id": robotId,
    });
  }

  void setMode({
    required String robotId,
    required String mode, // "auto" or "manual"
  }) {
    if (_status != SocketStatus.connected) return;

    _socket.emit("set_mode", {"robot_id": robotId, "mode": mode});
  }

  void emergencyStop({required String robotId, required bool stop}) {
    if (_status != SocketStatus.connected) return;

    _socket.emit("emergency_stop", {"robot_id": robotId, "stop": stop});
  }

  void sendArmCommand({
    required String robotId,
    String? motor,
    double? angle,
    List<Map<String, dynamic>>? commands,
  }) {
    if (_status != SocketStatus.connected) return;

    // Single joint
    if (motor != null && angle != null) {
      debugPrint("Sending arm command: motor=$motor, angle=$angle");
      _socket.emit("arm_command", {
        "robot_id": robotId,
        "motor": motor,
        "angle": angle,
      });
      return;
    }

    // Multiple joints
    if (commands != null && commands.isNotEmpty) {
      debugPrint("Sending arm commands: $commands");
      _socket.emit("arm_command", {"robot_id": robotId, "commands": commands});
    }
  }

  void dispose() {
    disconnect();
    _telemetryController.close();
    _statusController.close();
    _piCameraController.close();
    _espCameraController.close();
    _visionController.close();
    _inspectionController.close();
    _inspectionStatusController.close();
    _inspectionErrorController.close();
  }
}
