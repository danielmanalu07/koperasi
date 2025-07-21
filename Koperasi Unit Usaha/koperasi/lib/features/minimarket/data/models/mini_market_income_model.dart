import 'package:koperasi/features/minimarket/domain/entities/mini_market_income.dart';

class MiniMarketIncomeModel extends MiniMarketIncome {
  const MiniMarketIncomeModel({
    required super.category,
    required super.amount,
    required super.description,
  });

  factory MiniMarketIncomeModel.fromJson(Map<String, dynamic> json) {
    return MiniMarketIncomeModel(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
    );
  }
}
