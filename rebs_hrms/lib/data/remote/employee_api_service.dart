import 'package:dio/dio.dart';
import '../models/employee_model.dart';

class EmployeeApiService {
  final Dio _dio;
  EmployeeApiService(this._dio);

  Future<EmployeeModel> getEmployee() async {
    final response = await _dio.get('/employee/me');
    return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
  }
}
