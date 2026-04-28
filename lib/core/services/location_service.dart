import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../errors/failures.dart';

class LocationService {
  Future<Either<Failure, String>> getCountryCode() async {
    try {
      // 1. Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(LocationFailure(message: 'Location services disabled'));
      }

      // 2. Check & request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(LocationPermissionFailure());
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return const Left(LocationPermissionFailure(
            message: 'Location permission permanently denied'));
      }

      // 3. Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );

      // 4. Reverse geocode
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty || placemarks.first.isoCountryCode == null) {
        return const Left(LocationFailure(message: 'Could not determine country'));
      }

      return Right(placemarks.first.isoCountryCode!);
    } catch (e) {
      return Left(LocationFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> getCityName() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const Left(LocationPermissionFailure());
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return const Left(LocationFailure());
      }

      final placemark = placemarks.first;
      final city = placemark.locality ??
          placemark.administrativeArea ??
          placemark.country ??
          'Unknown';

      return Right(city);
    } catch (e) {
      return Left(LocationFailure(message: e.toString()));
    }
  }
}
