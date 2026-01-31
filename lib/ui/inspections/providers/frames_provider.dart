import 'package:electro_farm/models/inspection_models.dart';
import 'package:electro_farm/services/inspection_service.dart';
import 'package:flutter/foundation.dart';

class FramesProvider extends ChangeNotifier {
  final InspectionApi _api = InspectionApi();

  bool _loading = false;
  String? _error;
  List<InspectionFrame> _frames = const [];
  
  bool get loading => _loading;
  String? get error => _error;
  List<InspectionFrame> get frames => _frames;

  bool get hasError => _error != null;
  bool get isEmpty => _frames.isEmpty;
  int get count => _frames.length;

  // -----------------
  // Actions
  // -----------------
  Future<void> load(String runId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _frames = await _api.getFrames(runId);
    } catch (e) {
      _error = e.toString();
      _frames = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _frames = const [];
    _error = null;
    _loading = false;
    notifyListeners();
  }
}
