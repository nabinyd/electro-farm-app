import 'dart:math' as math;

double _d(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

double? _dn(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

DateTime _parseTs(dynamic tsVal) {
  if (tsVal is num) {
    return DateTime.fromMillisecondsSinceEpoch((tsVal * 1000).toInt());
  }
  return DateTime.now();
}

class Vec3 {
  final double x;
  final double y;
  final double z;
  const Vec3({required this.x, required this.y, required this.z});

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

class OdomData {
  final double x;
  final double y;
  final double yaw;

  const OdomData({required this.x, required this.y, required this.yaw});

  factory OdomData.fromJson(Map<String, dynamic> json) =>
      OdomData(x: _d(json['x']), y: _d(json['y']), yaw: _d(json['yaw']));
}

class TwistData {
  final double vx;
  final double vy;
  final double wz;

  const TwistData({required this.vx, required this.vy, required this.wz});

  factory TwistData.fromJson(Map<String, dynamic> json) =>
      TwistData(vx: _d(json['vx']), vy: _d(json['vy']), wz: _d(json['wz']));

  double get speed => math.sqrt(vx * vx + vy * vy);
}

class LidarData {
  /// These can be null if that sector has no valid readings
  final double? minFront;
  final double? minLeft;
  final double? minRight;

  /// meta (optional)
  final int? count;
  final double? rangeMin;
  final double? rangeMax;
  final String? frameId;

  const LidarData({
    required this.minFront,
    required this.minLeft,
    required this.minRight,
    this.count,
    this.rangeMin,
    this.rangeMax,
    this.frameId,
  });

  factory LidarData.fromJson(Map<String, dynamic> json) => LidarData(
    minFront: _dn(json['min_front']),
    minLeft: _dn(json['min_left']),
    minRight: _dn(json['min_right']),
    count: (json['count'] is num) ? (json['count'] as num).toInt() : null,
    rangeMin: _dn(json['range_min']),
    rangeMax: _dn(json['range_max']),
    frameId: json['frame_id']?.toString(),
  );

  bool dangerFront([double threshold = 0.5]) =>
      (minFront != null && minFront! > 0 && minFront! < threshold);
}

class Telemetry {
  final DateTime ts;
  final String robotId;

  final ImuData? imu;
  final OdomData? odom2d;
  final TwistData? twist2d;
  final LidarData? lidar;

  /// Keep raw fields for backward compatibility / debugging
  final double? speedMps;
  final Map<String, dynamic>? raw;

  Telemetry({
    required this.ts,
    required this.robotId,
    this.imu,
    this.odom2d,
    this.twist2d,
    this.lidar,
    this.speedMps,
    this.raw,
  });

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    final robotId = (json['robot_id'] ?? 'unknown').toString();
    final ts = _parseTs(json['ts']);

    final imuMap = (json['imu'] as Map?)?.cast<String, dynamic>();
    final imu = imuMap != null ? ImuData.fromJson(imuMap) : null;

    final odomMap = (json['odom'] as Map?)?.cast<String, dynamic>();
    final odom2d = odomMap != null ? OdomData.fromJson(odomMap) : null;

    final twistMap = (json['twist'] as Map?)?.cast<String, dynamic>();
    final twist2d = twistMap != null ? TwistData.fromJson(twistMap) : null;

    final lidarMap = (json['lidar'] as Map?)?.cast<String, dynamic>();
    final lidar = lidarMap != null ? LidarData.fromJson(lidarMap) : null;

    // speed_mps from backend OR compute from twist
    double? speed = json.containsKey('speed_mps')
        ? _d(json['speed_mps'])
        : null;
    if (speed == null && twist2d != null) speed = twist2d.speed;

    // Sanitize tiny scientific values (avoid 5e-11 showing as moving)
    if (speed != null && speed.abs() < 0.001) speed = 0.0;

    return Telemetry(
      ts: ts,
      robotId: robotId,
      imu: imu,
      odom2d: odom2d,
      twist2d: twist2d,
      lidar: lidar,
      speedMps: speed,
      raw: json, // keep whole payload if you want debug screens
    );
  }

  // Convenience getters for existing widgets
  double get x => odom2d?.x ?? 0.0;
  double get y => odom2d?.y ?? 0.0;
  double get yaw => odom2d?.yaw ?? 0.0;

  double get speed => speedMps ?? 0.0;

  bool get obstacleDanger => lidar?.dangerFront(0.5) ?? false;

  bool isStale([Duration maxAge = const Duration(seconds: 3)]) {
    return DateTime.now().difference(ts) > maxAge;
  }
}
