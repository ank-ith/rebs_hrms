import 'package:hive/hive.dart';
import '../models/employee_model.dart';
import '../../core/constants/app_constants.dart';

class EmployeeLocalDataSource {
  Box<EmployeeModel> get _box =>
      Hive.box<EmployeeModel>(AppConstants.employeeBox);

  Future<void> cacheEmployee(EmployeeModel employee) async {
    await _box.put('current', employee);
  }

  EmployeeModel? getCachedEmployee() => _box.get('current');
}
