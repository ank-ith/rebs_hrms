import 'package:equatable/equatable.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/attendance_record_model.dart';
import '../../../data/models/attendance_event_model.dart';
import '../../../data/models/leave_balance_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final EmployeeModel employee;
  final List<AttendanceRecordModel> attendanceRecords;
  final List<AttendanceEventModel> allEvents;
  final LeaveBalanceModel leaveBalance;
  final bool isOnline;
  final int pendingSyncCount;
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final bool isRefreshing;

  const DashboardLoaded({
    required this.employee,
    required this.attendanceRecords,
    required this.allEvents,
    required this.leaveBalance,
    required this.isOnline,
    required this.pendingSyncCount,
    required this.hasCheckedIn,
    required this.hasCheckedOut,
    this.isRefreshing = false,
  });

  DashboardLoaded copyWith({bool? isRefreshing}) => DashboardLoaded(
        employee: employee,
        attendanceRecords: attendanceRecords,
        allEvents: allEvents,
        leaveBalance: leaveBalance,
        isOnline: isOnline,
        pendingSyncCount: pendingSyncCount,
        hasCheckedIn: hasCheckedIn,
        hasCheckedOut: hasCheckedOut,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );

  @override
  List<Object?> get props => [
        employee,
        attendanceRecords,
        allEvents,
        leaveBalance,
        isOnline,
        pendingSyncCount,
        hasCheckedIn,
        hasCheckedOut,
        isRefreshing,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
