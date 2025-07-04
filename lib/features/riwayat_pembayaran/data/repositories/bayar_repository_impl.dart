import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/exceptions.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/datasources/bayar_remote_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/bayar_entity.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/bayar_repository.dart';

class BayarRepositoryImpl implements BayarRepository {
  final BayarRemoteDatasource bayarRemoteDatasource;
  final LocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  BayarRepositoryImpl({
    required this.bayarRemoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, BayarEntity>> bayarTagihanBulanan(
    int pinjamanDetail,
    String? image,
    num amount,
    String type,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getToken();
        final bayar = await bayarRemoteDatasource.bayarTagihan(
          pinjamanDetail,
          image,
          amount,
          type,
          token!,
        );
        return Right(bayar);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: $e'));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
