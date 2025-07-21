import 'package:equatable/equatable.dart';

class MiniMarketProduct extends Equatable {
  final String name;
  final double price;
  final int stock;

  const MiniMarketProduct({
    required this.name,
    required this.price,
    required this.stock,
  });

  @override
  List<Object?> get props => [name, price, stock];
}
