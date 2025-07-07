import 'package:equatable/equatable.dart';

class PinjamanRemainingEntity extends Equatable {
  final num remainingTotal;
  final num remainingTotalThisMonth;

  const PinjamanRemainingEntity({
    required this.remainingTotal,
    required this.remainingTotalThisMonth,
  });

  @override
  List<Object?> get props => [remainingTotal, remainingTotalThisMonth];
}
