import 'package:hive/hive.dart';
import '../models/leave_request_model.dart';
import '../models/leave_balance_model.dart';
import '../../core/constants/app_constants.dart';

class LeaveLocalDataSource {
  Box<LeaveRequestModel> get _requestBox =>
      Hive.box<LeaveRequestModel>(AppConstants.leaveBox);

  Box<LeaveBalanceModel> get _balanceBox =>
      Hive.box<LeaveBalanceModel>(AppConstants.leaveBalanceBox);

  Future<void> cacheLeaveRequests(List<LeaveRequestModel> requests) async {
    await _requestBox.clear();
    for (final r in requests) {
      await _requestBox.put(r.id, r);
    }
  }

  List<LeaveRequestModel> getCachedLeaveRequests() =>
      _requestBox.values.toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));

  Future<void> cacheLeaveBalance(LeaveBalanceModel balance) async {
    await _balanceBox.put('balance', balance);
  }

  LeaveBalanceModel? getCachedLeaveBalance() => _balanceBox.get('balance');
}
