import 'package:equatable/equatable.dart';

class Asset extends Equatable {
  final int id;
  final String name;
  final DateTime purchaseDate;
  final int price;
  final String description;
  final String status;

  const Asset({
    required this.id,
    required this.name,
    required this.purchaseDate,
    required this.price,
    required this.description,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    purchaseDate,
    price,
    description,
    status,
  ];
}
