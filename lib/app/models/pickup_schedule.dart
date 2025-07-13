import 'package:flutter/foundation.dart';

class PickupSchedule {
  final String id;
  final Map<String, dynamic>? admin;
  final DateTime dateTime;
  final String location;
  final double latitude;
  final double longitude;
  final double? coverageRadiusKm;
  final String garbageType;
  final String description;
  final String status;
  final int? usersNotified;
  final DateTime createdAt;
  final String notes;
  final double? distanceKm;
  final bool? isUpcoming;

  PickupSchedule({
    required this.id,
    this.admin,
    required this.dateTime,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.coverageRadiusKm,
    required this.garbageType,
    required this.description,
    required this.status,
    this.usersNotified,
    required this.createdAt,
    this.notes = '',
    this.distanceKm,
    this.isUpcoming,
  });

  factory PickupSchedule.fromJson(Map<String, dynamic> json) {
    try {
      return PickupSchedule(
        id: json['id']?.toString() ?? '',
        admin: json['admin'] as Map<String, dynamic>?,
        dateTime: DateTime.parse(
          json['date_time'] ?? DateTime.now().toIso8601String(),
        ),
        location: json['location']?.toString() ?? 'Unknown Location',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        coverageRadiusKm: json['coverage_radius_km'] != null
            ? (json['coverage_radius_km'] as num).toDouble()
            : null,
        garbageType: (json['garbage_type']?.toString() ?? 'mixed')
            .toLowerCase(),
        description: json['description']?.toString() ?? '',
        status: (json['status']?.toString() ?? 'scheduled').toLowerCase(),
        usersNotified: json['users_notified'] as int?,
        createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String(),
        ),
        notes: json['notes']?.toString() ?? '',
        distanceKm: json['distance_km'] != null
            ? (json['distance_km'] as num).toDouble()
            : null,
        isUpcoming: json['is_upcoming'] as bool?,
      );
    } catch (e) {
      debugPrint('Error parsing PickupSchedule: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  // Helper method to get admin name
  String get adminName {
    if (admin != null && admin!['name'] != null) {
      return admin!['name'];
    }
    return 'Unknown Admin';
  }
}
