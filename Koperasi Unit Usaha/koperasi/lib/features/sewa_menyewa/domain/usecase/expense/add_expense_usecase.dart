import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/expense.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/expense_repository.dart';

class AddExpenseUsecase implements Usecase<Expense, AddExpenseParams> {
  final ExpenseRepository repository;

  AddExpenseUsecase(this.repository);

  @override
  Future<Either<Failures, Expense>> call(AddExpenseParams params) async {
    return await repository.addExpense(params.expense);
  }
}

class AddExpenseParams extends Equatable {
  final Expense expense;

  const AddExpenseParams({required this.expense});

  @override
  List<Object?> get props => [expense];
}
