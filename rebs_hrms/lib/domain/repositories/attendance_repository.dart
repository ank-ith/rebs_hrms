import '../../data/models/attendance_record_model.dart';
import '../../data/models/attendance_event_model.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecordModel>> getAttendanceHistory(String month);

  /// Queues the event locally. Network synchronization is deliberately
  /// separate so the UI can confirm a valid attendance action immediately.
  Future<AttendanceEventModel> checkIn({
    required double lat,
    required double lng,
  });
  Future<AttendanceEventModel> checkOut({
    required double lat,
    required double lng,
  });
  Future<void> syncPendingEvents();
  List<AttendanceEventModel> getPendingEvents();
  List<AttendanceEventModel> getAllLocalEvents();
  bool hasCheckedInToday();
  bool hasCheckedOutToday();
}
