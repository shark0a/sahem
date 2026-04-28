import 'package:equatable/equatable.dart';
import '../constants/app_strings.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = AppStrings.serverError});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = AppStrings.networkError});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = AppStrings.cacheError});
}

class LocationFailure extends Failure {
  const LocationFailure({super.message = AppStrings.locationError});
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure(
      {super.message = AppStrings.locationPermissionDenied});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = AppStrings.unknownError});
}
