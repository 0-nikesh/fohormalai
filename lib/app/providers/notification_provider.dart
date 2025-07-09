import 'package:flutter/material.dart';
import 'dart:async';
import '../services/notification_service.dart';
import '../models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<UserNotification>? _notifications;
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  NotificationProvider() {
    // Initial fetch
    fetchNotifications();

    // Set up periodic refresh every 5 minutes
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => fetchNotifications(),
    );
  }

  List<UserNotification>? get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications?.where((n) => !n.isRead).length ?? 0;

  Future<void> fetchNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final notifications = await NotificationService.getNotifications();

      _notifications = notifications;
      _error = null;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
