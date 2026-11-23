import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/leave_repository.dart';
import '../local/leave_local_datasource.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_request_model.dart';
import '../remote/leave_api_service.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveApiService _api;
  final LeaveLocalDataSource _local;
  final NetworkInfo _network;

  LeaveRepositoryImpl({
    required LeaveApiService api,
    required LeaveLocalDataSource local,
    required NetworkInfo network,
  })  : _api = api,
        _local = local,
        _network = network;

  @override
  Future<LeaveBalanceModel> getLeaveBalance() async {
    if (await _network.isConnected) {
      try {
        final balance = await _api.getLeaveBalance();
        await _local.cacheLeaveBalance(balance);
        return balance;
      } catch (_) {}
    }
    final cached = _local.getCachedLeaveBalance();
    if (cached != null) return cached;
    throw Exception('Leave balance unavailable offline');
  }

  @override
  Future<List<LeaveRequestModel>> getLeaveRequests() async {
    if (await _network.isConnected) {
      try {
        final requests = await _api.getLeaveRequests();
        await _local.cacheLeaveRequests(requests);
        return requests;
      } catch (_) {}
    }
    return _local.getCachedLeaveRequests();
  }

  @override
  Future<LeaveRequestModel> submitLeaveRequest({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    if (!await _network.isConnected) {
      throw const NetworkFailure('Internet required to submit leave request');
    }
    final result = await _api.submitLeaveRequest({
      'leave_type': leaveType,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
    });
    final existing = _local.getCachedLeaveRequests();
    await _local.cacheLeaveRequests([...existing, result]);
    return result;
  }
}
