import 'package:flutter/material.dart';
import '../../data/models/leave_balance_model.dart';

class LeaveBalanceCard extends StatelessWidget {
  final LeaveBalanceModel balance;
  const LeaveBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Leave Balance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              _Tile(
                  label: 'Casual',
                  count: balance.casualLeave,
                  color: Colors.blue),
              const SizedBox(width: 12),
              _Tile(
                  label: 'Sick',
                  count: balance.sickLeave,
                  color: Colors.purple),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _Tile({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text('$count',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ]),
      ),
    );
  }
}
