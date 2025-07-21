import 'package:equatable/equatable.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/expense.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;

  const ExpenseLoaded({required this.expenses});

  @override
  List<Object> get props => [expenses];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object> get props => [message];
}

// States for Add, Update, Delete operations
class ExpenseActionLoading extends ExpenseState {}

class ExpenseActionSuccess extends ExpenseState {
  final String message;

  const ExpenseActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ExpenseActionError extends ExpenseState {
  final String message;

  const ExpenseActionError(this.message);

  @override
  List<Object> get props => [message];
}
