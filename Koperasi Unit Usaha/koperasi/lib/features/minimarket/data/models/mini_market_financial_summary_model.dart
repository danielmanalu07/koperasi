import 'package:koperasi/features/minimarket/domain/entities/mini_market_financial_summary.dart';

class MiniMarketFinancialSummaryModel extends MiniMarketFinancialSummary {
  const MiniMarketFinancialSummaryModel({
    required super.totalBalance,
    required super.totalIncome,
    required super.totalExpense,
  });

  factory MiniMarketFinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    return MiniMarketFinancialSummaryModel(
      totalBalance: (json['totalBalance'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
    );
  }

  MiniMarketFinancialSummaryModel copyWith({
    double? totalBalance,
    double? totalIncome,
    double? totalExpense,
  }) {
    return MiniMarketFinancialSummaryModel(
      totalBalance: totalBalance ?? this.totalBalance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
    );
  }
}
