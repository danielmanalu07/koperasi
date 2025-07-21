import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/pinjaman_remaining_entity.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/pinjaman_remaining_repository.dart';

class GetPinjamanRemainingUsecase
    implements Usecase<PinjamanRemainingEntity, NoParams> {
  final PinjamanRemainingRepository pinjamanRemainingRepository;

  GetPinjamanRemainingUsecase(this.pinjamanRemainingRepository);

  @override
  Future<Either<Failures, PinjamanRemainingEntity>> call(
    NoParams params,
  ) async {
    final res = await pinjamanRemainingRepository.getPinjamanRemaining();
    return res;
  }
}
