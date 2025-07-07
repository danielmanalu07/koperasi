import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/riwayat_pembayaran.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/riwayat_pembayaran_repository.dart';

class GetRiwayatPembayaranUsecase
    implements Usecase<List<RiwayatPembayaran>, GetRiwayatPembayaranParams> {
  final RiwayatPembayaranRepository riwayatPembayaranRepository;

  GetRiwayatPembayaranUsecase(this.riwayatPembayaranRepository);

  @override
  Future<Either<Failures, List<RiwayatPembayaran>>> call(
    GetRiwayatPembayaranParams params,
  ) async {
    final res = await riwayatPembayaranRepository.getRiwayatPembayaran(
      params.pinjamanDetail,
    );
    return res;
  }
}

class GetRiwayatPembayaranParams extends Equatable {
  final int pinjamanDetail;

  const GetRiwayatPembayaranParams(this.pinjamanDetail);

  @override
  List<Object?> get props => [pinjamanDetail];
}
