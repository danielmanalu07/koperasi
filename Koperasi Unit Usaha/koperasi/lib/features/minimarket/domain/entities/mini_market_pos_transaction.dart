import 'package:equatable/equatable.dart';

class MiniMarketPosTransaction extends Equatable {
  final String id;
  final double total;
  final DateTime date;
  final List<dynamic> items;

  const MiniMarketPosTransaction({
    required this.id,
    required this.total,
    required this.date,
    required this.items,
  });

  @override
  List<Object?> get props => [id, total, date, items];
}
