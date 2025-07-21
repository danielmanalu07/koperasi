import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/dashboard.dart';

abstract class DashboardRepository {
  Future<Either<Failures, Dashboard>> getDashboard();
}
