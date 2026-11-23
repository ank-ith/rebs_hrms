class AppConstants {
  // Office location — update coordinates or set debugMockLocation=true for testing
  static const double officeLatitude = 12.9716;
  static const double officeLongitude = 77.5946;
  static const double geofenceRadiusMeters = 200.0;

  // Set to true to bypass geofence check during testing/review
  static const bool debugMockLocation = false;

  // Company timezone
  static const String companyTimezone = 'Asia/Kolkata';

  // Mock API base URL
  // Android emulator → use 10.0.2.2:8080 (points to host machine localhost)
  // Physical device → use your LAN IP e.g. 192.168.1.x:8080
  static const String baseUrl = 'https://constant-wooing-amplify.ngrok-free.dev';
  // 'http://10.0.2.2:8080';

  // Hive box names
  static const String employeeBox = 'employee_box';
  static const String attendanceBox = 'attendance_box';
  static const String pendingEventsBox = 'pending_events_box';
  static const String leaveBox = 'leave_box';
  static const String leaveBalanceBox = 'leave_balance_box';
}
