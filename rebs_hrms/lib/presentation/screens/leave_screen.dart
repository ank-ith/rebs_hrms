import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/leave/leave_bloc.dart';
import '../bloc/leave/leave_event.dart';
import '../bloc/leave/leave_state.dart';
import '../../data/models/leave_request_model.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  String _leaveType = 'casual';
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LeaveBloc>().add(LoadLeaveData());
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    context.read<LeaveBloc>().add(SubmitLeaveRequest(
          leaveType: _leaveType,
          startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
          endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
          reason: _reasonCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('Leave Application',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<LeaveBloc, LeaveState>(
        listener: (context, state) {
          if (state is LeaveSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Leave submitted successfully!'),
              backgroundColor: Colors.green,
            ));
            setState(() {
              _startDate = null;
              _endDate = null;
              _reasonCtrl.clear();
            });
          } else if (state is LeaveValidationError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ));
          } else if (state is LeaveError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ));
          }
        },
        builder: (context, state) {
          if (state is LeaveLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Leave balance summary (if loaded)
              if (state is LeaveLoaded && state.balance != null)
                Card(
                  color: const Color(0xFFE3F2FD),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BalancePill(
                            label: 'Casual',
                            count: state.balance!.casualLeave,
                            color: Colors.blue),
                        _BalancePill(
                            label: 'Sick',
                            count: state.balance!.sickLeave,
                            color: Colors.purple),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Form
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Apply for Leave',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _leaveType,
                        decoration: const InputDecoration(
                            labelText: 'Leave Type',
                            border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(
                              value: 'casual', child: Text('Casual Leave')),
                          DropdownMenuItem(
                              value: 'sick', child: Text('Sick Leave')),
                        ],
                        onChanged: (v) => setState(() => _leaveType = v!),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_startDate == null
                                ? 'Start Date'
                                : DateFormat('dd MMM yyyy')
                                    .format(_startDate!)),
                            onPressed: () => _pickDate(true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_endDate == null
                                ? 'End Date'
                                : DateFormat('dd MMM yyyy').format(_endDate!)),
                            onPressed: () => _pickDate(false),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _reasonCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          hintText: 'Min 10 non-whitespace characters',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is LeaveSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                          child: state is LeaveSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Submit Leave Request',
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Leave history
              const Text('My Leave Requests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              if (state is LeaveLoaded && state.requests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No leave requests yet'),
                  ),
                )
              else if (state is LeaveLoaded)
                ...state.requests.map((r) => _LeaveRequestTile(request: r)),

              if (state is LeaveLoadError)
                Text(state.message, style: const TextStyle(color: Colors.red)),
            ],
          );
        },
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _BalancePill(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('$count',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      Text('$label Days', style: TextStyle(color: color, fontSize: 12)),
    ]);
  }
}

class _LeaveRequestTile extends StatelessWidget {
  final LeaveRequestModel request;
  const _LeaveRequestTile({required this.request});

  Color _statusColor() {
    switch (request.status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          request.leaveType == 'sick' ? Icons.sick : Icons.beach_access,
          color: const Color(0xFF1565C0),
        ),
        title: Text(
            '${request.leaveType[0].toUpperCase()}${request.leaveType.substring(1)} — ${request.startDate} to ${request.endDate}'),
        subtitle:
            Text(request.reason, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Chip(
          label: Text(request.status.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: _statusColor(),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
