import 'package:equatable/equatable.dart';
import '../../../data/models/attendance_event_model.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {
  final String message;
  const AttendanceLoading([this.message = 'Getting location…']);

  @override
  List<Object?> get props => [message];
}

class AttendanceQueued extends AttendanceState {
  final AttendanceEventModel event;
  final String message;
  const AttendanceQueued(this.event, this.message);

  @override
  List<Object?> get props => [event, message];
}

class AttendanceSyncing extends AttendanceState {
  const AttendanceSyncing();
}

class AttendanceSyncCompleted extends AttendanceState {
  const AttendanceSyncCompleted();
}

class AttendanceSuccess extends AttendanceState {
  final String message;
  const AttendanceSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AttendanceFailureState extends AttendanceState {
  final String message;
  const AttendanceFailureState(this.message);
  @override
  List<Object?> get props => [message];
}

class AttendancePermissionPermanentlyDenied extends AttendanceState {
  final String message;
  const AttendancePermissionPermanentlyDenied(this.message);
  @override
  List<Object?> get props => [message];
}
