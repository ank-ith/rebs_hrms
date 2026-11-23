import 'package:hive/hive.dart';
part 'attendance_record_model.g.dart';

@HiveType(typeId: 1)
class AttendanceRecordModel extends HiveObject {
  @HiveField(0)
  final String date;
  @HiveField(1)
  final String? checkInTime;
  @HiveField(2)
  final String? checkOutTime;
  @HiveField(3)
  final String status;

  AttendanceRecordModel({
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) =>
      AttendanceRecordModel(
        date: json['date'] as String,
        checkInTime: json['check_in_time'] as String?,
        checkOutTime: json['check_out_time'] as String?,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime,
        'status': status,
      };
}
