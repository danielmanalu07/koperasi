import 'package:koperasi/features/riwayat_pembayaran/domain/entities/pinjaman_remaining_entity.dart';

class PinjamanRemainingModel extends PinjamanRemainingEntity {
  const PinjamanRemainingModel({
    required super.remainingTotal,
    required super.remainingTotalThisMonth,
    super.activeThisMonthEntity,
  });

  factory PinjamanRemainingModel.fromJson(Map<String, dynamic> json) {
    final num parsedRemainingTotal = json['remaining_total'] is String
        ? (double.tryParse(json['remaining_total']) ?? 0.0)
        : (json['remaining_total'] ?? 0.0);
    final num parsedRemainingTotalThisMonth =
        json['remaining_total_this_month'] is String
        ? (double.tryParse(json['remaining_total_this_month']) ?? 0.0)
        : (json['remaining_total_this_month'] ?? 0.0);
    return PinjamanRemainingModel(
      remainingTotal: parsedRemainingTotal,
      remainingTotalThisMonth: parsedRemainingTotalThisMonth,
      activeThisMonthEntity: json['active_this_month'] != null
          ? ActiveThisMonthModel.fromJson(
              json['active_this_month'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class ActiveThisMonthModel extends ActiveThisMonthEntity {
  const ActiveThisMonthModel({
    required super.id,
    required super.pinjamanId,
    required super.month,
    required super.paid,
    required super.remaining,
    required super.dueDate,
    required super.paidAt,
    required super.description,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ActiveThisMonthModel.fromJson(Map<String, dynamic> json) {
    return ActiveThisMonthModel(
      id: json['id'],
      pinjamanId: json['pinjaman_id'],
      month: json['month'],
      paid: json['paid'],
      remaining: json['remaining'],
      dueDate: DateTime.parse(json['due_date']),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      description: json['description'] != null
          ? json['description'] as String
          : null,
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
