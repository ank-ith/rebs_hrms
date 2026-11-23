import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class SyncNow extends DashboardEvent {}

/// Refreshes attendance derived from Hive without waiting for dashboard APIs.
class RefreshLocalAttendance extends DashboardEvent {
  const RefreshLocalAttendance();
}
