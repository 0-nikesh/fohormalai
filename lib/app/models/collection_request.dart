import 'package:flutter/foundation.dart';
import 'user.dart';

class CollectionRequest {
  final String id;
  final String userId;
  final User? user;
  final String wasteType;
  final String quantity;
  final DateTime pickupDate;
  final String location;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? specialNotes;
  final String? status;
  final DateTime createdAt;

  CollectionRequest({
    required this.id,
    required this.userId,
    this.user,
    required this.wasteType,
    required this.quantity,
    required this.pickupDate,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.specialNotes,
    this.status,
    required this.createdAt,
  });

  factory CollectionRequest.fromJson(Map<String, dynamic> json) {
    // Debug the incoming JSON data for better error handling
    if (kDebugMode) {
      print('🔍 Parsing CollectionRequest JSON: ${json.keys.toList()}');
    }

    // Handle date parsing safely
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();

      try {
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        } else if (dateValue is Map && dateValue.containsKey('\$date')) {
          return DateTime.parse(dateValue['\$date']);
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error parsing date: $dateValue - $e');
        }
      }

      return DateTime.now();
    }

    // Handle various field name formats
    return CollectionRequest(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['user']?.toString() ?? '',
      user: json['user_details'] != null
          ? User.fromJson(json['user_details'])
          : null,
      wasteType: json['waste_type'] ?? json['wasteType'] ?? '',
      quantity: json['quantity'] ?? '',
      pickupDate: json['pickup_date'] != null
          ? parseDate(json['pickup_date'])
          : json['pickupDate'] != null
          ? parseDate(json['pickupDate'])
          : DateTime.now(),
      location: json['location'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString()) ?? 0.0
          : 0.0,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString()) ?? 0.0
          : 0.0,
      imageUrl: json['image_url'] ?? json['imageUrl'],
      specialNotes: json['special_notes'] ?? json['specialNotes'],
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null
          ? parseDate(json['created_at'])
          : json['createdAt'] != null
          ? parseDate(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'waste_type': wasteType,
      'quantity': quantity,
      'pickup_date': pickupDate.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'special_notes': specialNotes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
