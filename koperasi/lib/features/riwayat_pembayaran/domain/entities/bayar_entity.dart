import 'package:equatable/equatable.dart';

class BayarEntity extends Equatable {
  final int id;
  final num amount;
  final String type;
  final String? image;
  final TransactionEntity? transactionEntity;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Add these two fields as they are always in the 'data' object
  final int pinjamanId;
  final int pinjamanDetailId;

  const BayarEntity({
    required this.id,
    required this.amount,
    required this.type,
    this.image,
    this.transactionEntity,
    required this.createdAt,
    required this.updatedAt,
    // Make them required in the constructor as per JSON response
    required this.pinjamanId,
    required this.pinjamanDetailId,
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    type,
    image,
    transactionEntity,
    createdAt,
    updatedAt,
    pinjamanId,
    pinjamanDetailId,
  ];
}

class TransactionEntity extends Equatable {
  final int id;
  final int userId;
  final num amount;
  final String orderId;
  final DateTime expiresAt;
  final DateTime updatedAt;
  final DateTime createdAt;
  final String? paymentLink; // Make this nullable

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.orderId,
    required this.expiresAt,
    required this.updatedAt,
    required this.createdAt,
    this.paymentLink, // No longer required in constructor
  });
  @override
  List<Object?> get props => [
    id,
    userId,
    amount,
    orderId,
    expiresAt,
    updatedAt,
    createdAt,
    paymentLink,
  ];
}
