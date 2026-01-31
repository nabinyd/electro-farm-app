import 'dart:async';
import 'package:electro_farm/models/inspection_models.dart';
import 'package:electro_farm/services/inspection_service.dart';
import 'package:flutter/foundation.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider({required this.api, required this.runId});
  final InspectionApi api;
  final String runId;

  RunReport? report;
  bool loading = false;
  String? error;

  Timer? _poll;

  Future<void> load({bool pollIfProcessing = true}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      report = await api.getReport(runId);
      if (pollIfProcessing) _setupPollingIfNeeded();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _setupPollingIfNeeded() {
    _poll?.cancel();
    final status = report?.status ?? "processing";
    if (status == "done" || status == "failed") return;

    // poll every 2s until done
    _poll = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final r = await api.getReport(runId);
        report = r;
        notifyListeners();
        if (r.status == "done" || r.status == "failed") {
          _poll?.cancel();
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }
}
