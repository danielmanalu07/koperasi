import 'package:equatable/equatable.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/bayar_entity.dart';

abstract class BayarTagihanState extends Equatable {
  const BayarTagihanState();

  @override
  List<Object> get props => [];
}

class BayarTagihanInitial extends BayarTagihanState {}

class BayarTagihanCreating extends BayarTagihanState {}

class BayarTagihanCreated extends BayarTagihanState {
  final BayarEntity bayarEntity;

  const BayarTagihanCreated(this.bayarEntity);

  @override
  List<Object> get props => [bayarEntity];
}

class BayarTagihanCreateError extends BayarTagihanState {
  final String message;

  const BayarTagihanCreateError(this.message);

  @override
  List<Object> get props => [message];
}
