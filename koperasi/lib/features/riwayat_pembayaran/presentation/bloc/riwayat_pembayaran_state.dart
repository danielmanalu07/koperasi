import 'package:equatable/equatable.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/riwayat_pembayaran.dart';

abstract class RiwayatPembayaranState extends Equatable {
  const RiwayatPembayaranState();

  @override
  List<Object> get props => [];
}

class RiwayatPembayaranInitial extends RiwayatPembayaranState {}

class RiwayatPembayaranLoading extends RiwayatPembayaranState {}

class RiwayatPembayaranLoaded extends RiwayatPembayaranState {
  final List<RiwayatPembayaran> riwayatPembayaran;

  const RiwayatPembayaranLoaded(this.riwayatPembayaran);

  @override
  List<Object> get props => [riwayatPembayaran];
}

class RiwayatPembayaranError extends RiwayatPembayaranState {
  final String message;

  const RiwayatPembayaranError(this.message);

  @override
  List<Object> get props => [message];
}
