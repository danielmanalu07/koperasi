import 'package:koperasi/features/riwayat_pembayaran/domain/entities/pinjaman_remaining_entity.dart';

class PinjamanRemainingModel extends PinjamanRemainingEntity {
  const PinjamanRemainingModel({
    required super.remainingTotal,
    required super.remainingTotalThisMonth,
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
    );
  }
}
