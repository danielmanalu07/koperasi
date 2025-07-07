import 'package:equatable/equatable.dart';

abstract class RiwayatPembayaranEvent extends Equatable {
  const RiwayatPembayaranEvent();

  @override
  List<Object> get props => [];
}

class GetRiwayatPembayaranEvent extends RiwayatPembayaranEvent {
  final int pinjamanDetail;

  const GetRiwayatPembayaranEvent({required this.pinjamanDetail});

  @override
  List<Object> get props => [pinjamanDetail];
}
