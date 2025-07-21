import 'package:equatable/equatable.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionEvent extends TransactionEvent {}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class SearchTransactionsEvent extends TransactionEvent {
  final String query;

  const SearchTransactionsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class FilterTransactionsByStatusEvent extends TransactionEvent {
  final String status; // 'Aktif', 'Selesai', or 'Semua'

  const FilterTransactionsByStatusEvent(this.status);

  @override
  List<Object> get props => [status];
}

class RefreshTransactionsEvent extends TransactionEvent {}
