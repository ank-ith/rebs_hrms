import 'package:dio/dio.dart';
import '../models/attendance_record_model.dart';
import '../models/attendance_event_model.dart';

class AttendanceApiService {
  final Dio _dio;
  AttendanceApiService(this._dio);

  Future<List<AttendanceRecordModel>> getAttendanceHistory(String month) async {
    final response =
        await _dio.get('/attendance', queryParameters: {'month': month});
    final list = response.data as List<dynamic>;
    return list
        .map((e) => AttendanceRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> submitEvent(AttendanceEventModel event) async {
    final response =
        await _dio.post('/attendance/events', data: event.toJson());
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
