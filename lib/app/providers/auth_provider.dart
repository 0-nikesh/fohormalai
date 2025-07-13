import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  AuthProvider() {
    _checkLoginStatus();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _checkLoginStatus() async {
    _setLoading(true);
    try {
      _token = await _authService.getToken();
      if (_token != null) {
        // Get user data from stored preferences
        final userData = await _authService.getUserData();
        if (userData != null) {
          _user = User.fromJson(userData);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }
      await _authService.logout();
      _token = null;
      _user = null;
    }
    _setLoading(false);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _setLoading(true);
    try {
      if (kDebugMode) {
        print('🔄 AuthProvider: Initiating login process');
        print('📧 Email: $email');
        print('⏳ Calling AuthService.login()...');
      }

      final result = await _authService.login(email, password);

      if (kDebugMode) {
        print('✅ AuthProvider: Login result received');
        print('📊 Result: $result');
      }

      if (result['success']) {
        _token = await _authService.getToken();
        final userData = await _authService.getUserData();
        if (userData != null) {
          _user = User.fromJson(userData);
        }
        notifyListeners();
      }

      _setLoading(false);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthProvider: Login error');
        print('💥 Error details: $e');
      }
      _setLoading(false);
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    _setLoading(true);
    try {
      final result = await _authService.googleSignIn(idToken);

      if (result['success']) {
        _token = await _authService.getToken();
        // Fetch user data from stored preferences
        final userData = await _authService.getUserData();
        if (userData != null) {
          _user = User.fromJson(userData);
        }
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return {
        'success': false,
        'message': 'An unexpected error occurred during Google sign in',
      };
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _token = null;
    _user = null;
    _setLoading(false);
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        location: location,
        latitude: latitude,
        longitude: longitude,
      );

      // If registration returns a token and user data (immediate login)
      if (result['success'] && result['data']['token'] != null) {
        _token = await _authService.getToken();
        final userData = await _authService.getUserData();
        if (userData != null) {
          _user = User.fromJson(userData);
        }
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return {
        'success': false,
        'message': 'An unexpected error occurred during registration',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    _setLoading(true);
    try {
      final result = await _authService.verifyOtp(email, otp);
      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return {
        'success': false,
        'message': 'An unexpected error occurred during OTP verification',
      };
    }
  }
}
