import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/riwayat_pembayaran.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/riwayat_pembayaran_repository.dart';

class GetRiwayatPembayaranUsecase
    implements Usecase<List<RiwayatPembayaran>, NoParams> {
  final RiwayatPembayaranRepository riwayatPembayaranRepository;

  GetRiwayatPembayaranUsecase(this.riwayatPembayaranRepository);

  @override
  Future<Either<Failures, List<RiwayatPembayaran>>> call(
    NoParams params,
  ) async {
    final res = await riwayatPembayaranRepository.getRiwayatPembayaran();
    return res;
  }
}
