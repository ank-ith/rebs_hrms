import 'package:flutter_bloc/flutter_bloc.dart';
import 'leave_event.dart';
import 'leave_state.dart';
import '../../../domain/repositories/leave_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/leave_request_model.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository _repo;

  LeaveBloc({required LeaveRepository repo})
      : _repo = repo,
        super(LeaveInitial()) {
    on<LoadLeaveData>(_onLoad);
    on<SubmitLeaveRequest>(_onSubmit);
    on<ClearLeaveFeedback>(_onClearFeedback);
  }

  Future<void> _onLoad(LoadLeaveData event, Emitter<LeaveState> emit) async {
    final previous = state;
    if (previous is! LeaveLoaded) emit(LeaveLoading());
    var balance = previous is LeaveLoaded ? previous.balance : null;
    List<LeaveRequestModel> requests =
        previous is LeaveLoaded ? previous.requests : [];
    Object? failure;

    try {
      balance = await _repo.getLeaveBalance();
    } catch (e) {
      failure = e;
    }

    try {
      requests = await _repo.getLeaveRequests();
    } catch (e) {
      failure ??= e;
    }

    if (balance != null || requests.isNotEmpty || previous is LeaveLoaded) {
      emit(LeaveLoaded(balance: balance, requests: requests));
    } else {
      emit(LeaveLoadError(failure?.toString() ?? 'Leave data unavailable'));
    }
  }

  Future<void> _onSubmit(
      SubmitLeaveRequest event, Emitter<LeaveState> emit) async {
    final current = state;
    if (current is! LeaveLoaded) {
      emit(const LeaveLoadError(
          'Leave data must finish loading before submission'));
      return;
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final start = DateTime.parse(event.startDate);
    final end = DateTime.parse(event.endDate);

    if (start.isBefore(todayOnly)) {
      _emitValidation(emit, current, 'Start date cannot be in the past');
      return;
    }
    if (end.isBefore(start)) {
      _emitValidation(emit, current, 'End date cannot be before start date');
      return;
    }
    final nonWsChars = event.reason.replaceAll(RegExp(r'\s'), '').length;
    if (nonWsChars < 10) {
      _emitValidation(emit, current,
          'Reason must have at least 10 non-whitespace characters');
      return;
    }

    final daysRequested = end.difference(start).inDays + 1;

    final balance = current.balance;
    if (balance == null) {
      _emitError(emit, current,
          'Leave balance is unavailable. Please reconnect and try again.');
      return;
    }

    final available =
        event.leaveType == 'casual' ? balance.casualLeave : balance.sickLeave;

    if (daysRequested > available) {
      _emitValidation(emit, current,
          'Requested $daysRequested days exceeds $available available ${event.leaveType} leave days');
      return;
    }

    for (final req in current.requests) {
      if (req.status == 'rejected') continue;
      final reqStart = DateTime.parse(req.startDate);
      final reqEnd = DateTime.parse(req.endDate);
      if (!(end.isBefore(reqStart) || start.isAfter(reqEnd))) {
        _emitValidation(
            emit, current, 'Dates overlap with an existing leave request');
        return;
      }
    }

    emit(LeaveSubmitting(balance: current.balance, requests: current.requests));
    try {
      await _repo.submitLeaveRequest(
        leaveType: event.leaveType,
        startDate: event.startDate,
        endDate: event.endDate,
        reason: event.reason,
      );
      emit(LeaveSubmitSuccess(
          balance: current.balance, requests: current.requests));
      add(LoadLeaveData());
    } on NetworkFailure catch (f) {
      _emitError(emit, current, f.message);
    } catch (e) {
      _emitError(emit, current, e.toString());
    }
  }

  void _emitValidation(
      Emitter<LeaveState> emit, LeaveLoaded current, String message) {
    emit(LeaveValidationError(message,
        balance: current.balance, requests: current.requests));
    add(const ClearLeaveFeedback());
  }

  void _emitError(
      Emitter<LeaveState> emit, LeaveLoaded current, String message) {
    emit(LeaveError(message,
        balance: current.balance, requests: current.requests));
    add(const ClearLeaveFeedback());
  }

  void _onClearFeedback(ClearLeaveFeedback event, Emitter<LeaveState> emit) {
    final current = state;
    if (current is LeaveLoaded && current is! LeaveSubmitting) {
      emit(LeaveLoaded(balance: current.balance, requests: current.requests));
    }
  }
}
