import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    var status = await Permission.location.status;

    if (status.isPermanentlyDenied) {
      throw const LocationPermissionPermanentlyDeniedFailure();
    }

    if (!status.isGranted) {
      status = await Permission.location.request();
      if (status.isPermanentlyDenied) {
        throw const LocationPermissionPermanentlyDeniedFailure();
      }
      if (!status.isGranted) {
        throw const LocationPermissionDeniedFailure();
      }
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      throw const LocationFailure('Could not get current location');
    }
  }

  /// Haversine distance in metres between given coords and office
  double distanceFromOffice(double lat, double lng) {
    const R = 6371000.0;
    final lat1 = AppConstants.officeLatitude * pi / 180;
    final lat2 = lat * pi / 180;
    final dLat = (lat - AppConstants.officeLatitude) * pi / 180;
    final dLng = (lng - AppConstants.officeLongitude) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }
}
