import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/riwayat_pembayaran.dart';

abstract class RiwayatPembayaranRepository {
  Future<Either<Failures, List<RiwayatPembayaran>>> getRiwayatPembayaran();
}
