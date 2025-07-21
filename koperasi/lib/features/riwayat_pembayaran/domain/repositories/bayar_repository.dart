import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/bayar_entity.dart';

abstract class BayarRepository {
  Future<Either<Failures, BayarEntity>> bayarTagihanBulanan(
    int pinjamanDetail,
    String? image,
    num amount,
    String type,
  );
}
