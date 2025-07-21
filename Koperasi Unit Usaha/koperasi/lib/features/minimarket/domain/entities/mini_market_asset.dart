import 'package:equatable/equatable.dart';

class MiniMarketAsset extends Equatable {
  final String name;
  final double value;
  final DateTime purchaseDate;

  const MiniMarketAsset({
    required this.name,
    required this.value,
    required this.purchaseDate,
  });

  @override
  List<Object?> get props => [name, value, purchaseDate];
}
