import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../api_endpoints.dart';
import '../models/collection_request.dart';
import '../services/auth_service.dart';

class CollectionRequestService {
  static final AuthService _authService = AuthService();

  static Future<String?> _getToken() async {
    try {
      final token = await _authService.getToken();

      if (kDebugMode) {
        print('🔑 CollectionRequestService: Getting token');
        if (token != null) {
          print('✅ Token found: ${token.substring(0, 20)}...');
        } else {
          print('⚠️ No token found');
        }
      }

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting token: $e');
      }
      throw Exception('Not authenticated');
    }
  }

  static Future<void> createCollectionRequest({
    required String wasteType,
    required String quantity,
    required DateTime pickupDate,
    required String location,
    required double latitude,
    required double longitude,
    String? specialNotes,
    String? imagePath,
  }) async {
    if (kDebugMode) {
      print('\n📤 CollectionRequestService: Creating collection request');
      print('🗑️ Waste Type: $wasteType');
      print('📦 Quantity: $quantity');
      print('📅 Pickup Date: ${pickupDate.toIso8601String()}');
      print('📍 Location: $location');
      print('🌍 Coordinates: $latitude, $longitude');
      print('📝 Special Notes: $specialNotes');
      print('📸 Image path: $imagePath');
    }

    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = '${ApiEndpoints.baseUrl}/api/collection-request/';
    if (kDebugMode) {
      print('🌐 Full request URL: $url');
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers['Authorization'] = token.startsWith('Bearer ')
          ? token
          : 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      if (kDebugMode) {
        print('🔐 Authorization header: ${request.headers['Authorization']}');
      }

      // Add form fields
      request.fields['waste_type'] = wasteType.toLowerCase();
      request.fields['quantity'] = quantity;
      request.fields['pickup_date'] = pickupDate.toIso8601String();
      request.fields['location'] = location;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      if (specialNotes != null && specialNotes.isNotEmpty) {
        request.fields['special_notes'] = specialNotes;
      }

      // Add image if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          final file = File(imagePath);
          if (await file.exists()) {
            if (kDebugMode) {
              print('✓ Image file exists: $imagePath');
              print('✓ File size: ${await file.length()} bytes');
            }

            // Get file extension
            final extension = imagePath.split('.').last.toLowerCase();
            final mimeType = extension == 'jpg' || extension == 'jpeg'
                ? 'image/jpeg'
                : extension == 'png'
                ? 'image/png'
                : 'application/octet-stream';

            request.files.add(
              await http.MultipartFile.fromPath(
                'image',
                imagePath,
                contentType: MediaType.parse(mimeType),
              ),
            );

            if (kDebugMode) {
              print('📸 Added image file to request');
            }
          } else {
            if (kDebugMode) {
              print('❌ Image file does not exist: $imagePath');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error adding image file: $e');
          }
        }
      }

      if (kDebugMode) {
        print('📤 Sending collection request...');
        print('📋 Request fields: ${request.fields}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📡 Response status: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Collection request created successfully!');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to create collection request',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception during request: $e');
      }
      throw Exception('Failed to create collection request: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserRequests() async {
    if (kDebugMode) {
      print('\n🔍 CollectionRequestService: Fetching user collection requests');
    }

    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    // Get the current user ID
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('User ID not found');

    final url =
        '${ApiEndpoints.baseUrl}${ApiEndpoints.getUserCollectionRequests}$userId/';
    if (kDebugMode) {
      print('👤 User ID: $userId');
      print('🌐 Request URL: $url');
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token.startsWith('Bearer ')
              ? token
              : 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('📡 Response status: ${response.statusCode}');
        print(
          '📄 Response body: ${response.body.substring(0, min(100, response.body.length))}...',
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for both 'requests' and 'collection_requests' keys in the response
        if (data is Map) {
          if (data.containsKey('collection_requests')) {
            if (kDebugMode) {
              print(
                '✅ Retrieved ${(data['collection_requests'] as List).length} collection requests for user',
              );
            }
            return List<Map<String, dynamic>>.from(data['collection_requests']);
          } else if (data.containsKey('requests')) {
            if (kDebugMode) {
              print(
                '✅ Retrieved ${(data['requests'] as List).length} collection requests for user',
              );
            }
            return List<Map<String, dynamic>>.from(data['requests']);
          }
        }

        if (kDebugMode) {
          print('⚠️ Unexpected response structure: $data');
        }
        return [];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to fetch user collection requests',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception during request: $e');
      }
      throw Exception('Failed to fetch user collection requests: $e');
    }
  }

  static Future<List<CollectionRequest>> getUserCollectionRequests() async {
    try {
      final requestsData = await getUserRequests();

      if (kDebugMode) {
        print('🔄 Processing ${requestsData.length} collection requests');
        if (requestsData.isNotEmpty) {
          print('📋 First request sample: ${requestsData[0]}');
        }
      }

      final collectionRequests = requestsData.map((data) {
        try {
          return CollectionRequest.fromJson(data);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error parsing individual request: $e');
            print('⚠️ Problematic data: $data');
          }
          rethrow;
        }
      }).toList();

      if (kDebugMode) {
        print(
          '✅ Successfully parsed ${collectionRequests.length} collection requests',
        );
      }

      return collectionRequests;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing collection requests: $e');
      }
      throw Exception('Failed to process collection requests: $e');
    }
  }
}
