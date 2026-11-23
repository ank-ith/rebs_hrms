import 'package:flutter/material.dart';
import '../../data/models/attendance_record_model.dart';

class AttendanceHistoryList extends StatelessWidget {
  final List<AttendanceRecordModel> records;
  const AttendanceHistoryList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Attendance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No records')),
              )
            else
              ...records.map((r) => _RecordRow(record: r)),
          ],
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final AttendanceRecordModel record;
  const _RecordRow({required this.record});

  Color _color() {
    switch (record.status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _color(), shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(record.date, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        if (record.checkInTime != null)
          Text('In: ${record.checkInTime}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(width: 8),
        if (record.checkOutTime != null)
          Text('Out: ${record.checkOutTime}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ]),
    );
  }
}
