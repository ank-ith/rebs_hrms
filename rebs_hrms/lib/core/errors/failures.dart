import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Location unavailable']);
}

class LocationPermissionDeniedFailure extends Failure {
  const LocationPermissionDeniedFailure(
      [super.message = 'Location permission denied']);
}

class LocationPermissionPermanentlyDeniedFailure extends Failure {
  const LocationPermissionPermanentlyDeniedFailure(
      [super.message =
          'Location permission permanently denied. Please enable in app settings.']);
}

class GeofenceFailure extends Failure {
  final double distanceMeters;
  GeofenceFailure(this.distanceMeters)
      : super(
            'You are ${distanceMeters.toStringAsFixed(0)}m from the office. Must be within 200m to check in/out.');

  @override
  List<Object> get props => [message, distanceMeters];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class DuplicateEventFailure extends Failure {
  const DuplicateEventFailure(
      [super.message = 'Attendance already recorded for today']);
}
