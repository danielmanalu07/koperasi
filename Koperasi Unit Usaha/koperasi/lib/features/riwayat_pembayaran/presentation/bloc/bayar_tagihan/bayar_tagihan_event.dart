import 'package:equatable/equatable.dart';

abstract class BayarTagihanEvent extends Equatable {
  const BayarTagihanEvent();

  @override
  List<Object> get props => [];
}

class CreateBayarTagihanEvent extends BayarTagihanEvent {
  final int pinjamanDetail;
  final num amount;
  final String type;
  final String? image;

  const CreateBayarTagihanEvent({
    required this.pinjamanDetail,
    required this.amount,
    required this.type,
    this.image,
  });

  @override
  List<Object> get props => [pinjamanDetail, amount, type, image!];
}
