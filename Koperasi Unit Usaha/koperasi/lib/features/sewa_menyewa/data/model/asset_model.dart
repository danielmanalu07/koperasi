import 'package:koperasi/features/sewa_menyewa/domain/entities/asset.dart';

class AssetModel extends Asset {
  const AssetModel({
    required super.id,
    required super.name,
    required super.purchaseDate,
    required super.price,
    required super.description,
    required super.status,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'],
      name: json['nama'],
      purchaseDate: DateTime.parse(json['tanggal_beli'] as String),
      price: json['harga_beli'],
      description: json['keterangan'],
      status: json['status'],
    );
  }
}
