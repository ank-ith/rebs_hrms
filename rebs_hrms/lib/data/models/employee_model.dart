import 'package:hive/hive.dart';
part 'employee_model.g.dart';

@HiveType(typeId: 0)
class EmployeeModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String department;
  @HiveField(3)
  final double officeLatitude;
  @HiveField(4)
  final double officeLongitude;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.department,
    required this.officeLatitude,
    required this.officeLongitude,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        department: json['department'] as String,
        officeLatitude: (json['office_latitude'] as num).toDouble(),
        officeLongitude: (json['office_longitude'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'department': department,
        'office_latitude': officeLatitude,
        'office_longitude': officeLongitude,
      };
}
