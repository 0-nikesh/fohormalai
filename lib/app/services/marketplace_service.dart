import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/marketplace_post.dart';
import '../api_endpoints.dart';
import '../services/auth_service.dart';

class MarketplaceService {
  static final AuthService _authService = AuthService();

  static Future<String?> _getToken() async {
    try {
      final token = await _authService.getToken();

      if (kDebugMode) {
        print('\n🔑 MarketplaceService: Getting token');
        if (token != null) {
          print(
            '✅ Token found: ${token.substring(0, min(20, token.length))}...',
          );
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

  static Future<List<MarketplacePost>> getPosts() async {
    if (kDebugMode) {
      print('\n📦 MarketplaceService: Fetching posts');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token is null');
    }

    if (kDebugMode) {
      print(
        '🌐 Making request to: ${ApiEndpoints.baseUrl}${ApiEndpoints.getMarketplacePosts}',
      );
      print('🔑 Using token: ${token.substring(0, min(20, token.length))}...');
    }

    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getMarketplacePosts}'),
      headers: {
        'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (kDebugMode) {
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final posts = (data['posts'] as List)
          .map((post) => MarketplacePost.fromJson(post))
          .toList();
      return posts;
    } else {
      throw Exception('Failed to load marketplace posts: ${response.body}');
    }
  }

  static Future<void> createPost({
    required String title,
    required String description,
    required List<String> hashtags,
    required double price,
    String? quantity,
    required String wasteType,
    required String location,
    required double latitude,
    required double longitude,
    String? imagePath, // Optional image file path
  }) async {
    if (kDebugMode) {
      print('\n📤 MarketplaceService: Creating new post');
      print('� Title: $title');
      print('📝 Description: $description');
      print('🏷️ Hashtags: $hashtags');
      print('💰 Price: $price');
      print('📦 Quantity: $quantity');
      print('🗑️ Waste Type: $wasteType');
      print('📍 Location: $location');
      print('🌍 Coordinates: $latitude, $longitude');
      print('�📸 Image path: $imagePath');
      print(
        '🌐 API Endpoint: ${ApiEndpoints.baseUrl}${ApiEndpoints.createMarketplacePost}',
      );
    }

    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    // Create the request with full URL - double check the endpoint
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.createMarketplacePost}',
    );
    if (kDebugMode) {
      print('🌐 Full request URL: $url');
    }

    var request = http.MultipartRequest('POST', url);

    // Add the authorization header - ensure correct format without double Bearer
    final normalizedToken = token.startsWith('Bearer ')
        ? token // Already has Bearer prefix
        : 'Bearer $token'; // Add Bearer prefix

    request.headers['Authorization'] = normalizedToken;

    // Add Content-Type for the multipart request
    request.headers['Accept'] = 'application/json';

    // Debugging the exact header value
    if (kDebugMode) {
      print('🔐 Auth header exact value: ${request.headers['Authorization']}');

      // Try a second method to see if the backend might be expecting a different format
      if (!normalizedToken.contains('Bearer')) {
        print('⚠️ Warning: Token might not have Bearer prefix properly set');
      }
    }

    if (kDebugMode) {
      print('🔑 Using token: ${token.substring(0, min(20, token.length))}...');
    }

    // Add text fields - match the exact field names from backend
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['hashtags'] = hashtags.join(
      ',',
    ); // Match backend expectations
    request.fields['price'] = price.toString();
    if (quantity != null) request.fields['quantity'] = quantity;
    request.fields['waste_type'] = wasteType
        .toLowerCase(); // Match exact field name from backend
    request.fields['location'] = location;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();

    if (kDebugMode) {
      print('📦 Request fields:');
      request.fields.forEach((key, value) {
        print('  $key: $value');
      });
    }

    // Add the image file
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        // Check if file exists and is readable
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          if (kDebugMode) {
            print('✓ Image file exists: $imagePath');
            print('✓ File size: ${await imageFile.length()} bytes');
          }

          final file = await http.MultipartFile.fromPath('image', imagePath);
          request.files.add(file);

          if (kDebugMode) {
            print(
              '📸 Added image file: ${file.filename}, size: ${file.length} bytes',
            );
          }
        } else {
          if (kDebugMode) {
            print('❌ Image file does not exist: $imagePath');
          }
          throw Exception('Image file does not exist or is not accessible');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error adding image file: $e');
        }
        throw Exception('Failed to attach image: $e');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ No image file to attach');
      }
    }

    if (kDebugMode) {
      print('🌐 Making request to: ${request.url}');
      print('🔑 Using headers with Authorization token');
      print('📤 Sending request...');
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📡 Response status: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
        print('📄 Response headers:');
        response.headers.forEach((key, value) {
          print('  $key: $value');
        });
      }

      if (response.statusCode != 201) {
        if (kDebugMode) {
          print('❌ Request failed with status ${response.statusCode}');
          try {
            final errorJson = json.decode(response.body);
            print('❌ Error details: $errorJson');
          } catch (e) {
            print('❌ Raw error response: ${response.body}');
          }
        }
        throw Exception('Failed to create marketplace post: ${response.body}');
      } else {
        if (kDebugMode) {
          print('✅ Post created successfully!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception during request: $e');
      }
      throw Exception('Failed to create marketplace post: $e');
    }
  }
}
