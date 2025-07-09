class UserNotification {
  final String id;
  final String title;
  final String message;
  final String notificationType;
  final bool isRead;
  final DateTime sentAt;
  final PickupScheduleNotification? pickupSchedule;

  UserNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    required this.sentAt,
    this.pickupSchedule,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      notificationType: json['notification_type'],
      isRead: json['is_read'],
      sentAt: DateTime.parse(json['sent_at']),
      pickupSchedule: json['pickup_schedule'] != null
          ? PickupScheduleNotification.fromJson(json['pickup_schedule'])
          : null,
    );
  }
}

class PickupScheduleNotification {
  final String id;
  final DateTime dateTime;
  final String location;

  PickupScheduleNotification({
    required this.id,
    required this.dateTime,
    required this.location,
  });

  factory PickupScheduleNotification.fromJson(Map<String, dynamic> json) {
    return PickupScheduleNotification(
      id: json['id'],
      dateTime: DateTime.parse(json['date_time']),
      location: json['location'],
    );
  }
}
