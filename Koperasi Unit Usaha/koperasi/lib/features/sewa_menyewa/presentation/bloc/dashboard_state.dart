import 'package:koperasi/features/sewa_menyewa/domain/entities/dashboard.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Dashboard dashboard;

  DashboardLoaded(this.dashboard);
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}
