import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/expense.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/expense_repository.dart';

class UpdateExpenseUsecase implements Usecase<Expense, UpdateExpenseParams> {
  final ExpenseRepository repository;

  UpdateExpenseUsecase(this.repository);

  @override
  Future<Either<Failures, Expense>> call(UpdateExpenseParams params) async {
    return await repository.updateExpense(params.expense);
  }
}

class UpdateExpenseParams extends Equatable {
  final Expense expense;

  const UpdateExpenseParams({required this.expense});

  @override
  List<Object?> get props => [expense];
}
