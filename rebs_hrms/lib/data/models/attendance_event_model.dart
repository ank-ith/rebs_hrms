import 'package:hive/hive.dart';
part 'attendance_event_model.g.dart';

enum SyncStatus { pendingSync, synced, rejected }

@HiveType(typeId: 2)
class AttendanceEventModel extends HiveObject {
  @HiveField(0)
  final String eventId; // UUID — idempotency key

  @HiveField(1)
  final String type; // 'check_in' | 'check_out'

  @HiveField(2)
  final String timestamp; // ISO 8601 UTC

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  int syncStatusIndex; // maps to SyncStatus enum index

  @HiveField(6)
  String? rejectionReason;

  AttendanceEventModel({
    required this.eventId,
    required this.type,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.syncStatusIndex = 0,
    this.rejectionReason,
  });

  SyncStatus get syncStatus => SyncStatus.values[syncStatusIndex];
  set syncStatus(SyncStatus s) => syncStatusIndex = s.index;

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'type': type,
        'timestamp': timestamp,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory AttendanceEventModel.fromJson(Map<String, dynamic> json) =>
      AttendanceEventModel(
        eventId: json['event_id'] as String,
        type: json['type'] as String,
        timestamp: json['timestamp'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        syncStatusIndex: json['sync_status_index'] as int? ?? 0,
        rejectionReason: json['rejection_reason'] as String?,
      );
}
