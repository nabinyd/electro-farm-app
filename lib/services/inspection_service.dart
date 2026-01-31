import 'package:dio/dio.dart';
import 'package:electro_farm/config/api_client.dart';
import 'package:electro_farm/models/inspection_models.dart';

class InspectionApi {
  final Dio _dio = DioClient().dio;

  Future<List<InspectionRun>> getRuns({
    String? fieldId,
    String? robotId,
  }) async {
    final res = await _dio.get(
      "/api/inspection/runs",
      queryParameters: {
        if (fieldId != null) "field_id": fieldId,
        if (robotId != null) "robot_id": robotId,
        "limit": 50,
      },
    );

    final list = (res.data as List).cast<dynamic>();
    return list
        .whereType<Map>()
        .map((e) => InspectionRun.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<RunReport> getReport(String runId) async {
    final res = await _dio.get(
      "/api/inspection/report",
      queryParameters: {"run_id": runId},
    );
    return RunReport.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<List<InspectionFrame>> getFrames(String runId) async {
    final res = await _dio.get(
      "/api/inspection/frames",
      queryParameters: {"run_id": runId, "limit": 200},
    );
    final list = (res.data as List).cast<dynamic>();
    return list
        .whereType<Map>()
        .map((e) => InspectionFrame.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}
