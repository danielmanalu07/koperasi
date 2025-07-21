import 'package:koperasi/features/riwayat_pembayaran/domain/entities/bayar_entity.dart';

// features/riwayat_pembayaran/data/models/bayar_model.dart

class BayarModel extends BayarEntity {
  const BayarModel({
    required super.id,
    required super.amount, // This now comes from a String, needs parsing
    required super.type,
    super.image,
    super.transactionEntity,
    required super.createdAt,
    required super.updatedAt,
    required super.pinjamanId,
    required super.pinjamanDetailId,
  });

  factory BayarModel.fromJson(Map<String, dynamic> json) {
    // Parse 'amount' from String to num
    final num parsedAmount = num.parse(json['amount'] as String);

    return BayarModel(
      id: json['id'] as int,
      amount: parsedAmount, // Use the parsed num
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      pinjamanId: json['pinjaman_id'] as int,
      pinjamanDetailId: json['pinjaman_detail_id'] as int,
      image: json['image'] as String?,
      transactionEntity: json['transaction'] != null
          ? TransactionModel.fromJson(
              json['transaction'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'amount': amount.toString(), // Convert back to String for consistency
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pinjaman_id': pinjamanId,
      'pinjaman_detail_id': pinjamanDetailId,
    };
    if (image != null) {
      data['image'] = image;
    }
    if (transactionEntity != null) {
      data['transaction'] = (transactionEntity as TransactionModel).toJson();
    }
    return data;
  }
}

// features/riwayat_pembayaran/data/models/transaction_model.dart

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.amount, // This now comes from a String, needs parsing
    required super.orderId,
    required super.expiresAt,
    required super.updatedAt,
    required super.createdAt,
    super.paymentLink,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Parse 'amount' from String to num
    final num parsedAmount = num.parse(json['amount'] as String);
    final String? parsedPaymentLink = json['payment_link'] as String?;

    return TransactionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      amount: parsedAmount, // Use the parsed num
      orderId: json['order_id'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      paymentLink: parsedPaymentLink,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'amount': amount.toString(), // Convert back to String for consistency
      'order_id': orderId,
      'expires_at': expiresAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
    if (paymentLink != null) {
      data['payment_link'] = paymentLink;
    }
    return data;
  }
}
