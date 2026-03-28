import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class ArmJointControlProvider extends ChangeNotifier {
  final SocketService socket;

  ArmJointControlProvider({required this.socket});

  // Current angles (UI state)
  final Map<String, double> _angles = {
    'A': 90,
    'B': 90,
    'C': 90,
    'D': 90,
    'E': 90,
  };

  Map<String, double> get angles => _angles;

  // 🔹 Update single joint
  void updateJoint({
    required String robotId,
    required String motor,
    required double angle,
  }) {
    final clamped = angle.clamp(0, 180) as double;
    _angles[motor] = clamped;

    socket.sendArmCommand(robotId: robotId, motor: motor, angle: clamped);

    notifyListeners();
  }

  // 🔹 Update multiple joints
  void updateMultiple({
    required String robotId,
    required Map<String, double> newAngles,
  }) {
    final commands = <Map<String, dynamic>>[];

    newAngles.forEach((motor, angle) {
      final clamped = angle.clamp(0, 180) as double;
      _angles[motor] = clamped;

      commands.add({"motor": motor, "angle": clamped});
    });

    socket.sendArmCommand(robotId: robotId, commands: commands);

    notifyListeners();
  }

  // 🔹 Reset to default position
  void reset(String robotId) {
    final defaultAngles = {
      'A': 90.0,
      'B': 90.0,
      'C': 90.0,
      'D': 90.0,
      'E': 90.0,
    };

    updateMultiple(robotId: robotId, newAngles: defaultAngles);
  }

  // 🔹 Preset positions
  void setPreset(String robotId, String preset) {
    if (preset == "pick") {
      updateMultiple(
        robotId: robotId,
        newAngles: {'A': 90, 'B': 120, 'C': 60, 'D': 90, 'E': 40},
      );
    } else if (preset == "place") {
      updateMultiple(
        robotId: robotId,
        newAngles: {'A': 100, 'B': 80, 'C': 120, 'D': 90, 'E': 120},
      );
    }
  }
}
