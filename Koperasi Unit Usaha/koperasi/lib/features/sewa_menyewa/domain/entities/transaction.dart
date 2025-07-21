import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int id;
  final String customerName;
  final String assetName;
  final String description;
  final DateTime date;
  final String status;

  const Transaction({
    required this.id,
    required this.customerName,
    required this.assetName,
    required this.description,
    required this.date,
    required this.status,
  });

  @override
  List<Object?> get props => [];
}
