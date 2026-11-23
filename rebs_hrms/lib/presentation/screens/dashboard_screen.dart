import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';
import '../widgets/attendance_status_card.dart';
import '../widgets/leave_balance_card.dart';
import '../widgets/attendance_history_list.dart';
import '../widgets/sync_status_banner.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('REBS HRMS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoaded && state.isRefreshing) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                );
              }
              if (state is DashboardLoaded && state.pendingSyncCount > 0) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.sync, color: Colors.white),
                      onPressed: () =>
                          context.read<DashboardBloc>().add(SyncNow()),
                      tooltip: 'Sync Now',
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.orange, shape: BoxShape.circle),
                        child: Text(
                          '${state.pendingSyncCount}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () =>
                    context.read<DashboardBloc>().add(LoadDashboard()),
              );
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AttendanceBloc, AttendanceState>(
            listener: (context, state) {
              if (state is AttendanceQueued) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.blue,
                ));
                context
                    .read<DashboardBloc>()
                    .add(const RefreshLocalAttendance());
              } else if (state is AttendanceSyncCompleted) {
                context
                    .read<DashboardBloc>()
                    .add(const RefreshLocalAttendance());
              } else if (state is AttendanceFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ));
              } else if (state is AttendancePermissionPermanentlyDenied) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Location Permission Required'),
                    content: Text(state.message),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          openAppSettings();
                          Navigator.pop(context);
                        },
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DashboardError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<DashboardBloc>().add(LoadDashboard()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is DashboardLoaded) {
              final today = DateTime.now().toIso8601String().substring(0, 10);
              final todayEvents = state.allEvents
                  .where((e) => e.timestamp.startsWith(today))
                  .toList();

              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<DashboardBloc>().add(LoadDashboard()),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (!state.isOnline)
                      SyncStatusBanner(pendingCount: state.pendingSyncCount),
                    _EmployeeCard(
                      name: state.employee.name,
                      id: state.employee.id,
                      department: state.employee.department,
                    ),
                    const SizedBox(height: 12),
                    AttendanceStatusCard(
                      hasCheckedIn: state.hasCheckedIn,
                      hasCheckedOut: state.hasCheckedOut,
                      todayEvents: todayEvents,
                      onCheckIn: () =>
                          context.read<AttendanceBloc>().add(PerformCheckIn()),
                      onCheckOut: () =>
                          context.read<AttendanceBloc>().add(PerformCheckOut()),
                    ),
                    const SizedBox(height: 12),
                    LeaveBalanceCard(balance: state.leaveBalance),
                    const SizedBox(height: 12),
                    AttendanceHistoryList(records: state.attendanceRecords),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final String name, id, department;
  const _EmployeeCard(
      {required this.name, required this.id, required this.department});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF1565C0),
              child: Text(name[0],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text('ID: $id',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text(department,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
