import 'package:hive/hive.dart';
part 'leave_balance_model.g.dart';

@HiveType(typeId: 3)
class LeaveBalanceModel extends HiveObject {
  @HiveField(0)
  final int casualLeave;
  @HiveField(1)
  final int sickLeave;

  LeaveBalanceModel({required this.casualLeave, required this.sickLeave});

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) =>
      LeaveBalanceModel(
        casualLeave: json['casual_leave'] as int,
        sickLeave: json['sick_leave'] as int,
      );

  Map<String, dynamic> toJson() => {
        'casual_leave': casualLeave,
        'sick_leave': sickLeave,
      };
}
