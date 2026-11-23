import 'package:equatable/equatable.dart';
import '../../../data/models/leave_balance_model.dart';
import '../../../data/models/leave_request_model.dart';

abstract class LeaveState extends Equatable {
  const LeaveState();
  @override
  List<Object?> get props => [];
}

class LeaveInitial extends LeaveState {}

class LeaveLoading extends LeaveState {}

class LeaveLoaded extends LeaveState {
  final LeaveBalanceModel? balance;
  final List<LeaveRequestModel> requests;

  const LeaveLoaded({required this.balance, required this.requests});

  @override
  List<Object?> get props => [balance, requests];
}

class LeaveSubmitting extends LeaveLoaded {
  const LeaveSubmitting({required super.balance, required super.requests});
}

class LeaveSubmitSuccess extends LeaveLoaded {
  const LeaveSubmitSuccess({required super.balance, required super.requests});
}

class LeaveValidationError extends LeaveLoaded {
  final String message;
  const LeaveValidationError(
    this.message, {
    required super.balance,
    required super.requests,
  });
  @override
  List<Object?> get props => [...super.props, message];
}

class LeaveError extends LeaveLoaded {
  final String message;
  const LeaveError(
    this.message, {
    required super.balance,
    required super.requests,
  });
  @override
  List<Object?> get props => [...super.props, message];
}

class LeaveLoadError extends LeaveState {
  final String message;
  const LeaveLoadError(this.message);

  @override
  List<Object?> get props => [message];
}
