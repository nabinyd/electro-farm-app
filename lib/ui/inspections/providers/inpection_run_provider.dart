import 'package:collection/collection.dart';
import 'package:electro_farm/models/inspection_models.dart';
import 'package:electro_farm/services/inspection_service.dart';
import 'package:flutter/foundation.dart';

class RunsProvider extends ChangeNotifier {
  final InspectionApi api = InspectionApi();

  bool loading = false;
  String? error;

  final List<InspectionRun> _runs = [];

  /// Public read-only list
  List<InspectionRun> get runs => List.unmodifiable(_runs);

  /// Fetch runs from API (force refresh)
  Future<void> fetchRuns({String? fieldId, String? robotId}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final fetched = await api.getRuns(fieldId: fieldId, robotId: robotId);

      _runs
        ..clear()
        ..addAll(fetched);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Fetch only if not already loaded
  Future<void> fetchRunsIfEmpty({String? fieldId, String? robotId}) async {
    if (_runs.isNotEmpty) return;
    await fetchRuns(fieldId: fieldId, robotId: robotId);
  }

  /// Get run from memory (fast)
  InspectionRun? getRunById(String runId) {
    return _runs.firstWhereOrNull((r) => r.runId == runId);
  }

  /// Optional: fetch a single run from API if missing
  Future<InspectionRun?> fetchRunById(String runId) async {
    final cached = getRunById(runId);
    if (cached != null) return cached;

    try {
      final all = await api.getRuns();
      final run = all.firstWhereOrNull((r) => r.runId == runId);
      if (run != null) {
        _runs.add(run);
        notifyListeners();
      }
      return run;
    } catch (_) {
      return null;
    }
  }

  /// Clear cache (logout / switch farm / robot)
  void clear() {
    _runs.clear();
    notifyListeners();
  }
}
