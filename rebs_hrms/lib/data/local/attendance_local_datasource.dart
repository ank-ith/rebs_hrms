import 'package:hive/hive.dart';
import '../models/attendance_record_model.dart';
import '../models/attendance_event_model.dart';
import '../../core/constants/app_constants.dart';

class AttendanceLocalDataSource {
  Box<AttendanceRecordModel> get _recordBox =>
      Hive.box<AttendanceRecordModel>(AppConstants.attendanceBox);

  Box<AttendanceEventModel> get _pendingBox =>
      Hive.box<AttendanceEventModel>(AppConstants.pendingEventsBox);

  Future<void> cacheRecords(List<AttendanceRecordModel> records) async {
    await _recordBox.clear();
    for (final r in records) {
      await _recordBox.put(r.date, r);
    }
  }

  List<AttendanceRecordModel> getCachedRecords() =>
      _recordBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  Future<void> addPendingEvent(AttendanceEventModel event) async {
    await _pendingBox.put(event.eventId, event);
  }

  List<AttendanceEventModel> getPendingEvents() => _pendingBox.values
      .where((e) => e.syncStatus == SyncStatus.pendingSync)
      .toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  List<AttendanceEventModel> getAllEvents() => _pendingBox.values.toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  Future<void> updateEventStatus(String eventId, SyncStatus status,
      {String? reason}) async {
    final event = _pendingBox.get(eventId);
    if (event != null) {
      event.syncStatus = status;
      event.rejectionReason = reason;
      await event.save();
    }
  }
}
