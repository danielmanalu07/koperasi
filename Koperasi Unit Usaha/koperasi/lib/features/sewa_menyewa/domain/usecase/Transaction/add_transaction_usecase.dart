import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/transaction.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/transaction_repository.dart';

class AddTransactionUsecase
    implements Usecase<Transaction, CreateTransactionParams> {
  final TransactionRepository transactionRepository;

  AddTransactionUsecase(this.transactionRepository);

  @override
  Future<Either<Failures, Transaction>> call(
    CreateTransactionParams params,
  ) async {
    return await transactionRepository.createTransaction(params.transaction);
  }
}

class CreateTransactionParams extends Equatable {
  final Transaction transaction;

  const CreateTransactionParams({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}
