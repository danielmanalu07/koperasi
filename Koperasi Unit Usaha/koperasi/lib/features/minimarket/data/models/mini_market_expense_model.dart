import 'package:koperasi/features/minimarket/domain/entities/mini_market_expense.dart';

class MiniMarketExpenseModel extends MiniMarketExpense {
  const MiniMarketExpenseModel({
    required super.category,
    required super.amount,
    required super.description,
  });

  factory MiniMarketExpenseModel.fromJson(Map<String, dynamic> json) {
    return MiniMarketExpenseModel(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
    );
  }
}
