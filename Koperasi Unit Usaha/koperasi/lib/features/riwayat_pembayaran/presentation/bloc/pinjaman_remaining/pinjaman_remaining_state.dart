import 'package:equatable/equatable.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/pinjaman_remaining_entity.dart';

abstract class PinjamanRemainingState extends Equatable {
  const PinjamanRemainingState();

  @override
  List<Object> get props => [];
}

class PinjamanRemainingInitial extends PinjamanRemainingState {}

class PinjamanRemainingLoading extends PinjamanRemainingState {}

class PinjamanRemainingLoaded extends PinjamanRemainingState {
  final PinjamanRemainingEntity pinjamanRemainingEntity;

  const PinjamanRemainingLoaded(this.pinjamanRemainingEntity);

  @override
  List<Object> get props => [pinjamanRemainingEntity];
}

class PinjamanRemainingError extends PinjamanRemainingState {
  final String message;

  const PinjamanRemainingError(this.message);

  @override
  List<Object> get props => [message];
}
