import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/dashboard.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/dashboard_repository.dart';

class GetDashboardData implements Usecase<Dashboard, NoParams> {
  final DashboardRepository dashboardRepository;

  GetDashboardData(this.dashboardRepository);

  @override
  Future<Either<Failures, Dashboard>> call(NoParams params) async {
    final res = await dashboardRepository.getDashboard();
    return res;
  }
}
