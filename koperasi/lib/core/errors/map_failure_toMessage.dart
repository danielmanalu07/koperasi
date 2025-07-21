import 'package:koperasi/core/errors/failures.dart';

class MapFailureToMessage {
  static String map(Failures failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return (failure as ServerFailure).message;
      case AuthFailure _:
        return (failure as AuthFailure).message;
      case NetworkFailure _:
        return (failure as NetworkFailure).message;
      case CacheFailure _:
        return 'Cache Error: ${(failure as CacheFailure).message}';
      default:
        return 'Unexpected Error';
    }
  }
}
