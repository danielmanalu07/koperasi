import 'package:equatable/equatable.dart';

class MiniMarketFinancialSummary extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  const MiniMarketFinancialSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  List<Object?> get props => [totalBalance, totalIncome, totalExpense];
}
