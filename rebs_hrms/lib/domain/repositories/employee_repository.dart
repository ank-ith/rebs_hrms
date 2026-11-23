import '../../data/models/employee_model.dart';

abstract class EmployeeRepository {
  Future<EmployeeModel> getEmployee();
}
