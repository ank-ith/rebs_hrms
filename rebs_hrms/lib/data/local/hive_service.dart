import 'package:hive_flutter/hive_flutter.dart';
import '../models/employee_model.dart';
import '../models/attendance_record_model.dart';
import '../models/attendance_event_model.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_request_model.dart';
import '../../core/constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(EmployeeModelAdapter());
    Hive.registerAdapter(AttendanceRecordModelAdapter());
    Hive.registerAdapter(AttendanceEventModelAdapter());
    Hive.registerAdapter(LeaveBalanceModelAdapter());
    Hive.registerAdapter(LeaveRequestModelAdapter());
    await Hive.openBox<EmployeeModel>(AppConstants.employeeBox);
    await Hive.openBox<AttendanceRecordModel>(AppConstants.attendanceBox);
    await Hive.openBox<AttendanceEventModel>(AppConstants.pendingEventsBox);
    await Hive.openBox<LeaveRequestModel>(AppConstants.leaveBox);
    await Hive.openBox<LeaveBalanceModel>(AppConstants.leaveBalanceBox);
  }
}
