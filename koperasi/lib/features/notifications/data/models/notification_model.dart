import 'package:koperasi/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.date,
    required super.status,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      date: DateTime.parse(json['date'] as String),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
