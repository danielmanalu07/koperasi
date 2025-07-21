import 'package:equatable/equatable.dart';

class MiniMarketProcurement extends Equatable {
  final String item;
  final int quantity;
  final double cost;
  final DateTime date;

  const MiniMarketProcurement({
    required this.item,
    required this.quantity,
    required this.cost,
    required this.date,
  });

  @override
  List<Object?> get props => [item, quantity, cost, date];
}
