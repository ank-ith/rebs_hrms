import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../domain/repositories/employee_repository.dart';
import '../../../domain/repositories/attendance_repository.dart';
import '../../../domain/repositories/leave_repository.dart';
import '../../../core/network/network_info.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final EmployeeRepository _employeeRepo;
  final AttendanceRepository _attendanceRepo;
  final LeaveRepository _leaveRepo;
  final NetworkInfo _network;

  DashboardBloc({
    required EmployeeRepository employeeRepo,
    required AttendanceRepository attendanceRepo,
    required LeaveRepository leaveRepo,
    required NetworkInfo network,
  })  : _employeeRepo = employeeRepo,
        _attendanceRepo = attendanceRepo,
        _leaveRepo = leaveRepo,
        _network = network,
        super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<SyncNow>(_onSync);
    on<RefreshLocalAttendance>(_onRefreshLocalAttendance);
  }

  Future<void> _onLoad(
      LoadDashboard event, Emitter<DashboardState> emit) async {
    final previous = state;
    if (previous is DashboardLoaded) {
      emit(previous.copyWith(isRefreshing: true));
    } else {
      emit(DashboardLoading());
    }
    try {
      final isOnline = await _network.isConnected;
      final month = DateFormat('yyyy-MM').format(DateTime.now());

      final employee = await _employeeRepo.getEmployee();
      final records = await _attendanceRepo.getAttendanceHistory(month);
      final balance = await _leaveRepo.getLeaveBalance();
      final allEvents = _attendanceRepo.getAllLocalEvents();
      final pendingCount = _attendanceRepo.getPendingEvents().length;

      emit(DashboardLoaded(
        employee: employee,
        attendanceRecords: records.take(5).toList(),
        allEvents: allEvents,
        leaveBalance: balance,
        isOnline: isOnline,
        pendingSyncCount: pendingCount,
        hasCheckedIn: _attendanceRepo.hasCheckedInToday(),
        hasCheckedOut: _attendanceRepo.hasCheckedOutToday(),
      ));
    } catch (e) {
      if (previous is DashboardLoaded) {
        emit(previous.copyWith(isRefreshing: false));
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }

  Future<void> _onSync(SyncNow event, Emitter<DashboardState> emit) async {
    await _attendanceRepo.syncPendingEvents();
    add(LoadDashboard());
  }

  void _onRefreshLocalAttendance(
      RefreshLocalAttendance event, Emitter<DashboardState> emit) {
    final current = state;
    if (current is! DashboardLoaded) return;

    final allEvents = _attendanceRepo.getAllLocalEvents();
    emit(DashboardLoaded(
      employee: current.employee,
      attendanceRecords: current.attendanceRecords,
      allEvents: allEvents,
      leaveBalance: current.leaveBalance,
      isOnline: current.isOnline,
      pendingSyncCount: _attendanceRepo.getPendingEvents().length,
      hasCheckedIn: _attendanceRepo.hasCheckedInToday(),
      hasCheckedOut: _attendanceRepo.hasCheckedOutToday(),
      isRefreshing: current.isRefreshing,
    ));
  }
}
