import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/asset.dart';

abstract class AssetRepository {
  Future<Either<Failures, List<Asset>>> getAllAsset();
  Future<Either<Failures, Asset>> addAsset(
    String nama,
    DateTime tanggalBeli,
    double hargaBeli,
    String keterangan,
  );
}
