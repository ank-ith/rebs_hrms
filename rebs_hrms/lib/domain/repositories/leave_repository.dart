import '../../data/models/leave_balance_model.dart';
import '../../data/models/leave_request_model.dart';

abstract class LeaveRepository {
  Future<LeaveBalanceModel> getLeaveBalance();
  Future<List<LeaveRequestModel>> getLeaveRequests();
  Future<LeaveRequestModel> submitLeaveRequest({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  });
}
