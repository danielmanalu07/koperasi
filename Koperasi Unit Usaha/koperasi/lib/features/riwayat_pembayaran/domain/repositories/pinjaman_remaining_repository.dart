import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/pinjaman_remaining_entity.dart';

abstract class PinjamanRemainingRepository {
  Future<Either<Failures, PinjamanRemainingEntity>> getPinjamanRemaining();
}
