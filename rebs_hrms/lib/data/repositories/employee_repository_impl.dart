import '../../core/network/network_info.dart';
import '../../domain/repositories/employee_repository.dart';
import '../local/employee_local_datasource.dart';
import '../models/employee_model.dart';
import '../remote/employee_api_service.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeApiService _api;
  final EmployeeLocalDataSource _local;
  final NetworkInfo _network;

  EmployeeRepositoryImpl({
    required EmployeeApiService api,
    required EmployeeLocalDataSource local,
    required NetworkInfo network,
  })  : _api = api,
        _local = local,
        _network = network;

  @override
  Future<EmployeeModel> getEmployee() async {
    if (await _network.isConnected) {
      try {
        final employee = await _api.getEmployee();
        await _local.cacheEmployee(employee);
        return employee;
      } catch (_) {}
    }
    final cached = _local.getCachedEmployee();
    if (cached != null) return cached;
    throw Exception('No employee data available offline');
  }
}
