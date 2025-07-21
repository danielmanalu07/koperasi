import 'package:koperasi/features/minimarket/domain/entities/mini_market_asset.dart';

class MiniMarketAssetModel extends MiniMarketAsset {
  const MiniMarketAssetModel({
    required super.name,
    required super.value,
    required super.purchaseDate,
  });

  factory MiniMarketAssetModel.fromJson(Map<String, dynamic> json) {
    return MiniMarketAssetModel(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    );
  }
}
