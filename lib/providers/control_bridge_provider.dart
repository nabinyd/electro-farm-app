import 'package:electro_farm/services/socket_service.dart';
import 'package:flutter/material.dart';

enum RobotMode { manual, auto }

class ControlProvider extends ChangeNotifier {
  final SocketService socket;

  ControlProvider(this.socket);

  RobotMode _mode = RobotMode.manual;
  bool _emergency = false;

  RobotMode get mode => _mode;
  bool get isAuto => _mode == RobotMode.auto;
  bool get isManual => _mode == RobotMode.manual;
  bool get isEmergency => _emergency;

  String get modeText => _mode == RobotMode.auto ? "AUTO" : "MANUAL";

  /// 🚀 Switch to AUTO
  void setAuto(String robotId) {
    socket.setMode(robotId: robotId, mode: "auto");
    _mode = RobotMode.auto;
    notifyListeners();
  }

  /// 🧑‍✈️ Switch to MANUAL
  void setManual(String robotId) {
    socket.setMode(robotId: robotId, mode: "manual");
    _mode = RobotMode.manual;
    notifyListeners();
  }

  /// 🛑 Emergency Stop
  void triggerEmergency(String robotId) {
    socket.emergencyStop(robotId: robotId, stop: true);
    _emergency = true;
    _mode = RobotMode.manual;
    notifyListeners();
  }

  /// ✅ Release Emergency
  void releaseEmergency(String robotId) {
    socket.emergencyStop(robotId: robotId, stop: false);
    _emergency = false;
    notifyListeners();
  }
}
