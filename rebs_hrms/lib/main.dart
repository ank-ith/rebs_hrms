import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/services/location_service.dart';
import 'data/local/attendance_local_datasource.dart';
import 'data/local/employee_local_datasource.dart';
import 'data/local/hive_service.dart';
import 'data/local/leave_local_datasource.dart';
import 'data/remote/attendance_api_service.dart';
import 'data/remote/employee_api_service.dart';
import 'data/remote/leave_api_service.dart';
import 'data/repositories/attendance_repository_impl.dart';
import 'data/repositories/employee_repository_impl.dart';
import 'data/repositories/leave_repository_impl.dart';
import 'presentation/bloc/attendance/attendance_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_event.dart';
import 'presentation/bloc/leave/leave_bloc.dart';
import 'presentation/screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const RebsApp());
}

class RebsApp extends StatelessWidget {
  const RebsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Dependency Wiring (manual DI) ────────────────────────────────────────
    final dio = DioClient.create();
    final connectivity = Connectivity();
    final networkInfo = NetworkInfoImpl(connectivity);
    final locationService = LocationService();

    final employeeApi = EmployeeApiService(dio);
    final attendanceApi = AttendanceApiService(dio);
    final leaveApi = LeaveApiService(dio);

    final employeeLocal = EmployeeLocalDataSource();
    final attendanceLocal = AttendanceLocalDataSource();
    final leaveLocal = LeaveLocalDataSource();

    final employeeRepo = EmployeeRepositoryImpl(
        api: employeeApi, local: employeeLocal, network: networkInfo);
    final attendanceRepo = AttendanceRepositoryImpl(
        api: attendanceApi,
        local: attendanceLocal,
        network: networkInfo,
        location: locationService);
    final leaveRepo = LeaveRepositoryImpl(
        api: leaveApi, local: leaveLocal, network: networkInfo);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DashboardBloc(
            employeeRepo: employeeRepo,
            attendanceRepo: attendanceRepo,
            leaveRepo: leaveRepo,
            network: networkInfo,
          )..add(LoadDashboard()),
        ),
        BlocProvider(
          create: (_) => AttendanceBloc(
            repo: attendanceRepo,
            location: locationService,
          ),
        ),
        BlocProvider(create: (_) => LeaveBloc(repo: leaveRepo)),
      ],
      child: MaterialApp(
        title: 'REBS HRMS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}
