import 'package:electro_farm/models/wether_model.dart';
import 'package:electro_farm/services/location_service.dart';
import 'package:electro_farm/services/wether_service.dart';
import 'package:flutter/foundation.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService api = WeatherService();

  bool loading = false;
  String? error;
  WeatherData? weather;

  DateTime? _lastFetch;
  static const _minRefresh = Duration(seconds: 60);

  Future<void> fetchFromDevice({bool force = false}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final pos = await LocationService.getCurrentPosition();

      final json = await api.getByLatLon(lat: pos.latitude, lon: pos.longitude);

      weather = WeatherData.fromApi(json);
      _lastFetch = DateTime.now();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatLon({
    required double lat,
    required double lon,
    bool force = false,
  }) async {
    if (!force && _lastFetch != null) {
      final diff = DateTime.now().difference(_lastFetch!);
      if (diff < _minRefresh) return; // ✅ avoid spamming backend
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final json = await api.getByLatLon(lat: lat, lon: lon);
      weather = WeatherData.fromApi(json);
      _lastFetch = DateTime.now();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCity({required String city, bool force = false}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final json = await api.getByCity(city: city);
      weather = WeatherData.fromApi(json);
      _lastFetch = DateTime.now();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
