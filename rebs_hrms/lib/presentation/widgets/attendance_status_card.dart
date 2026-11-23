import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/attendance_event_model.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_state.dart';

class AttendanceStatusCard extends StatelessWidget {
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final List<AttendanceEventModel> todayEvents;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const AttendanceStatusCard({
    super.key,
    required this.hasCheckedIn,
    required this.hasCheckedOut,
    required this.todayEvents,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  String get _statusLabel {
    if (hasCheckedOut) return 'Checked Out';
    if (hasCheckedIn) return 'Checked In';
    return 'Not Checked In';
  }

  Color get _statusColor {
    if (hasCheckedOut) return Colors.grey;
    if (hasCheckedIn) return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text("Today's Attendance",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Chip(
                label: Text(_statusLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: _statusColor,
              ),
            ]),
            if (todayEvents.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...todayEvents.map((e) => _EventRow(event: e)),
            ],
            const SizedBox(height: 16),
            BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                final loading =
                    state is AttendanceLoading || state is AttendanceSyncing;
                if (loading) {
                  return const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  );
                }
                return Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Check In'),
                      onPressed: hasCheckedIn ? null : onCheckIn,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Check Out'),
                      onPressed:
                          (!hasCheckedIn || hasCheckedOut) ? null : onCheckOut,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white),
                    ),
                  ),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final AttendanceEventModel event;
  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final timeStr = event.timestamp.length >= 19
        ? '${event.timestamp.substring(11, 16)} UTC'
        : event.timestamp;
    final isCheckIn = event.type == 'check_in';

    final syncColor = switch (event.syncStatus) {
      SyncStatus.pendingSync => Colors.orange,
      SyncStatus.synced => Colors.green,
      SyncStatus.rejected => Colors.red,
    };
    final syncLabel = switch (event.syncStatus) {
      SyncStatus.pendingSync => 'Pending',
      SyncStatus.synced => 'Synced',
      SyncStatus.rejected => 'Rejected',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(isCheckIn ? Icons.login : Icons.logout,
            size: 16, color: isCheckIn ? Colors.green : Colors.red),
        const SizedBox(width: 6),
        Text('${isCheckIn ? 'In' : 'Out'}: $timeStr',
            style: const TextStyle(fontSize: 13)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: syncColor.withValues(alpha: 0.12),
              border: Border.all(color: syncColor),
              borderRadius: BorderRadius.circular(10)),
          child:
              Text(syncLabel, style: TextStyle(color: syncColor, fontSize: 11)),
        ),
      ]),
    );
  }
}
