import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api_endpoints.dart';
import '../models/pickup_schedule.dart';
import 'auth_service.dart';

class PickupScheduleService {
  static Future<List<PickupSchedule>> fetchSchedules({
    String? status,
    String? garbageType,
    bool upcomingOnly = false,
  }) async {
    final token = await AuthService().getToken();
    final uri =
        Uri.parse(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.getUserPickupSchedules}',
        ).replace(
          queryParameters: {
            if (status != null) 'status': status,
            if (garbageType != null) 'garbage_type': garbageType,
            if (upcomingOnly) 'upcoming_only': 'true',
          },
        );

    try {
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

      debugPrint('API Request: ${uri.toString()}'); // Debug request URL

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Pickup schedules response: $data'); // Debug print

        if (data == null) {
          debugPrint('API returned null response data');
          return [];
        }

        List<dynamic> schedules;

        try {
          // Try each possible response structure
          if (data['pickup_schedules'] != null) {
            schedules = data['pickup_schedules'] as List<dynamic>;
          } else if (data['schedules'] != null) {
            schedules = data['schedules'] as List<dynamic>;
          } else if (data['data'] != null) {
            schedules = data['data'] as List<dynamic>;
          } else if (data is List) {
            schedules = data;
          } else {
            debugPrint('Unexpected response structure: $data');
            return [];
          }

          debugPrint('Found schedules: ${schedules.length}');
          return schedules.map((e) => PickupSchedule.fromJson(e)).toList();
        } catch (e) {
          debugPrint('Error parsing schedule data: $e');
          debugPrint('Response data was: $data');
          return [];
        }
      } else {
        final errorBody = response.body;
        debugPrint('Error response (${response.statusCode}): $errorBody');
        throw Exception(
          'Failed to load pickup schedules: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      debugPrint('Exception in fetchSchedules: $e');
      rethrow;
    }
  }

  static Future<List<PickupSchedule>> getActivePickups() async {
    try {
      debugPrint('🔑 Getting auth token:');
      final token = await AuthService().getToken();
      if (token != null) {
        debugPrint(
          '✅ Token found: ${token.substring(0, min(20, token.length))}...',
        );
      } else {
        throw Exception('No authentication token found');
      }

      final authToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.getActivePickups),
        headers: {'Authorization': authToken, 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('📦 Response data: $data');

        if (data['active_pickups'] == null) {
          debugPrint('❌ No active_pickups field in response');
          return [];
        }

        final List<dynamic> pickups = data['active_pickups'];
        return pickups
            .map((pickup) => PickupSchedule.fromJson(pickup))
            .toList();
      } else {
        debugPrint(
          '❌ Error response (${response.statusCode}): ${response.body}',
        );
        throw Exception(
          'Failed to load active pickups: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error getting active pickups: $e');
      rethrow;
    }
  }
}
