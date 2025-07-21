import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/expense.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/expense_repository.dart';

class GetExpensesUsecase implements Usecase<List<Expense>, NoParams> {
  final ExpenseRepository repository;

  GetExpensesUsecase(this.repository);

  @override
  Future<Either<Failures, List<Expense>>> call(NoParams params) async {
    return await repository.getExpenses();
  }
}
