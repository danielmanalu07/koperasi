import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/asset.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/asset_repository.dart';

class AddAssetData implements Usecase<Asset, Asset> {
  final AssetRepository assetRepository;

  AddAssetData(this.assetRepository);

  @override
  Future<Either<Failures, Asset>> call(Asset params) async {
    final res = await assetRepository.addAsset(
      params.name,
      params.purchaseDate,
      params.price.toDouble(),
      params.description,
    );

    return res;
  }
}
