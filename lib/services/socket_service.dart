import 'dart:async';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum SocketStatus { disconnected, connecting, connected, reconnecting, error }

class SocketService {
  SocketService({required this.baseUrl});

  final String baseUrl;
  late IO.Socket _socket;

  final _telemetryController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get telemetryStream =>
      _telemetryController.stream;

  final _statusController = StreamController<SocketStatus>.broadcast();
  Stream<SocketStatus> get statusStream => _statusController.stream;

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

  void dispose() {
    disconnect();
    _telemetryController.close();
    _statusController.close();
  }
}
