double _d(dynamic v, [double fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

int _i(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

Map<String, dynamic>? _map(dynamic v) {
  if (v is Map) return v.cast<String, dynamic>();
  return null;
}

List<dynamic> _list(dynamic v) => (v is List) ? v : const [];

class InspectionRun {
  final String runId;
  final String robotId;
  final String fieldId;
  final String status; // pending|processing|done|failed
  final double startedAtTs;
  final double? endedAtTs;
  final int totalFrames;
  final int doneFrames;
  final int failedFrames;

  InspectionRun({
    required this.runId,
    required this.robotId,
    required this.fieldId,
    required this.status,
    required this.startedAtTs,
    required this.totalFrames,
    required this.doneFrames,
    required this.failedFrames,
    this.endedAtTs,
  });

  factory InspectionRun.fromJson(Map<String, dynamic> json) {
    return InspectionRun(
      runId: (json["run_id"] ?? "").toString(),
      robotId: (json["robot_id"] ?? "").toString(),
      fieldId: (json["field_id"] ?? "").toString(),
      status: (json["status"] ?? "pending").toString(),
      startedAtTs: _d(json["started_at_ts"]),
      endedAtTs: json["ended_at_ts"] == null ? null : _d(json["ended_at_ts"]),
      totalFrames: _i(json["total_frames"]),
      doneFrames: _i(json["done_frames"]),
      failedFrames: _i(json["failed_frames"]),
    );
  }

  double get progress =>
      totalFrames <= 0 ? 0 : (doneFrames / totalFrames).clamp(0.0, 1.0);
}

class IssueItem {
  final String type;
  final String severity; // low|medium|high
  final double confidence;
  final List<double>? bbox; // [x1,y1,x2,y2]

  IssueItem({
    required this.type,
    required this.severity,
    required this.confidence,
    this.bbox,
  });

  factory IssueItem.fromJson(Map<String, dynamic> json) {
    final bb = _list(json["bbox"]).map((e) => _d(e)).toList();
    return IssueItem(
      type: (json["type"] ?? "unknown").toString(),
      severity: (json["severity"] ?? "low").toString(),
      confidence: _d(json["confidence"]),
      bbox: bb.isEmpty ? null : bb,
    );
  }
}

class FrameFindings {
  final String plantHealth; // healthy|stressed|unknown
  final List<IssueItem> issues;
  final List<String> tags;

  FrameFindings({
    required this.plantHealth,
    required this.issues,
    required this.tags,
  });

  factory FrameFindings.fromJson(Map<String, dynamic> json) {
    final issues = _list(json["issues"])
        .whereType<Map>()
        .map((e) => IssueItem.fromJson(e.cast<String, dynamic>()))
        .toList();

    final tags = _list(
      json["recommendation_tags"],
    ).map((e) => e.toString()).toList();

    return FrameFindings(
      plantHealth: (json["plant_health"] ?? "unknown").toString(),
      issues: issues,
      tags: tags,
    );
  }
}

class FrameMeta {
  final Map<String, dynamic> raw;
  FrameMeta(this.raw);

  double? get x {
    final odom = _map(raw["odom"]);
    if (odom == null) return null;
    return odom["x"] is num ? _d(odom["x"]) : null;
  }

  double? get y {
    final odom = _map(raw["odom"]);
    if (odom == null) return null;
    return odom["y"] is num ? _d(odom["y"]) : null;
  }
}

class InspectionFrame {
  final String frameId;
  final String runId;
  final String robotId;
  final String fieldId;
  final double ts;
  final String status; // pending|processing|done|failed
  final String imagePath; // backend path (may not be directly public)
  final FrameMeta? meta;
  final FrameFindings? findings;

  InspectionFrame({
    required this.frameId,
    required this.runId,
    required this.robotId,
    required this.fieldId,
    required this.ts,
    required this.status,
    required this.imagePath,
    this.meta,
    this.findings,
  });

  factory InspectionFrame.fromJson(Map<String, dynamic> json) {
    final metaMap = _map(json["meta"]);
    final findingsMap = _map(json["findings"]);

    return InspectionFrame(
      frameId: (json["frame_id"] ?? "").toString(),
      runId: (json["run_id"] ?? "").toString(),
      robotId: (json["robot_id"] ?? "").toString(),
      fieldId: (json["field_id"] ?? "").toString(),
      ts: _d(json["ts"]),
      status: (json["status"] ?? "pending").toString(),
      imagePath: (json["image_path"] ?? "").toString(),
      meta: metaMap == null ? null : FrameMeta(metaMap),
      findings: findingsMap == null
          ? null
          : FrameFindings.fromJson(findingsMap),
    );
  }
}

class RunReport {
  final String runId;
  final String robotId;
  final String fieldId;
  final String status;

  final int totalFrames;
  final int doneFrames;
  final int failedFrames;

  final Map<String, dynamic>? reportJson; // aggregated
  final Map<String, dynamic>? reportText;

  RunReport({
    required this.runId,
    required this.robotId,
    required this.fieldId,
    required this.status,
    required this.totalFrames,
    required this.doneFrames,
    required this.failedFrames,
    this.reportJson,
    this.reportText,
  });

  factory RunReport.fromJson(Map<String, dynamic> json) {
    final reportJson = _map(json["report_json"]);
    final reportText = _map(json["report_text"]);

    // Fallbacks if backend doesn't send robot_id/status/total_frames
    String robotId = (json["robot_id"] ?? "").toString();
    String status = (json["status"] ?? "processing").toString();
    int totalFrames = _i(json["total_frames"]);

    // try infer from report_json.frames_preview[0].meta
    final frames = (reportJson?["frames_preview"] is List)
        ? (reportJson!["frames_preview"] as List)
        : const [];

    if (frames.isNotEmpty && frames.first is Map) {
      final first = (frames.first as Map).cast<String, dynamic>();
      final meta = _map(first["meta"]);
      robotId = robotId.isNotEmpty
          ? robotId
          : (meta?["robot_id"] ?? "").toString();

      // optionally infer status if missing
      status = status.isNotEmpty
          ? status
          : (first["status"] ?? "processing").toString();
    }

    // if totalFrames not provided, infer from frames_preview length (or keep 0)
    if (totalFrames <= 0) totalFrames = frames.length;

    return RunReport(
      runId: (json["run_id"] ?? json["runId"] ?? "").toString(),
      robotId: robotId,
      fieldId: (json["field_id"] ?? "").toString(),
      status: status,
      totalFrames: totalFrames,
      doneFrames: _i(json["done_frames"]),
      failedFrames: _i(json["failed_frames"]),
      reportJson: reportJson,
      reportText: reportText,
    );
  }

  double get progress =>
      totalFrames <= 0 ? 0 : (doneFrames / totalFrames).clamp(0.0, 1.0);

  Map<String, dynamic> get stats {
    final s = reportJson?["stats"];
    return (s is Map) ? s.cast<String, dynamic>() : <String, dynamic>{};
  }

  List<Map<String, dynamic>> get topIssues {
    final list = stats["top_issues"];
    if (list is List) {
      return list
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return const [];
  }
}
