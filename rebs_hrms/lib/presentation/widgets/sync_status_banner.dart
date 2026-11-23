import 'package:flutter/material.dart';

class SyncStatusBanner extends StatelessWidget {
  final int pendingCount;
  const SyncStatusBanner({super.key, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(children: [
        const Icon(Icons.wifi_off, color: Colors.orange, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            pendingCount > 0
                ? 'Offline — $pendingCount action(s) pending sync'
                : 'Offline — viewing cached data',
            style: const TextStyle(color: Colors.orange),
          ),
        ),
      ]),
    );
  }
}
