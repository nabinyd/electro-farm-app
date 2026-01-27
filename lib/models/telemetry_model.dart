// lib/models/telemetry_model.dart
import 'dart:math' as math;

class Vec3 {
  final double x;
  final double y;
  final double z;
  const Vec3({required this.x, required this.y, required this.z});

  static double _d(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  factory Vec3.fromJson(Map<String, dynamic> json) =>
      Vec3(x: _d(json['x']), y: _d(json['y']), z: _d(json['z']));

  double magnitude() => math.sqrt(x * x + y * y + z * z);
}

class ImuData {
  final String frameId;
  final Vec3 angVel; // rad/s
  final Vec3 linAcc; // m/s^2
  final bool orientationValid;

  const ImuData({
    required this.frameId,
    required this.angVel,
    required this.linAcc,
    required this.orientationValid,
  });

  factory ImuData.fromJson(Map<String, dynamic> json) {
    final ang = (json['ang_vel'] as Map?)?.cast<String, dynamic>() ?? {};
    final acc = (json['lin_acc'] as Map?)?.cast<String, dynamic>() ?? {};
    return ImuData(
      frameId: (json['frame_id'] ?? 'imu').toString(),
      angVel: Vec3.fromJson(ang),
      linAcc: Vec3.fromJson(acc),
      orientationValid: (json['orientation_valid'] == true),
    );
  }
}

class Telemetry {
  final DateTime ts;
  final String robotId;

  // Current real payload:
  final ImuData? imu;

  // Future payload (keep optional for later expansion):
  final double? speedMps;
  final Map<String, dynamic>? odom;
  final Map<String, dynamic>? cmd;
  final Map<String, dynamic>? twist;
  final Map<String, dynamic>? wheels;

  Telemetry({
    required this.ts,
    required this.robotId,
    this.imu,
    this.speedMps,
    this.odom,
    this.cmd,
    this.twist,
    this.wheels,
  });

  static double _toDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static DateTime _parseTs(dynamic tsVal) {
    if (tsVal is num) {
      return DateTime.fromMillisecondsSinceEpoch((tsVal * 1000).toInt());
    }
    return DateTime.now();
  }

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    final robotId = (json['robot_id'] ?? 'unknown').toString();
    final ts = _parseTs(json['ts']);

    // IMU payload:
    final imuMap = (json['imu'] as Map?)?.cast<String, dynamic>();
    final imu = imuMap != null ? ImuData.fromJson(imuMap) : null;

    // Optional legacy/future fields:
    final speed = json.containsKey('speed_mps')
        ? _toDouble(json['speed_mps'])
        : null;
    final odom = (json['odom'] as Map?)?.cast<String, dynamic>();
    final cmd = (json['cmd'] as Map?)?.cast<String, dynamic>();
    final twist = (json['twist'] as Map?)?.cast<String, dynamic>();
    final wheels = (json['wheels'] as Map?)?.cast<String, dynamic>();

    return Telemetry(
      ts: ts,
      robotId: robotId,
      imu: imu,
      speedMps: speed,
      odom: odom,
      cmd: cmd,
      twist: twist,
      wheels: wheels,
    );
  }
}
