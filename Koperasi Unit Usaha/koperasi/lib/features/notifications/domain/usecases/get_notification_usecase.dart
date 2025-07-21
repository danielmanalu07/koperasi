import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/notifications/domain/entities/notification_entity.dart';
import 'package:koperasi/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationUsecase
    implements Usecase<List<NotificationEntity>, NoParams> {
  final NotificationRepository notificationRepository;

  GetNotificationUsecase(this.notificationRepository);

  @override
  Future<Either<Failures, List<NotificationEntity>>> call(
    NoParams params,
  ) async {
    final res = await notificationRepository.getNotifications();
    return res;
  }
}
