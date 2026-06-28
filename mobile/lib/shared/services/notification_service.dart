import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> initialize() async {
    debugPrint('NotificationService: initialized (stub)');
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('NotificationService: show [$title] $body');
  }

  Future<void> cancelAllNotifications() async {}

  Future<String?> getFCMToken() async => null;
}
