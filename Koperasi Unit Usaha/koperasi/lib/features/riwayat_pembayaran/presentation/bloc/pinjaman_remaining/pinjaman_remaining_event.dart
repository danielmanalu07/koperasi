import 'package:equatable/equatable.dart';

abstract class PinjamanRemainingEvent extends Equatable {
  const PinjamanRemainingEvent();

  @override
  List<Object> get props => [];
}

class GetPinjamanRemainingEvent extends PinjamanRemainingEvent {}
