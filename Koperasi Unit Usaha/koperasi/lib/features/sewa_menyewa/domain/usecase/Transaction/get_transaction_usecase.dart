import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/transaction.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/transaction_repository.dart';

class GetTransactionUsecase implements Usecase<List<Transaction>, NoParams> {
  final TransactionRepository transactionRepository;

  GetTransactionUsecase(this.transactionRepository);

  @override
  Future<Either<Failures, List<Transaction>>> call(NoParams params) async {
    return await transactionRepository.getTransactions();
  }
}
