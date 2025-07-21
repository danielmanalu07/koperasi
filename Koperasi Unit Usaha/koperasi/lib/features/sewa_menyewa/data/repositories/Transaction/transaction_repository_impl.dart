import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/features/sewa_menyewa/data/dataSources/transaction_remote_dataSource.dart';
import 'package:koperasi/features/sewa_menyewa/data/model/Transaction/transaction_model.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/transaction.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDatasource transactionRemoteDatasource;
  final NetworkInfo networkInfo;

  TransactionRepositoryImpl({
    required this.transactionRemoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, Transaction>> createTransaction(
    Transaction transaction,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final transactionModel = TransactionModel.fromEntity(transaction);
        final createdTransaction = await transactionRemoteDatasource
            .createTransaction(transactionModel);
        return Right(createdTransaction);
      } catch (e) {
        throw Left(e.toString());
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, List<Transaction>>> getTransactions() async {
    if (await networkInfo.isConnected) {
      try {
        final transactions = await transactionRemoteDatasource
            .getTransactions();
        return Right(transactions);
      } catch (e) {
        throw Left(e.toString());
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
