import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:koperasi/features/sewa_menyewa/data/dataSources/dashboard_remote_data_source.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/dashboard.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final LocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, Dashboard>> getDashboard() async {
    if (await networkInfo.isConnected) {
      try {
        final dashboard = await remoteDataSource.getDashboard();
        return Right(dashboard);
      } catch (e) {
        throw Left(e.toString());
      }
    } else {
      return const Left(NetworkFailure('No Internet Conection'));
    }
  }
}
