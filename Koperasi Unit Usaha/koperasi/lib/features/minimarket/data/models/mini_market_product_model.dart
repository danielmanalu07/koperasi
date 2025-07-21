import 'package:koperasi/features/minimarket/domain/entities/mini_market_product.dart';

class MiniMarketProductModel extends MiniMarketProduct {
  const MiniMarketProductModel({
    required super.name,
    required super.price,
    required super.stock,
  });

  factory MiniMarketProductModel.fromJson(Map<String, dynamic> json) {
    return MiniMarketProductModel(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
    );
  }

  MiniMarketProductModel copyWith({String? name, double? price, int? stock}) {
    return MiniMarketProductModel(
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }
}
