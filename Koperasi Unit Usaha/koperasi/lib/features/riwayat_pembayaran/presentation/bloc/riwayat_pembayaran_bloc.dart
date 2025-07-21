import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koperasi/core/errors/map_failure_toMessage.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/usecases/get_riwayat_pembayaran_usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/riwayat_pembayaran_event.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/riwayat_pembayaran_state.dart';

class RiwayatPembayaranBloc
    extends Bloc<RiwayatPembayaranEvent, RiwayatPembayaranState> {
  final GetRiwayatPembayaranUsecase getRiwayatPembayaranUsecase;

  RiwayatPembayaranBloc({required this.getRiwayatPembayaranUsecase})
    : super(RiwayatPembayaranInitial()) {
    on<GetRiwayatPembayaranEvent>(_onGetRiwayatPembayaran);
  }

  Future<void> _onGetRiwayatPembayaran(
    GetRiwayatPembayaranEvent event,
    Emitter<RiwayatPembayaranState> emit,
  ) async {
    emit(RiwayatPembayaranLoading());
    final riwayatPembayaran = await getRiwayatPembayaranUsecase(NoParams());
    riwayatPembayaran.fold(
      (failure) =>
          emit(RiwayatPembayaranError(MapFailureToMessage.map(failure))),
      (riwayatPembayaran) => emit(RiwayatPembayaranLoaded(riwayatPembayaran)),
    );
  }
}
