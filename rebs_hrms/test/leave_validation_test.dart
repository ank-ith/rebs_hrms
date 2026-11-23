import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:rebs_hrms/data/models/leave_balance_model.dart';
import 'package:rebs_hrms/data/models/leave_request_model.dart';
import 'package:rebs_hrms/domain/repositories/leave_repository.dart';
import 'package:rebs_hrms/presentation/bloc/leave/leave_bloc.dart';
import 'package:rebs_hrms/presentation/bloc/leave/leave_event.dart';
import 'package:rebs_hrms/presentation/bloc/leave/leave_state.dart';
import 'package:rebs_hrms/core/errors/failures.dart';

class MockLeaveRepository extends Mock implements LeaveRepository {}

void main() {
  late LeaveBloc bloc;
  late MockLeaveRepository mockRepo;

  final balance = LeaveBalanceModel(casualLeave: 8, sickLeave: 5);

  final existingApproved = LeaveRequestModel(
    id: 'LR001',
    leaveType: 'casual',
    startDate: '2026-12-20',
    endDate: '2026-12-25',
    reason: 'Christmas holiday travel confirmed',
    status: 'approved',
  );

  setUp(() {
    mockRepo = MockLeaveRepository();
    bloc = LeaveBloc(repo: mockRepo);
  });

  tearDown(() => bloc.close());

  // ── Test 4: Overlapping leave dates rejected ───────────────────────────────
  blocTest<LeaveBloc, LeaveState>(
    '4. overlapping leave dates emit LeaveValidationError',
    build: () {
      when(() => mockRepo.getLeaveBalance()).thenAnswer((_) async => balance);
      when(() => mockRepo.getLeaveRequests())
          .thenAnswer((_) async => [existingApproved]);
      return bloc;
    },
    act: (b) async {
      b.add(LoadLeaveData());
      // Wait for data to load
      await Future.delayed(const Duration(milliseconds: 50));
      // Submit overlapping dates: Dec 23–27 overlaps Dec 20–25
      b.add(const SubmitLeaveRequest(
        leaveType: 'casual',
        startDate: '2026-12-23',
        endDate: '2026-12-27',
        reason: 'Extending my holiday plans here',
      ));
    },
    expect: () => [
      isA<LeaveLoading>(),
      isA<LeaveLoaded>(),
      isA<LeaveValidationError>(),
      isA<LeaveLoaded>(),
    ],
  );

  // ── Additional: past start date rejected ───────────────────────────────────
  blocTest<LeaveBloc, LeaveState>(
    '4b. past start date emits LeaveValidationError',
    build: () {
      when(() => mockRepo.getLeaveBalance()).thenAnswer((_) async => balance);
      when(() => mockRepo.getLeaveRequests()).thenAnswer((_) async => []);
      return bloc;
    },
    act: (b) async {
      b.add(LoadLeaveData());
      await Future.delayed(const Duration(milliseconds: 50));
      b.add(const SubmitLeaveRequest(
        leaveType: 'casual',
        startDate: '2025-01-01', // past date
        endDate: '2025-01-02',
        reason: 'Historical leave request attempt',
      ));
    },
    expect: () => [
      isA<LeaveLoading>(),
      isA<LeaveLoaded>(),
      isA<LeaveValidationError>(),
      isA<LeaveLoaded>(),
    ],
  );

  // ── Additional: insufficient balance rejected ──────────────────────────────
  blocTest<LeaveBloc, LeaveState>(
    '4c. requesting more days than balance emits LeaveValidationError',
    build: () {
      when(() => mockRepo.getLeaveBalance()).thenAnswer(
          (_) async => LeaveBalanceModel(casualLeave: 2, sickLeave: 1));
      when(() => mockRepo.getLeaveRequests()).thenAnswer((_) async => []);
      return bloc;
    },
    act: (b) async {
      b.add(LoadLeaveData());
      await Future.delayed(const Duration(milliseconds: 50));
      // Request 10 days but only 2 available
      b.add(SubmitLeaveRequest(
        leaveType: 'casual',
        startDate: DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String()
            .substring(0, 10),
        endDate: DateTime.now()
            .add(const Duration(days: 10))
            .toIso8601String()
            .substring(0, 10),
        reason: 'Extended vacation trip planned',
      ));
    },
    expect: () => [
      isA<LeaveLoading>(),
      isA<LeaveLoaded>(),
      isA<LeaveValidationError>(),
      isA<LeaveLoaded>(),
    ],
  );

  blocTest<LeaveBloc, LeaveState>(
    'offline submission keeps cached leave data visible',
    build: () {
      when(() => mockRepo.getLeaveBalance()).thenAnswer((_) async => balance);
      when(() => mockRepo.getLeaveRequests())
          .thenAnswer((_) async => [existingApproved]);
      when(() => mockRepo.submitLeaveRequest(
                leaveType: any(named: 'leaveType'),
                startDate: any(named: 'startDate'),
                endDate: any(named: 'endDate'),
                reason: any(named: 'reason'),
              ))
          .thenThrow(const NetworkFailure(
              'Internet required to submit leave request'));
      return bloc;
    },
    act: (b) async {
      b.add(LoadLeaveData());
      await Future.delayed(const Duration(milliseconds: 50));
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      b.add(SubmitLeaveRequest(
        leaveType: 'casual',
        startDate: tomorrow.toIso8601String().substring(0, 10),
        endDate: tomorrow.toIso8601String().substring(0, 10),
        reason: 'Offline leave submission test',
      ));
    },
    expect: () => [
      isA<LeaveLoading>(),
      isA<LeaveLoaded>(),
      isA<LeaveSubmitting>(),
      isA<LeaveError>(),
      isA<LeaveLoaded>(),
    ],
    verify: (b) {
      final loaded = b.state as LeaveLoaded;
      expect(loaded.balance, balance);
      expect(loaded.requests, [existingApproved]);
    },
  );

  blocTest<LeaveBloc, LeaveState>(
    'cached leave requests remain visible when the balance is unavailable',
    build: () {
      when(() => mockRepo.getLeaveBalance())
          .thenThrow(const NetworkFailure('Leave balance unavailable offline'));
      when(() => mockRepo.getLeaveRequests())
          .thenAnswer((_) async => [existingApproved]);
      return bloc;
    },
    act: (b) => b.add(LoadLeaveData()),
    expect: () => [isA<LeaveLoading>(), isA<LeaveLoaded>()],
    verify: (b) {
      final loaded = b.state as LeaveLoaded;
      expect(loaded.balance, isNull);
      expect(loaded.requests, [existingApproved]);
    },
  );
}
