import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failures, List<Expense>>> getExpenses();
  Future<Either<Failures, Expense>> addExpense(Expense expense);
  Future<Either<Failures, Expense>> updateExpense(Expense expense);
  Future<Either<Failures, void>> deleteExpense(int id);
}
