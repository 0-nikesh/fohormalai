import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api_endpoints.dart';
import '../models/notification.dart';
import 'auth_service.dart';

class NotificationService {
  static Future<List<UserNotification>> getNotifications({bool? isRead}) async {
    final token = await AuthService().getToken();
    final uri = Uri.parse('${ApiEndpoints.baseUrl}/api/user/notifications/')
        .replace(
          queryParameters: {if (isRead != null) 'is_read': isRead.toString()},
        );

    try {
      debugPrint('Fetching notifications from: ${uri.toString()}');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final authToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      debugPrint(
        'Using auth token: ${authToken.substring(0, min(20, authToken.length))}...',
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': authToken, 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Notifications response: $data');
        final List<dynamic> notifications = data['notifications'];
        return notifications.map((e) => UserNotification.fromJson(e)).toList();
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in getNotifications: $e');
      rethrow;
    }
  }

  static Future<void> markAsRead(List<String>? notificationIds) async {
    final token = await AuthService().getToken();
    final uri = Uri.parse('${ApiEndpoints.baseUrl}/api/user/notifications/');

    try {
      debugPrint('Marking notifications as read: $notificationIds');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final authToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      debugPrint(
        'Using auth token: ${authToken.substring(0, min(20, authToken.length))}...',
      );

      final response = await http.patch(
        uri,
        headers: {
          'Authorization': authToken,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'notification_ids': notificationIds ?? []}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Mark as read response: $data');
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception(
          'Failed to mark notifications as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Exception in markAsRead: $e');
      rethrow;
    }
  }
}
