import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koperasi/core/errors/map_failure_toMessage.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/get_dashboard_data.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/dashboard_event.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardData getDashboardData;

  DashboardBloc({required this.getDashboardData}) : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onGetDashboard);
  }

  Future<void> _onGetDashboard(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final dashboard = await getDashboardData(NoParams());
    dashboard.fold(
      (failures) => emit(DashboardError(MapFailureToMessage.map(failures))),
      (dashboard) => emit(DashboardLoaded(dashboard)),
    );
  }
}
