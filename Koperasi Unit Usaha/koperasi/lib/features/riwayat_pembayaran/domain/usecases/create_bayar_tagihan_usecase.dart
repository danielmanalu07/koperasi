import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/bayar_entity.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/bayar_repository.dart';

class CreateBayarTagihanUsecase
    implements Usecase<BayarEntity, CreateBayarTagihanParams> {
  final BayarRepository bayarRepository;

  CreateBayarTagihanUsecase(this.bayarRepository);

  @override
  Future<Either<Failures, BayarEntity>> call(
    CreateBayarTagihanParams params,
  ) async {
    final result = await bayarRepository.bayarTagihanBulanan(
      params.pinjamanDetail,
      params.image,
      params.amount,
      params.type,
    );
    return result;
  }
}

class CreateBayarTagihanParams extends Equatable {
  final int pinjamanDetail;
  final num amount;
  final String type;
  final String? image;

  const CreateBayarTagihanParams({
    required this.pinjamanDetail,
    required this.amount,
    required this.type,
    this.image,
  });

  @override
  List<Object?> get props => [pinjamanDetail, amount, type, image];
}
