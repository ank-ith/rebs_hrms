import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// ── In-memory state ───────────────────────────────────────────────────────────
final Set<String> processedEventIds = {};
final List<Map<String, dynamic>> attendanceEvents = [];
final List<Map<String, dynamic>> leaveRequests = [];

// Active scenario (can be changed via POST /scenario)
// Values: success | slow | error | conflict | leave_reject
String _scenario = 'success';

void main() async {
  final router = Router();

  // ── GET /employee/me ────────────────────────────────────────────────────────
  router.get('/employee/me', (Request req) async {
    await _applyScenario();
    return _json({
      'id': 'EMP001',
      'name': 'Ankith Kumar',
      'department': 'Engineering',
      'office_latitude': 12.9716,
      'office_longitude': 77.5946,
    });
  });

  // ── GET /attendance?month=YYYY-MM ───────────────────────────────────────────
  router.get('/attendance', (Request req) async {
    await _applyScenario();
    final month = req.url.queryParameters['month'] ?? '2026-11';
    return _json([
      {
        'date': '$month-21',
        'check_in_time': '09:05',
        'check_out_time': '18:12',
        'status': 'present'
      },
      {
        'date': '$month-20',
        'check_in_time': '09:00',
        'check_out_time': '17:58',
        'status': 'present'
      },
      {
        'date': '$month-19',
        'check_in_time': null,
        'check_out_time': null,
        'status': 'absent'
      },
      {
        'date': '$month-18',
        'check_in_time': '09:30',
        'check_out_time': '18:00',
        'status': 'present'
      },
      {
        'date': '$month-17',
        'check_in_time': '09:15',
        'check_out_time': '13:00',
        'status': 'half_day'
      },
    ]);
  });

  // ── POST /attendance/events ─────────────────────────────────────────────────
  router.post('/attendance/events', (Request req) async {
    await _applyScenario();

    final body =
        jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final eventId = body['event_id'] as String?;

    if (eventId == null) {
      return Response(400,
          body: jsonEncode({'message': 'event_id is required'}),
          headers: {'content-type': 'application/json'});
    }

    // Simulate duplicate conflict scenario
    if (_scenario == 'conflict') {
      return Response(409,
          body: jsonEncode(
              {'message': 'Attendance already exists for today'}),
          headers: {'content-type': 'application/json'});
    }

    // Idempotency check: same event_id already processed?
    if (processedEventIds.contains(eventId)) {
      return Response(409,
          body: jsonEncode(
              {'message': 'Event already recorded (idempotent)'}),
          headers: {'content-type': 'application/json'});
    }

    processedEventIds.add(eventId);
    attendanceEvents.add(body);

    return _json({'message': 'Event recorded', 'event_id': eventId});
  });

  // ── GET /leave/balance ──────────────────────────────────────────────────────
  router.get('/leave/balance', (Request req) async {
    await _applyScenario();
    return _json({'casual_leave': 8, 'sick_leave': 5});
  });

  // ── GET /leave/requests ─────────────────────────────────────────────────────
  router.get('/leave/requests', (Request req) async {
    await _applyScenario();
    final all = [
      {
        'id': 'LR001',
        'leave_type': 'casual',
        'start_date': '2026-12-24',
        'end_date': '2026-12-25',
        'reason': 'Christmas holidays with family',
        'status': 'approved',
      },
      {
        'id': 'LR002',
        'leave_type': 'sick',
        'start_date': '2026-11-10',
        'end_date': '2026-11-10',
        'reason': 'Fever and cold, need rest to recover',
        'status': 'approved',
      },
      ...leaveRequests,
    ];
    return _json(all);
  });

  // ── POST /leave/requests ────────────────────────────────────────────────────
  router.post('/leave/requests', (Request req) async {
    await _applyScenario();

    final body =
        jsonDecode(await req.readAsString()) as Map<String, dynamic>;

    // Simulate server-side leave rejection
    if (_scenario == 'leave_reject') {
      return Response(422,
          body: jsonEncode({
            'message':
                'Server: leave dates conflict with an approved request'
          }),
          headers: {'content-type': 'application/json'});
    }

    final newReq = {
      'id': 'LR${100 + leaveRequests.length}',
      'leave_type': body['leave_type'],
      'start_date': body['start_date'],
      'end_date': body['end_date'],
      'reason': body['reason'],
      'status': 'pending',
    };
    leaveRequests.add(newReq);
    return _json(newReq);
  });

  // ── POST /scenario — switch test scenario ───────────────────────────────────
  router.post('/scenario', (Request req) async {
    final body =
        jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    _scenario = body['scenario'] as String? ?? 'success';
    print('[MOCK] Scenario switched to: $_scenario');
    return _json({'scenario': _scenario});
  });

  // ── GET /scenario ────────────────────────────────────────────────────────────
  router.get('/scenario', (Request req) async {
    return _json({'current_scenario': _scenario});
  });

  // ── Middleware pipeline ──────────────────────────────────────────────────────
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(router.call);

  final server =
      await io.serve(handler, InternetAddress.anyIPv4, 8080);

  print('');
  print('🚀  REBS Mock API running at http://localhost:${server.port}');
  print('');
  print('Endpoints:');
  print('  GET  /employee/me');
  print('  GET  /attendance?month=YYYY-MM');
  print('  POST /attendance/events');
  print('  GET  /leave/balance');
  print('  GET  /leave/requests');
  print('  POST /leave/requests');
  print('');
  print('Scenario control (POST /scenario):');
  print('  success     — normal responses (default)');
  print('  slow        — 3-second delay on every request');
  print('  error       — 500 Internal Server Error');
  print('  conflict    — 409 on attendance POST (duplicate)');
  print('  leave_reject— 422 on leave POST (server validation failure)');
  print('');
  print('Example:');
  print(
      "  curl -X POST http://localhost:8080/scenario -H 'Content-Type: application/json' -d '{\"scenario\":\"slow\"}'");
  print('');
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Response _json(Object data, {int status = 200}) => Response(
      status,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );

Future<void> _applyScenario() async {
  switch (_scenario) {
    case 'slow':
      await Future.delayed(const Duration(seconds: 3));
      break;
    case 'error':
      throw Exception('Simulated 500 Internal Server Error');
    default:
      break;
  }
}

Middleware _cors() => (Handler inner) => (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      final response = await inner(request);
      return response.change(headers: _corsHeaders);
    };

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};
