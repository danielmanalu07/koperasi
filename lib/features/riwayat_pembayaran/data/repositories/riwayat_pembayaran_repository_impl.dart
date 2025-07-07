import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/datasources/riwayat_pemabayaran_remote_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/riwayat_pembayaran.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/riwayat_pembayaran_repository.dart';

class RiwayatPembayaranRepositoryImpl implements RiwayatPembayaranRepository {
  final RiwayatPemabayaranRemoteDatasource riwayatPemabayaranRemoteDatasource;
  final LocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  RiwayatPembayaranRepositoryImpl({
    required this.riwayatPemabayaranRemoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, List<RiwayatPembayaran>>> getRiwayatPembayaran(
    int pinjamanDetail,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getToken();
        final riwayatPembayaran = await riwayatPemabayaranRemoteDatasource
            .getRiwayatPembayaran(pinjamanDetail, token!);
        return Right(riwayatPembayaran);
      } catch (e) {
        throw Left(e.toString());
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
