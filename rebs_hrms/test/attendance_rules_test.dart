import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:rebs_hrms/core/errors/failures.dart';
import 'package:rebs_hrms/core/network/network_info.dart';
import 'package:rebs_hrms/core/services/location_service.dart';
import 'package:rebs_hrms/data/local/attendance_local_datasource.dart';
import 'package:rebs_hrms/data/models/attendance_event_model.dart';
import 'package:rebs_hrms/data/remote/attendance_api_service.dart';
import 'package:rebs_hrms/data/repositories/attendance_repository_impl.dart';

class MockAttendanceApi extends Mock implements AttendanceApiService {}

class MockAttendanceLocal extends Mock implements AttendanceLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockLocationService extends Mock implements LocationService {}

void main() {
  late AttendanceRepositoryImpl repo;
  late MockAttendanceApi mockApi;
  late MockAttendanceLocal mockLocal;
  late MockNetworkInfo mockNetwork;
  late MockLocationService mockLocation;

  final today = DateTime.now().toIso8601String().substring(0, 10);

  // ── Register fallback values for custom types used with any() ─────────────
  setUpAll(() {
    registerFallbackValue(SyncStatus.pendingSync);
    registerFallbackValue(AttendanceEventModel(
      eventId: 'fallback',
      type: 'check_in',
      timestamp: '2026-01-01T00:00:00Z',
      latitude: 0,
      longitude: 0,
    ));
  });

  setUp(() {
    mockApi = MockAttendanceApi();
    mockLocal = MockAttendanceLocal();
    mockNetwork = MockNetworkInfo();
    mockLocation = MockLocationService();

    repo = AttendanceRepositoryImpl(
      api: mockApi,
      local: mockLocal,
      network: mockNetwork,
      location: mockLocation,
    );

    // Default: offline, no events
    when(() => mockNetwork.isConnected).thenAnswer((_) async => false);
    when(() => mockLocal.getAllEvents()).thenReturn([]);
    when(() => mockLocal.getPendingEvents()).thenReturn([]);
    when(() => mockLocation.distanceFromOffice(any(), any())).thenReturn(0);
  });

  // ── Test 1: Check-out without check-in is rejected ────────────────────────
  test('1. check-out without prior check-in throws ValidationFailure', () {
    when(() => mockLocal.getAllEvents()).thenReturn([]);

    expect(
      () async => repo.checkOut(lat: 12.9716, lng: 77.5946),
      throwsA(isA<ValidationFailure>()),
    );
  });

  // ── Test 2: Duplicate check-in throws DuplicateEventFailure ───────────────
  test('2. repeated check-in throws DuplicateEventFailure', () {
    final existing = AttendanceEventModel(
      eventId: 'uuid-ci',
      type: 'check_in',
      timestamp: '${today}T09:00:00Z',
      latitude: 12.9716,
      longitude: 77.5946,
      syncStatusIndex: SyncStatus.synced.index,
    );
    when(() => mockLocal.getAllEvents()).thenReturn([existing]);

    expect(
      () async => repo.checkIn(lat: 12.9716, lng: 77.5946),
      throwsA(isA<DuplicateEventFailure>()),
    );
  });

  // ── Test 3: Pending events persist and sync in FIFO order ─────────────────
  test('3. pending events are synced in FIFO order (check-in before check-out)',
      () async {
    final checkIn = AttendanceEventModel(
      eventId: 'uuid-ci',
      type: 'check_in',
      timestamp: '${today}T09:00:00Z',
      latitude: 12.9716,
      longitude: 77.5946,
      syncStatusIndex: SyncStatus.pendingSync.index,
    );
    final checkOut = AttendanceEventModel(
      eventId: 'uuid-co',
      type: 'check_out',
      timestamp: '${today}T18:00:00Z',
      latitude: 12.9716,
      longitude: 77.5946,
      syncStatusIndex: SyncStatus.pendingSync.index,
    );

    when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
    when(() => mockLocal.getPendingEvents()).thenReturn([checkIn, checkOut]);
    // Use any() for all args since SyncStatus fallback is now registered
    when(() => mockApi.submitEvent(any())).thenAnswer((_) async => true);
    when(() => mockLocal.updateEventStatus(
          any(),
          any(),
          reason: any(named: 'reason'),
        )).thenAnswer((_) async {});

    await repo.syncPendingEvents();

    // Verify FIFO: check_in submitted before check_out
    verifyInOrder([
      () => mockApi.submitEvent(checkIn),
      () => mockApi.submitEvent(checkOut),
    ]);
  });

  // ── Test 5: Idempotency — 409 on retry marks event Synced ─────────────────
  test('5. 409 conflict on retry marks event as Synced (idempotent)', () async {
    final event = AttendanceEventModel(
      eventId: 'uuid-idempotent',
      type: 'check_in',
      timestamp: '${today}T09:00:00Z',
      latitude: 12.9716,
      longitude: 77.5946,
      syncStatusIndex: SyncStatus.pendingSync.index,
    );

    when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
    when(() => mockLocal.getPendingEvents()).thenReturn([event]);

    // Server returns 409 — event already exists
    when(() => mockApi.submitEvent(any())).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/attendance/events'),
        response: Response(
          requestOptions: RequestOptions(path: '/attendance/events'),
          statusCode: 409,
          data: {'message': 'Already recorded'},
        ),
        type: DioExceptionType.badResponse,
      ),
    );
    when(() => mockLocal.updateEventStatus(
          any(),
          any(),
          reason: any(named: 'reason'),
        )).thenAnswer((_) async {});

    await repo.syncPendingEvents();

    // Capture what updateEventStatus was called with
    final captured = verify(() => mockLocal.updateEventStatus(
          captureAny(),
          captureAny(),
          reason: captureAny(named: 'reason'),
        )).captured;

    // captured = [eventId, status, reason] — status must be synced, not rejected
    expect(captured[0], equals('uuid-idempotent'));
    expect(captured[1], equals(SyncStatus.synced));
  });
}
