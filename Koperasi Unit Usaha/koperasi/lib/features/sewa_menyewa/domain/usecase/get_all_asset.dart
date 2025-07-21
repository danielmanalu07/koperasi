import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/asset.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/asset_repository.dart';

class GetAllAsset implements Usecase<List<Asset>, NoParams> {
  final AssetRepository assetRepository;

  GetAllAsset(this.assetRepository);

  @override
  Future<Either<Failures, List<Asset>>> call(NoParams params) async {
    final res = await assetRepository.getAllAsset();
    return res;
  }
}
