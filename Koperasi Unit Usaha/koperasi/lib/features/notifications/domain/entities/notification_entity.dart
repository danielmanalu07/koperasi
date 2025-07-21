import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String message;
  final String type;
  final DateTime date;
  final bool status;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    date,
    status,
    createdAt,
  ];
}
