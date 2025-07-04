import 'package:equatable/equatable.dart';

class RiwayatPembayaran extends Equatable {
  final int id;
  final int pinjamanId;
  final int pinjamanDetailId;
  final num amount;
  final int status; // This 'status' is for the payment record itself
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type;
  final int pinjamanDetailStatus;
  final String anggotaName;
  final TransactionHistoryEntity? transaction; // Make this nullable

  const RiwayatPembayaran({
    required this.id,
    required this.pinjamanId,
    required this.pinjamanDetailId,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.pinjamanDetailStatus,
    required this.anggotaName,
    this.transaction, // Make it optional in constructor
  });

  @override
  List<Object?> get props => [
    id,
    pinjamanId,
    pinjamanDetailId,
    amount,
    status,
    createdAt,
    updatedAt,
    type,
    pinjamanDetailStatus,
    anggotaName,
    transaction,
  ];
}

class TransactionHistoryEntity extends Equatable {
  final int id;
  final int userId;
  final String? reference; // New field
  final String? refNumber; // New field
  final String modelType;
  final int modelId;
  final num amount;
  final String orderId;
  final String? paymentLink; // Can be null
  final DateTime expiresAt;
  final DateTime? paidAt; // Can be null
  final int status; // New field (status for the transaction itself)
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionHistoryEntity({
    required this.id,
    required this.userId,
    this.reference,
    this.refNumber,
    required this.modelType,
    required this.modelId,
    required this.amount,
    required this.orderId,
    this.paymentLink,
    required this.expiresAt,
    this.paidAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    reference,
    refNumber,
    modelType,
    modelId,
    amount,
    orderId,
    paymentLink,
    expiresAt,
    paidAt,
    status,
    createdAt,
    updatedAt,
  ];
}
