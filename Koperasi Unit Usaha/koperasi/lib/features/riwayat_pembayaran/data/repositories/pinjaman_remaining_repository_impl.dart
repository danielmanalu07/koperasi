import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/datasources/pinjaman_remaining_remote_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/pinjaman_remaining_entity.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/pinjaman_remaining_repository.dart';

class PinjamanRemainingRepositoryImpl implements PinjamanRemainingRepository {
  final PinjamanRemainingRemoteDatasource pinjamanRemainingRemoteDatasource;
  final LocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  PinjamanRemainingRepositoryImpl({
    required this.pinjamanRemainingRemoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, PinjamanRemainingEntity>>
  getPinjamanRemaining() async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getToken();
        final pinjamanRemaining = await pinjamanRemainingRemoteDatasource
            .getPinjamanRemaining(token!);
        return Right(pinjamanRemaining);
      } catch (e) {
        throw Left(e.toString());
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
