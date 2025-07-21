import 'package:equatable/equatable.dart';

abstract class Failures extends Equatable {
  final String message;

  const Failures(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failures {
  const ServerFailure(super.message);
}

class AuthFailure extends Failures {
  const AuthFailure(super.message);
}

class CacheFailure extends Failures {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failures {
  const NetworkFailure(super.message);
}
