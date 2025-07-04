import 'package:koperasi/features/riwayat_pembayaran/domain/entities/riwayat_pembayaran.dart';

class RiwayatPembayaranModel extends RiwayatPembayaran {
  const RiwayatPembayaranModel({
    required super.id,
    required super.pinjamanId,
    required super.pinjamanDetailId,
    required super.amount,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.type,
    required super.pinjamanDetailStatus,
    required super.anggotaName,
    super.transaction,
  });

  factory RiwayatPembayaranModel.fromJson(Map<String, dynamic> json) {
    return RiwayatPembayaranModel(
      id: json['id'] as int,
      pinjamanId: json['pinjaman_id'] as int,
      pinjamanDetailId: json['pinjaman_detail_id'] as int,
      amount: json['amount'] as num, // Amount here is num, not string
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      type: json['type'] as String,
      pinjamanDetailStatus: json['pinjaman_detail_status'] as int,
      anggotaName: json['anggota_name'] as String,
      transaction: json['transaction'] != null
          ? TransactionHistoryModel.fromJson(
              json['transaction'] as Map<String, dynamic>,
            )
          : null, // Parse transaction here
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'pinjaman_id': pinjamanId,
      'pinjaman_detail_id': pinjamanDetailId,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'type': type,
      'pinjaman_detail_status': pinjamanDetailStatus,
      'anggota_name': anggotaName,
    };
    if (transaction != null) {
      data['transaction'] = (transaction as TransactionHistoryModel).toJson();
    }
    return data;
  }
}

class TransactionHistoryModel extends TransactionHistoryEntity {
  const TransactionHistoryModel({
    required super.id,
    required super.userId,
    super.reference,
    super.refNumber,
    required super.modelType,
    required super.modelId,
    required super.amount,
    required super.orderId,
    super.paymentLink,
    required super.expiresAt,
    super.paidAt,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      reference: json['reference'] as String?,
      refNumber: json['ref_number'] as String?,
      modelType: json['model_type'] as String,
      modelId: json['model_id'] as int,
      amount: json['amount'] as num,
      orderId: json['order_id'] as String,
      paymentLink: json['payment_link'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reference': reference,
      'ref_number': refNumber,
      'model_type': modelType,
      'model_id': modelId,
      'amount': amount,
      'order_id': orderId,
      'payment_link': paymentLink,
      'expires_at': expiresAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
