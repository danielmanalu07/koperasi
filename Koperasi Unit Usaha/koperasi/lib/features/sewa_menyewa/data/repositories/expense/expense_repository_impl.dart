import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/exceptions.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/features/sewa_menyewa/data/datasources/expense_remote_data_source.dart';
import 'package:koperasi/features/sewa_menyewa/data/model/expense/expense_model.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/expense.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ExpenseRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, List<Expense>>> getExpenses() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getExpenses();
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException {
        return const Left(NetworkFailure('Tidak ada koneksi internet.'));
      } catch (e) {
        return Left(
          ServerFailure('Terjadi kesalahan tidak terduga: ${e.toString()}'),
        );
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, Expense>> addExpense(Expense expense) async {
    if (await networkInfo.isConnected) {
      try {
        final expenseModel = ExpenseModel(
          id: expense.id, // ID might be 0 for new, backend will assign
          date: expense.date,
          category: expense.category,
          amount: expense.amount,
          description: expense.description,
        );
        final result = await remoteDataSource.addExpense(expenseModel);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException {
        return const Left(NetworkFailure('Tidak ada koneksi internet.'));
      } catch (e) {
        return Left(
          ServerFailure('Terjadi kesalahan tidak terduga: ${e.toString()}'),
        );
      }
    } else {
      return const Left(NetworkFailure("No Internet Connection"));
    }
  }

  @override
  Future<Either<Failures, Expense>> updateExpense(Expense expense) async {
    if (await networkInfo.isConnected) {
      try {
        final expenseModel = ExpenseModel(
          id: expense.id,
          date: expense.date,
          category: expense.category,
          amount: expense.amount,
          description: expense.description,
        );
        final result = await remoteDataSource.updateExpense(expenseModel);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException {
        return const Left(NetworkFailure('Tidak ada koneksi internet.'));
      } catch (e) {
        return Left(
          ServerFailure('Terjadi kesalahan tidak terduga: ${e.toString()}'),
        );
      }
    } else {
      return const Left(NetworkFailure("No Internet Connection"));
    }
  }

  @override
  Future<Either<Failures, void>> deleteExpense(int id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteExpense(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException {
        return const Left(NetworkFailure('Tidak ada koneksi internet.'));
      } catch (e) {
        return Left(
          ServerFailure('Terjadi kesalahan tidak terduga: ${e.toString()}'),
        );
      }
    } else {
      return const Left(NetworkFailure("No Internet Connection"));
    }
  }
}
