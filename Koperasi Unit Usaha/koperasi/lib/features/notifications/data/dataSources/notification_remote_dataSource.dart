import 'dart:convert';

import 'package:koperasi/core/constants/api_constant.dart';
import 'package:koperasi/core/errors/exceptions.dart';
import 'package:koperasi/features/notifications/data/models/notification_model.dart';
import 'package:koperasi/features/notifications/domain/entities/notification_entity.dart';
import 'package:http/http.dart' as http;

abstract class NotificationRemoteDatasource {
  Future<List<NotificationEntity>> getNotifications(String token);
}

class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final http.Client client;

  NotificationRemoteDatasourceImpl(this.client);

  @override
  Future<List<NotificationEntity>> getNotifications(String token) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/notifications');

    try {
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("Data Notifications: $jsonResponse");

        final List<dynamic>? data = jsonResponse['data']?['data'];

        if (data == null || data.isEmpty) {
          return [];
        }

        final List<NotificationEntity> notifications = data
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        return notifications;
      } else {
        throw ServerException('Failed to load notification');
      }
    } catch (e) {
      throw ServerException('Failed to get notification: $e');
    }
  }
}
