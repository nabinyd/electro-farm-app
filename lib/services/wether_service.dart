import 'package:dio/dio.dart';
import 'package:electro_farm/config/api_client.dart';

class WeatherService {
  final DioClient _client = DioClient();
  late final Dio _dio = _client.dio;

  Future<Map<String, dynamic>> getByLatLon({
    required double lat,
    required double lon,
    String units = "metric",
  }) async {
    // Important: your backend route is /api/weather/ (trailing slash)
    final res = await _dio.get(
      "/api/weather/",
      queryParameters: {"lat": lat, "lon": lon, "units": units},
    );
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getByCity({
    required String city,
    String units = "metric",
  }) async {
    final res = await _dio.get(
      "/api/weather/",
      queryParameters: {"city": city, "units": units},
    );
    return (res.data as Map).cast<String, dynamic>();
  }
}
