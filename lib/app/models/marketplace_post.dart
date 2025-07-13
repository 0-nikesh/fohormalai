import 'package:flutter/foundation.dart';

import 'user.dart';

class MarketplacePost {
  final String id;
  final User? user;
  final String title;
  final String description;
  final List<String> hashtags;
  final double price;
  final String? quantity;
  final String wasteType;
  final String location;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final List<String> imageUrls;
  final DateTime createdAt;

  MarketplacePost({
    required this.id,
    this.user,
    required this.title,
    required this.description,
    required this.hashtags,
    required this.price,
    this.quantity,
    required this.wasteType,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.imageUrls = const [], // Default to empty list
    required this.createdAt,
  });

  factory MarketplacePost.fromJson(Map<String, dynamic> json) {
    debugPrint('MarketplacePost payload: \n$json'); // Log the payload

    // Handle potential invalid data safely
    List<String> parseHashtags() {
      try {
        if (json['hashtags'] == null) return [];
        if (json['hashtags'] is List)
          return List<String>.from(json['hashtags']);
        if (json['hashtags'] is String) {
          final hashtagString = json['hashtags'] as String;
          if (hashtagString.isEmpty) return [];
          return hashtagString.split(',');
        }
        return [];
      } catch (e) {
        debugPrint('Error parsing hashtags: $e');
        return [];
      }
    }

    // Handle potential date parsing issues
    DateTime parseDate() {
      try {
        if (json['created_at'] == null) return DateTime.now();
        return DateTime.parse(json['created_at'].toString());
      } catch (e) {
        debugPrint('Error parsing date: $e');
        return DateTime.now();
      }
    }

    // Handle potential numeric parsing issues
    double parseDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return defaultValue;
        }
      }
      return defaultValue;
    }

    // Handle multiple image URLs
    List<String> parseImageUrls() {
      try {
        List<String> urls = [];

        // First check for multiple images
        if (json['image_urls'] != null && json['image_urls'] is List) {
          urls = List<String>.from(
            json['image_urls'],
          ).where((url) => url.isNotEmpty).toList();
        }

        // If no multiple images, check for single image URL
        if (urls.isEmpty &&
            json['image_url'] != null &&
            json['image_url'].toString().isNotEmpty) {
          urls.add(json['image_url'].toString());
        }

        return urls;
      } catch (e) {
        debugPrint('Error parsing image URLs: $e');
        return [];
      }
    }

    return MarketplacePost(
      id: json['id']?.toString() ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      hashtags: parseHashtags(),
      price: parseDouble(json['price']),
      quantity: json['quantity']?.toString(),
      wasteType: json['waste_type']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      imageUrl: json['image_url']?.toString(),
      imageUrls: parseImageUrls(),
      createdAt: parseDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'title': title,
      'description': description,
      'hashtags': hashtags,
      'price': price,
      'quantity': quantity,
      'waste_type': wasteType,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
