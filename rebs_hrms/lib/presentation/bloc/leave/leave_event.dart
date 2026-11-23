import 'package:equatable/equatable.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();
  @override
  List<Object?> get props => [];
}

class LoadLeaveData extends LeaveEvent {}

/// Returns to the data state after transient validation or network feedback.
class ClearLeaveFeedback extends LeaveEvent {
  const ClearLeaveFeedback();
}

class SubmitLeaveRequest extends LeaveEvent {
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;

  const SubmitLeaveRequest({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  @override
  List<Object?> get props => [leaveType, startDate, endDate, reason];
}
