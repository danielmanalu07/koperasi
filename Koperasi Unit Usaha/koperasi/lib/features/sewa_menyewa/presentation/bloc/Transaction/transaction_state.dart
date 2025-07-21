import 'package:equatable/equatable.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final String currentSearchQuery; // Added
  final String currentFilterStatus; // Added

  const TransactionLoaded({
    required this.transactions,
    this.currentSearchQuery = '',
    this.currentFilterStatus = 'Semua',
  });

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    String? currentSearchQuery,
    String? currentFilterStatus,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      currentFilterStatus: currentFilterStatus ?? this.currentFilterStatus,
    );
  }

  @override
  List<Object> get props => [
    transactions,
    currentSearchQuery,
    currentFilterStatus,
  ];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}

class TransactionCreating extends TransactionState {}

class TransactionCreated extends TransactionState {
  final Transaction transaction;

  const TransactionCreated(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class TransactionCreateError extends TransactionState {
  final String message;

  const TransactionCreateError(this.message);

  @override
  List<Object> get props => [message];
}
