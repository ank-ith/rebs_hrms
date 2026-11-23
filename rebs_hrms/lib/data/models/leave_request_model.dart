import 'package:hive/hive.dart';
part 'leave_request_model.g.dart';

@HiveType(typeId: 4)
class LeaveRequestModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String leaveType;
  @HiveField(2)
  final String startDate;
  @HiveField(3)
  final String endDate;
  @HiveField(4)
  final String reason;
  @HiveField(5)
  final String status;

  LeaveRequestModel({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      LeaveRequestModel(
        id: json['id'] as String,
        leaveType: json['leave_type'] as String,
        startDate: json['start_date'] as String,
        endDate: json['end_date'] as String,
        reason: json['reason'] as String,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'leave_type': leaveType,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
        'status': status,
      };
}
