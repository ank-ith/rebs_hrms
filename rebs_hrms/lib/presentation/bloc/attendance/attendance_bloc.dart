import 'package:flutter_bloc/flutter_bloc.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/repositories/attendance_repository.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _repo;
  final LocationService _location;

  AttendanceBloc({
    required AttendanceRepository repo,
    required LocationService location,
  })  : _repo = repo,
        _location = location,
        super(AttendanceInitial()) {
    on<PerformCheckIn>(_onCheckIn);
    on<PerformCheckOut>(_onCheckOut);
    on<SyncPendingAttendance>(_onSyncPending);
  }

  Future<void> _onCheckIn(
      PerformCheckIn event, Emitter<AttendanceState> emit) async {
    emit(const AttendanceLoading());
    try {
      final pos = await _location.getCurrentPosition();
      emit(const AttendanceLoading('Saving check-in…'));
      final event = await _repo.checkIn(lat: pos.latitude, lng: pos.longitude);
      emit(AttendanceQueued(event, 'Check-in saved. Syncing…'));
      add(const SyncPendingAttendance());
    } on GeofenceFailure catch (f) {
      emit(AttendanceFailureState(f.message));
    } on LocationPermissionPermanentlyDeniedFailure catch (f) {
      emit(AttendancePermissionPermanentlyDenied(f.message));
    } on Failure catch (f) {
      emit(AttendanceFailureState(f.message));
    } catch (e) {
      emit(AttendanceFailureState(e.toString()));
    }
  }

  Future<void> _onCheckOut(
      PerformCheckOut event, Emitter<AttendanceState> emit) async {
    emit(const AttendanceLoading());
    try {
      final pos = await _location.getCurrentPosition();
      emit(const AttendanceLoading('Saving check-out…'));
      final event = await _repo.checkOut(lat: pos.latitude, lng: pos.longitude);
      emit(AttendanceQueued(event, 'Check-out saved. Syncing…'));
      add(const SyncPendingAttendance());
    } on GeofenceFailure catch (f) {
      emit(AttendanceFailureState(f.message));
    } on LocationPermissionPermanentlyDeniedFailure catch (f) {
      emit(AttendancePermissionPermanentlyDenied(f.message));
    } on Failure catch (f) {
      emit(AttendanceFailureState(f.message));
    } catch (e) {
      emit(AttendanceFailureState(e.toString()));
    }
  }

  Future<void> _onSyncPending(
      SyncPendingAttendance event, Emitter<AttendanceState> emit) async {
    emit(const AttendanceSyncing());
    try {
      await _repo.syncPendingEvents();
      emit(const AttendanceSyncCompleted());
    } catch (_) {
      // Events remain pending in local storage and can be retried manually or
      // when connectivity is restored.
      emit(const AttendanceSyncCompleted());
    }
  }
}
