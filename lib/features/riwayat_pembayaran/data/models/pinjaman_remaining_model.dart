import 'package:koperasi/features/riwayat_pembayaran/domain/entities/pinjaman_remaining_entity.dart';

class PinjamanRemainingModel extends PinjamanRemainingEntity {
  const PinjamanRemainingModel({
    required super.remainingTotal,
    required super.remainingTotalThisMonth,
  });

  factory PinjamanRemainingModel.fromJson(Map<String, dynamic> json) {
    return PinjamanRemainingModel(
      remainingTotal: num.parse(json['remaining_total']),
      remainingTotalThisMonth: num.parse(json['remaining_total_this_month']),
    );
  }
}
