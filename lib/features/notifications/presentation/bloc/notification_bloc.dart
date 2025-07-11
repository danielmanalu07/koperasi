import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koperasi/core/errors/map_failure_toMessage.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/notifications/domain/usecases/get_notification_usecase.dart';
import 'package:koperasi/features/notifications/presentation/bloc/notification_event.dart';
import 'package:koperasi/features/notifications/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationUsecase getNotificationUsecase;

  NotificationBloc({required this.getNotificationUsecase})
    : super(NotificationInitial()) {
    on<GetNotificationEvent>(_onGetNotification);
  }

  Future<void> _onGetNotification(
    GetNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final notifcations = await getNotificationUsecase(NoParams());
    notifcations.fold(
      (failure) => emit(NotificationError(MapFailureToMessage.map(failure))),
      (notification) => emit(NotificationLoaded(notification)),
    );
  }
}
