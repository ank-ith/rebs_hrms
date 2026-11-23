import 'package:dio/dio.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_request_model.dart';

class LeaveApiService {
  final Dio _dio;
  LeaveApiService(this._dio);

  Future<LeaveBalanceModel> getLeaveBalance() async {
    final response = await _dio.get('/leave/balance');
    return LeaveBalanceModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<LeaveRequestModel>> getLeaveRequests() async {
    final response = await _dio.get('/leave/requests');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => LeaveRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LeaveRequestModel> submitLeaveRequest(
      Map<String, dynamic> data) async {
    final response = await _dio.post('/leave/requests', data: data);
    return LeaveRequestModel.fromJson(response.data as Map<String, dynamic>);
  }
}
