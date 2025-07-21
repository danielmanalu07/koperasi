import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koperasi/core/errors/map_failure_toMessage.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/usecases/create_bayar_tagihan_usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/bayar_tagihan/bayar_tagihan_event.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/bayar_tagihan/bayar_tagihan_state.dart';

class BayarTagihanBloc extends Bloc<BayarTagihanEvent, BayarTagihanState> {
  final CreateBayarTagihanUsecase createBayarTagihanUsecase;

  BayarTagihanBloc({required this.createBayarTagihanUsecase})
    : super(BayarTagihanInitial()) {
    on<CreateBayarTagihanEvent>(_onCreateBayarTagihan);
  }

  Future<void> _onCreateBayarTagihan(
    CreateBayarTagihanEvent event,
    Emitter<BayarTagihanState> emit,
  ) async {
    emit(BayarTagihanCreating());
    final bayarTagihan = await createBayarTagihanUsecase(
      CreateBayarTagihanParams(
        pinjamanDetail: event.pinjamanDetail,
        amount: event.amount,
        type: event.type,
        image: event.image,
      ),
    );

    bayarTagihan.fold(
      (failure) =>
          emit(BayarTagihanCreateError(MapFailureToMessage.map(failure))),
      (bayar) => emit(BayarTagihanCreated(bayar)),
    );
  }
}
