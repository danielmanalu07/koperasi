import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failures, List<Transaction>>> getTransactions();
  Future<Either<Failures, Transaction>> createTransaction(
    Transaction transaction,
  );
}
