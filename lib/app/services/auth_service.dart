import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_endpoints.dart';

class AuthService {
  final Dio _dio = Dio();
  final String _baseUrl =
      ApiEndpoints.baseUrl; // Use the centralized API endpoint configuration

  // Keys for SharedPreferences
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final loginUrl = '${_baseUrl}${ApiEndpoints.login}';

      if (kDebugMode) {
        print('\n🔐 AuthService: Processing login request');
        print('📍 Full API URL: $loginUrl');
        print('📧 Email: $email');
        print('🔒 Password length: ${password.length}');
        print('⚙️ Request headers: ${_dio.options.headers}');
      }

      final response = await _dio.post(
        loginUrl,
        data: {'email': email, 'password': password},
      );

      if (kDebugMode) {
        print('\n📡 API Response Details:');
        print('📊 Status code: ${response.statusCode}');
        print('🔍 Response headers: ${response.headers}');
        print('📦 Response data: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        final isAdmin = response.data['is_admin'];
        // Extract userId from backend response (adjust key as needed)
        final userId =
            response.data['user']?['id']?.toString() ??
            response.data['id']?.toString() ??
            email;
        // Create user data map from response
        final userData = {
          'email': email,
          'is_admin': isAdmin,
          // Add any other user data you receive from the backend
        };
        if (kDebugMode) {
          print('\n✅ Login successful:');
          print(
            '🎫 Token received (first 10 chars): \\${token.toString().substring(0, min(10, token.toString().length))}...',
          );
          print('👤 User data saved: $userData');
          print('🆔 User ID saved: $userId');
        }
        // Save token and user data with real userId
        await _saveAuthData(token, userId, userData);
        return {
          'success': true,
          'data': userData,
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed. Please check your credentials.',
        };
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Login error: ${e.message}');
        print('❌ Error type: ${e.type}');
        print('❌ Error response: ${e.response}');
        print('❌ Error data: ${e.response?.data}');
        print('❌ Request: ${e.requestOptions.uri}');
        print('❌ Request data: ${e.requestOptions.data}');
      }

      // Handle specific error responses from backend
      if (e.response?.statusCode == 400) {
        return {
          'success': false,
          'message':
              e.response?.data['error'] ?? 'Email and password are required.',
        };
      } else if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': e.response?.data['error'] ?? 'Incorrect password',
        };
      } else if (e.response?.statusCode == 404) {
        return {
          'success': false,
          'message': e.response?.data['error'] ?? 'User not found',
        };
      }

      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Network error occurred',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Google Sign In
  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/google',
        data: {'id_token': idToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['user'];
        final token = response.data['token'];

        await _saveAuthData(token, userData['id'].toString(), userData);

        return {
          'success': true,
          'data': userData,
          'message': 'Google sign in successful',
        };
      } else {
        return {'success': false, 'message': 'Google sign in failed.'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Google sign in error: $e');
      }
      return {
        'success': false,
        'message': 'An error occurred during Google sign in',
      };
    }
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/register',
        data: {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'location': location,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Check if we get a token upon registration
        if (response.data['token'] != null) {
          final token = response.data['token'];
          final isAdmin = response.data['is_admin'] ?? false;
          // Extract userId from backend response (adjust key as needed)
          final userId =
              response.data['user']?['id']?.toString() ??
              response.data['id']?.toString() ??
              email;
          // Create user data from registration info
          final userData = {
            'email': email,
            'full_name': fullName,
            'is_admin': isAdmin,
            'location': location,
            'latitude': latitude,
            'longitude': longitude,
          };
          await _saveAuthData(token, userId, userData);
        }
        return {
          'success': true,
          'data': response.data,
          'message': 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Registration failed',
        };
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Registration error: ${e.message}');
      }
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      return {
        'success': false,
        'message': 'An unexpected error occurred during registration',
      };
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/verify-otp',
        data: {'email': email, 'otp_code': otp},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'OTP verification successful',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('OTP verification error: $e');
      }
      return {
        'success': false,
        'message': 'An error occurred during OTP verification',
      };
    }
  }

  // Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userDataKey);
    return _decodeUserData(userData);
  }

  // Save authentication data
  Future<void> _saveAuthData(
    String token,
    String userId, [
    Map<String, dynamic>? userData,
  ]) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (kDebugMode) {
        print('\n💾 Saving auth data:');
        print('🎫 Token: ${token.substring(0, min(10, token.length))}...');
        print('👤 User ID: $userId');
      }

      // Save token with Bearer prefix
      await prefs.setString(tokenKey, 'Bearer $token');
      await prefs.setString(userIdKey, userId);

      // Save user data if provided
      if (userData != null) {
        await prefs.setString(userDataKey, _encodeUserData(userData));
      }

      if (kDebugMode) {
        // Verify the data was saved
        final savedToken = await prefs.getString(tokenKey);
        print('✅ Token saved successfully: ${savedToken != null}');
        if (savedToken != null) {
          print(
            '🔍 Saved token starts with: ${savedToken.substring(0, min(20, savedToken.length))}...',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving auth data: $e');
      }
      throw Exception('Failed to save authentication data');
    }
  }

  // Encode user data to JSON string
  String _encodeUserData(Map<String, dynamic> userData) {
    return const JsonEncoder().convert(userData);
  }

  // Decode user data from JSON string
  Map<String, dynamic>? _decodeUserData(String? userData) {
    if (userData == null) return null;
    return const JsonDecoder().convert(userData) as Map<String, dynamic>;
  }

  // Get authentication token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);

      if (kDebugMode) {
        print('\n🔑 Getting auth token:');
        if (token != null) {
          print(
            '✅ Token found: ${token.substring(0, min(20, token.length))}...',
          );
        } else {
          print('⚠️ No token found in SharedPreferences');
        }
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting token: $e');
      }
      return null;
    }
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
  }
}
