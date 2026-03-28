import 'dart:async';
import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class InspectionProvider extends ChangeNotifier {
  final SocketService socket;

  InspectionProvider({required this.socket}) {
    _init();
  }

  // ================= STATE =================
  String? runId;
  String? robotId;
  String? fieldId;

  String status = "idle"; // idle | processing | done
  double progress = 0.0;

  int totalFrames = 0;
  int doneFrames = 0;
  int failedFrames = 0;

  Map<String, dynamic>? report;
  Map<String, dynamic>? reportText;

  String? error;

  bool get isRunning => status == "processing";

  // ================= STREAM SUBSCRIPTIONS =================
  StreamSubscription? _inspectionSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _errorSub;

  // ================= INIT =================
  void _init() {
    _inspectionSub = socket.inspectionStream.listen((data) {
      _handleInspectionEvent(data);
    });

    _statusSub = socket.inspectionStatusStream.listen((data) {
      _handleStatusUpdate(data);
    });

    _errorSub = socket.inspectionErrorStream.listen((data) {
      error = data["error"];
      notifyListeners();
    });
  }

  // ================= HANDLERS =================

  void _handleInspectionEvent(Map<String, dynamic> data) {
    if (data.containsKey("run_id")) {
      runId = data["run_id"];
      robotId = data["robot_id"];
      fieldId = data["field_id"];
      status = data["status"] ?? "processing";
      progress = 0.0;
    }

    notifyListeners();
  }

  void _handleStatusUpdate(Map<String, dynamic> data) {
    runId = data["run_id"];
    robotId = data["robot_id"];
    fieldId = data["field_id"];

    status = data["status"] ?? status;

    totalFrames = data["total_frames"] ?? 0;
    doneFrames = data["done_frames"] ?? 0;
    failedFrames = data["failed_frames"] ?? 0;

    progress = (data["progress"] ?? 0).toDouble();

    report = data["report"];
    reportText = data["report_text"];

    notifyListeners();
  }

  // ================= ACTIONS =================

  void startInspection({
    required String robotId,
    required String fieldId,
    int totalFrames = 0,
  }) {
    error = null;
    debugPrint(
      "Starting inspection: robotId=$robotId, fieldId=$fieldId, totalFrames=$totalFrames",
    );
    socket.startInspection(
      robotId: robotId,
      fieldId: fieldId,
      totalFrames: totalFrames,
    );
  }

  void stopInspection() {
    if (robotId == null) return;

    socket.stopInspection(robotId: robotId!);
  }

  void refreshStatus() {
    if (runId != null) {
      socket.getInspectionStatus(runId: runId);
    } else if (robotId != null) {
      socket.getInspectionStatus(robotId: robotId);
    }
  }

  // ================= CLEANUP =================

  @override
  void dispose() {
    _inspectionSub?.cancel();
    _statusSub?.cancel();
    _errorSub?.cancel();
    super.dispose();
  }
}
