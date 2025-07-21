import 'package:dartz/dartz.dart';
import 'package:koperasi/core/errors/failures.dart';
import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:koperasi/features/notifications/data/dataSources/notification_remote_dataSource.dart';
import 'package:koperasi/features/notifications/domain/entities/notification_entity.dart';
import 'package:koperasi/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource notificationRemoteDatasource;
  final LocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({
    required this.notificationRemoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, List<NotificationEntity>>> getNotifications() async {
    if (await networkInfo.isConnected) {
      try {
        final token = await localDatasource.getToken();
        final notifications = await notificationRemoteDatasource
            .getNotifications(token!);
        return Right(notifications);
      } catch (e) {
        throw Left(e.toString());
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
