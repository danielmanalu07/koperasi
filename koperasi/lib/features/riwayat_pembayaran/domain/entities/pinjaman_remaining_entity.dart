import 'package:equatable/equatable.dart';

class PinjamanRemainingEntity extends Equatable {
  final num remainingTotal;
  final num remainingTotalThisMonth;
  final ActiveThisMonthEntity? activeThisMonthEntity;

  const PinjamanRemainingEntity({
    required this.remainingTotal,
    required this.remainingTotalThisMonth,
    this.activeThisMonthEntity,
  });

  @override
  List<Object?> get props => [remainingTotal, remainingTotalThisMonth];
}

class ActiveThisMonthEntity extends Equatable {
  final int id;
  final int pinjamanId;
  final int month;
  final num paid;
  final num remaining;
  final DateTime dueDate;
  final DateTime? paidAt;
  final String? description;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ActiveThisMonthEntity({
    required this.id,
    required this.pinjamanId,
    required this.month,
    required this.paid,
    required this.remaining,
    required this.dueDate,
    this.paidAt,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    pinjamanId,
    month,
    paid,
    remaining,
    dueDate,
    paidAt,
    description,
    status,
    createdAt,
    updatedAt,
  ];
}
