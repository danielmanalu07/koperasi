import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koperasi/core/errors/map_failure_toMessage.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/expense/add_expense_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/expense/delete_expense_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/expense/get_expenses_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/expense/update_expense_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/expense/expense_event.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/expense/expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesUsecase getExpensesUsecase;
  final AddExpenseUsecase addExpenseUsecase;
  final UpdateExpenseUsecase updateExpenseUsecase;
  final DeleteExpenseUsecase deleteExpenseUsecase;

  ExpenseBloc({
    required this.getExpensesUsecase,
    required this.addExpenseUsecase,
    required this.updateExpenseUsecase,
    required this.deleteExpenseUsecase,
  }) : super(ExpenseInitial()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final failureOrExpenses = await getExpensesUsecase(NoParams());
    failureOrExpenses.fold(
      (failure) => emit(ExpenseError(MapFailureToMessage.map(failure))),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseActionLoading());
    final failureOrExpense = await addExpenseUsecase(
      AddExpenseParams(expense: event.expense),
    );
    failureOrExpense.fold(
      (failure) => emit(ExpenseActionError(MapFailureToMessage.map(failure))),
      (expense) {
        emit(const ExpenseActionSuccess('Pengeluaran berhasil ditambahkan!'));
        add(LoadExpensesEvent()); // Refresh list after adding
      },
    );
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseActionLoading());
    final failureOrExpense = await updateExpenseUsecase(
      UpdateExpenseParams(expense: event.expense),
    );
    failureOrExpense.fold(
      (failure) => emit(ExpenseActionError(MapFailureToMessage.map(failure))),
      (expense) {
        emit(const ExpenseActionSuccess('Pengeluaran berhasil diperbarui!'));
        add(LoadExpensesEvent()); // Refresh list after updating
      },
    );
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseActionLoading());
    final failureOrVoid = await deleteExpenseUsecase(
      DeleteExpenseParams(id: event.id),
    );
    failureOrVoid.fold(
      (failure) => emit(ExpenseActionError(MapFailureToMessage.map(failure))),
      (_) {
        emit(const ExpenseActionSuccess('Pengeluaran berhasil dihapus!'));
        add(LoadExpensesEvent());
      },
    );
  }
}
