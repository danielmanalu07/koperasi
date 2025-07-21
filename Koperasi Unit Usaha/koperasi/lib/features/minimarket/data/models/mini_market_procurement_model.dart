import 'package:koperasi/features/minimarket/domain/entities/mini_market_procurement.dart';

class MiniMarketProcurementModel extends MiniMarketProcurement {
  const MiniMarketProcurementModel({
    required super.item,
    required super.quantity,
    required super.cost,
    required super.date,
  });

  factory MiniMarketProcurementModel.fromJson(Map<String, dynamic> json) {
    return MiniMarketProcurementModel(
      item: json['item'] as String,
      quantity: json['quantity'] as int,
      cost: (json['cost'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
