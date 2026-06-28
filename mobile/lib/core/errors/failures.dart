import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required super.message, this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Please try again.'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Failed to load cached data.'});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Connection timed out. Please try again.'});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'An unexpected error occurred.'});
}

class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'Permission denied.'});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found.'});
}

class StorageFailure extends Failure {
  const StorageFailure({super.message = 'Storage operation failed.'});
}
