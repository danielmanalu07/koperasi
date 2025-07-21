import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koperasi/core/errors/map_failure_toMessage.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/usecases/get_pinjaman_remaining_usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/pinjaman_remaining/pinjaman_remaining_event.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/pinjaman_remaining/pinjaman_remaining_state.dart';

class PinjamanRemainingBloc
    extends Bloc<PinjamanRemainingEvent, PinjamanRemainingState> {
  final GetPinjamanRemainingUsecase getPinjamanRemainingUsecase;

  PinjamanRemainingBloc({required this.getPinjamanRemainingUsecase})
    : super(PinjamanRemainingInitial()) {
    on<GetPinjamanRemainingEvent>(_onGetPinjamanRemaining);
  }

  Future<void> _onGetPinjamanRemaining(
    GetPinjamanRemainingEvent event,
    Emitter<PinjamanRemainingState> emit,
  ) async {
    emit(PinjamanRemainingLoading());
    final pinjamanRemaining = await getPinjamanRemainingUsecase(NoParams());
    pinjamanRemaining.fold(
      (failure) =>
          emit(PinjamanRemainingError(MapFailureToMessage.map(failure))),
      (pinjamanRemaining) => emit(PinjamanRemainingLoaded(pinjamanRemaining)),
    );
  }
}
