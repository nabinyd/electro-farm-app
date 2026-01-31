import 'package:electro_farm/models/inspection_models.dart';
import 'package:electro_farm/services/inspection_service.dart';
import 'package:flutter/foundation.dart';

class RunsProvider extends ChangeNotifier {
  final InspectionApi api = InspectionApi();

  bool loading = false;
  String? error;
  List<InspectionRun> runs = const [];

  Future<void> refresh({String? fieldId, String? robotId}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      runs = await api.getRuns(fieldId: fieldId, robotId: robotId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
