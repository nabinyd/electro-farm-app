import 'package:electro_farm/models/inspection_models.dart';
import 'package:electro_farm/services/inspection_service.dart';
import 'package:flutter/foundation.dart';

class FramesProvider extends ChangeNotifier {
  FramesProvider({required this.api, required this.runId});
  final InspectionApi api;
  final String runId;

  bool loading = false;
  String? error;
  List<InspectionFrame> frames = const [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      frames = await api.getFrames(runId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
