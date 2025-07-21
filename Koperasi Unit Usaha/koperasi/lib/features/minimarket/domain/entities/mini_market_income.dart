import 'package:equatable/equatable.dart';

class MiniMarketIncome extends Equatable {
  final String category;
  final double amount;
  final String description;

  const MiniMarketIncome({
    required this.category,
    required this.amount,
    required this.description,
  });

  @override
  List<Object?> get props => [category, amount, description];
}
