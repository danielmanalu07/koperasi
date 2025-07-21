import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koperasi/core/errors/map_failure_toMessage.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/transaction.dart'; // Import Transaction entity
import 'package:koperasi/features/sewa_menyewa/domain/usecase/Transaction/add_transaction_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/Transaction/get_transaction_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Transaction/transaction_event.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Transaction/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionUsecase getTransactionUsecase;
  final AddTransactionUsecase addTransactionUsecase;

  List<Transaction> _allTransactions = []; // Holds the full, unfiltered list
  String _currentSearchQuery = '';
  String _currentFilterStatus = 'Semua'; // Default filter status

  TransactionBloc({
    required this.getTransactionUsecase,
    required this.addTransactionUsecase,
  }) : super(TransactionInitial()) {
    on<LoadTransactionEvent>(_onLoadTransaction);
    on<AddTransactionEvent>(_onAddTransaction);
    on<SearchTransactionsEvent>(_onSearchTransactions);
    on<FilterTransactionsByStatusEvent>(_onFilterTransactionsByStatus);
    on<RefreshTransactionsEvent>(_onRefreshTransactions); // New event handler
  }

  // Handles loading all transactions and then applies current filters/search
  Future<void> _onLoadTransaction(
    LoadTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final failureOrTransactions = await getTransactionUsecase(NoParams());
    failureOrTransactions.fold(
      (failure) => emit(TransactionError(MapFailureToMessage.map(failure))),
      (transactions) {
        _allTransactions = transactions; // Store the full list
        _applyFiltersAndSearch(emit); // Apply current filters/search to display
      },
    );
  }

  // Handles adding a new transaction
  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionCreating());
    final failureOrCreate = await addTransactionUsecase(
      CreateTransactionParams(transaction: event.transaction),
    );
    failureOrCreate.fold(
      (failure) =>
          emit(TransactionCreateError(MapFailureToMessage.map(failure))),
      (created) {
        // Assuming 'created' implies success and the transaction was added to the backend.
        // To reflect this in the UI, we should either:
        // 1. Re-fetch all transactions (simple but might be inefficient for large datasets)
        // 2. Add the new transaction to _allTransactions directly (if backend confirms success and gives an ID)
        // For simplicity, let's assume we re-load.
        // If 'created' contains the full new transaction object with ID, you can do:
        // _allTransactions.add(event.transaction.copyWith(id: created.id)); // Assuming 'created' has an 'id'
        // For now, we'll re-trigger the load to get the updated list from source.
        add(LoadTransactionEvent()); // Re-load to get updated list
        emit(TransactionCreated(event.transaction)); // Emit success for the UI
      },
    );
  }

  // Handles search query changes
  void _onSearchTransactions(
    SearchTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) {
    _currentSearchQuery = event.query
        .toLowerCase(); // Store lowercase query for case-insensitive search
    _applyFiltersAndSearch(emit); // Re-apply filters with new search query
  }

  // Handles status filter changes
  void _onFilterTransactionsByStatus(
    FilterTransactionsByStatusEvent event,
    Emitter<TransactionState> emit,
  ) {
    _currentFilterStatus = event.status; // Store the new filter status
    _applyFiltersAndSearch(emit); // Re-apply filters with new status
  }

  // Handles refresh event, re-loading transactions from source
  Future<void> _onRefreshTransactions(
    RefreshTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    // This will trigger _onLoadTransaction which re-fetches and applies filters
    add(LoadTransactionEvent());
  }

  // Applies current search and status filters to _allTransactions
  void _applyFiltersAndSearch(Emitter<TransactionState> emit) {
    List<Transaction> filteredTransactions = _allTransactions.where((
      transaction,
    ) {
      // Search filter
      final matchesSearchQuery =
          _currentSearchQuery.isEmpty ||
          transaction.customerName.toLowerCase().contains(
            _currentSearchQuery,
          ) ||
          transaction.assetName.toLowerCase().contains(_currentSearchQuery);

      // Status filter
      final matchesStatusFilter =
          _currentFilterStatus == 'Semua' ||
          transaction.status == _currentFilterStatus;

      return matchesSearchQuery && matchesStatusFilter;
    }).toList();

    // Emit the new state with filtered transactions and current filter/search parameters
    emit(
      TransactionLoaded(
        transactions: filteredTransactions,
        currentSearchQuery: _currentSearchQuery,
        currentFilterStatus: _currentFilterStatus,
      ),
    );
  }
}
