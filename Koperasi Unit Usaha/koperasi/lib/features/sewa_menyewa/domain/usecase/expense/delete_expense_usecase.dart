import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/expense_repository.dart';

class DeleteExpenseUsecase implements Usecase<void, DeleteExpenseParams> {
  final ExpenseRepository repository;

  DeleteExpenseUsecase(this.repository);

  @override
  Future<Either<Failures, void>> call(DeleteExpenseParams params) async {
    return await repository.deleteExpense(params.id);
  }
}

class DeleteExpenseParams extends Equatable {
  final int id;

  const DeleteExpenseParams({required this.id});

  @override
  List<Object?> get props => [id];
}
