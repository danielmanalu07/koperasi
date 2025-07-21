import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final int id;
  final DateTime date;
  final String category;
  final int amount;
  final String description;

  const Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.description,
  });

  @override
  List<Object?> get props => [id, date, category, amount, description];

  Expense copyWith({
    int? id,
    DateTime? date,
    String? category,
    int? amount,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      date: date ?? this.date,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
    );
  }
}
