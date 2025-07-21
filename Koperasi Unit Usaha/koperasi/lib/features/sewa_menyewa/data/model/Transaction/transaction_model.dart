import 'package:intl/intl.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.customerName,
    required super.assetName,
    required super.description,
    required super.date,
    required super.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json["id"] as int? ?? 0, // Default ke 0 jika null, sesuaikan logika
      customerName: (json["customer_name"] as String?) ?? '',
      assetName: (json["asset_name"] as String?) ?? '',
      description: (json["description"] as String?) ?? '',
      date: json["date"] != null
          ? DateTime.parse(json["date"] as String)
          : DateTime.now(),
      status: (json["status"] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "customer_name": customerName,
      "asset_name": assetName,
      "description": description,
      "date": DateFormat('yyyy-MM-dd').format(date),
      "status": status,
    };
  }

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      customerName: entity.customerName,
      assetName: entity.assetName,
      description: entity.description,
      date: entity.date,
      status: entity.status,
    );
  }
}
