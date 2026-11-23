import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class PerformCheckIn extends AttendanceEvent {}

class PerformCheckOut extends AttendanceEvent {}

class SyncPendingAttendance extends AttendanceEvent {
  const SyncPendingAttendance();
}
