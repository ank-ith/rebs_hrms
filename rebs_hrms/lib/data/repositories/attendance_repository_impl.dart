import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/services/location_service.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../local/attendance_local_datasource.dart';
import '../models/attendance_event_model.dart';
import '../models/attendance_record_model.dart';
import '../remote/attendance_api_service.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceApiService _api;
  final AttendanceLocalDataSource _local;
  final NetworkInfo _network;
  final LocationService _location;
  final _uuid = const Uuid();

  AttendanceRepositoryImpl({
    required AttendanceApiService api,
    required AttendanceLocalDataSource local,
    required NetworkInfo network,
    required LocationService location,
  })  : _api = api,
        _local = local,
        _network = network,
        _location = location;

  @override
  Future<List<AttendanceRecordModel>> getAttendanceHistory(String month) async {
    if (await _network.isConnected) {
      try {
        final records = await _api.getAttendanceHistory(month);
        await _local.cacheRecords(records);
        return records;
      } catch (_) {}
    }
    return _local.getCachedRecords();
  }

  @override
  Future<AttendanceEventModel> checkIn({
    required double lat,
    required double lng,
  }) async {
    if (!AppConstants.debugMockLocation) {
      final distance = _location.distanceFromOffice(lat, lng);
      if (distance > AppConstants.geofenceRadiusMeters) {
        throw GeofenceFailure(distance);
      }
    }
    return _performAction('check_in', lat, lng);
  }

  @override
  Future<AttendanceEventModel> checkOut({
    required double lat,
    required double lng,
  }) async {
    if (!AppConstants.debugMockLocation) {
      final distance = _location.distanceFromOffice(lat, lng);
      if (distance > AppConstants.geofenceRadiusMeters) {
        throw GeofenceFailure(distance);
      }
    }
    return _performAction('check_out', lat, lng);
  }

  Future<AttendanceEventModel> _performAction(
      String type, double lat, double lng) async {
    if (type == 'check_in' && hasCheckedInToday()) {
      throw const DuplicateEventFailure('Already checked in today');
    }
    if (type == 'check_out' && !hasCheckedInToday()) {
      throw const ValidationFailure(
          'Cannot check out without checking in first');
    }
    if (type == 'check_out' && hasCheckedOutToday()) {
      throw const DuplicateEventFailure('Already checked out today');
    }

    final event = AttendanceEventModel(
      eventId: _uuid.v4(),
      type: type,
      timestamp: DateTime.now().toUtc().toIso8601String(),
      latitude: lat,
      longitude: lng,
      syncStatusIndex: SyncStatus.pendingSync.index,
    );

    // Persist locally first. The caller can update the UI as soon as this
    // completes; synchronization runs separately in the background.
    await _local.addPendingEvent(event);
    return event;
  }

  Future<void> _syncEvent(AttendanceEventModel event) async {
    try {
      await _api.submitEvent(event);
      await _local.updateEventStatus(event.eventId, SyncStatus.synced);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        // Server says duplicate — idempotent: treat as already synced
        await _local.updateEventStatus(event.eventId, SyncStatus.synced);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        // Timeout: unknown server state — keep as PendingSync
        // Same UUID ensures retry won't duplicate on server
      } else {
        await _local.updateEventStatus(
          event.eventId,
          SyncStatus.rejected,
          reason: e.response?.data?['message'] as String? ??
              'Server rejected event',
        );
      }
    }
  }

  @override
  Future<void> syncPendingEvents() async {
    if (!await _network.isConnected) return;
    final pending = _local.getPendingEvents(); // FIFO sorted by timestamp
    for (final event in pending) {
      await _syncEvent(event);
    }
  }

  @override
  List<AttendanceEventModel> getPendingEvents() => _local.getPendingEvents();

  @override
  List<AttendanceEventModel> getAllLocalEvents() => _local.getAllEvents();

  @override
  bool hasCheckedInToday() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _local
        .getAllEvents()
        .any((e) => e.type == 'check_in' && e.timestamp.startsWith(today));
  }

  @override
  bool hasCheckedOutToday() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _local
        .getAllEvents()
        .any((e) => e.type == 'check_out' && e.timestamp.startsWith(today));
  }
}
