import 'package:koperasi/features/minimarket/domain/entities/mini_market_pos_transaction.dart';

class MiniMarketPosTransactionModel extends MiniMarketPosTransaction {
  const MiniMarketPosTransactionModel({
    required super.id,
    required super.total,
    required super.date,
    required super.items,
  });

  factory MiniMarketPosTransactionModel.fromJson(Map<String, dynamic> json) {
    return MiniMarketPosTransactionModel(
      id: json['id'] as String,
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      items: json['items'] as List<dynamic>,
    );
  }
}
