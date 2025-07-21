import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/features/sewa_menyewa/data/dataSources/asset_remote_data_source.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/asset.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/asset_repository.dart';

class AssetRepositoryImpl implements AssetRepository {
  final AssetRemoteDataSource assetRemoteDataSource;
  final NetworkInfo networkInfo;

  AssetRepositoryImpl({
    required this.assetRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, Asset>> addAsset(
    String nama,
    DateTime tanggalBeli,
    double hargaBeli,
    String keterangan,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final asset = await assetRemoteDataSource.addAsset(
          nama,
          tanggalBeli,
          hargaBeli,
          keterangan,
        );
        return Right(asset);
      } catch (e) {
        throw Left(e.toString());
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, List<Asset>>> getAllAsset() async {
    if (await networkInfo.isConnected) {
      try {
        final assets = await assetRemoteDataSource.getAllAsset();
        return Right(assets);
      } catch (e) {
        throw Left(e.toString());
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
