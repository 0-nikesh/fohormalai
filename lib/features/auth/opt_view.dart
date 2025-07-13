import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fohormalai/app/api_endpoints.dart';
import 'dart:async';
import 'dart:ui';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool isLoading = false;
  bool _isResending = false;
  int _countdown = 60;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _startCountdown();
    _animationController.forward();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-submit when all fields are filled
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
  }

  void _clearOtp() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendOtp() async {
    if (_isResending || _countdown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['email'] != null) {
        final payload = {"email": args['email']};

        print("🔄 Resending OTP to: ${args['email']}");

        final response = await Dio().post(
          ApiEndpoints.baseUrl + ApiEndpoints.sendOtp,
          data: payload,
          options: Options(
            sendTimeout: const Duration(seconds: 30), // Increased timeout
            receiveTimeout: const Duration(seconds: 30), // Increased timeout
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

        print("✅ Resend OTP Response: ${response.statusCode}");
        print("📦 Response Data: ${response.data}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          _showSuccessSnackBar('OTP sent successfully!');
          _startCountdown();
          _clearOtp();
        } else {
          _showErrorSnackBar('Failed to resend OTP');
        }
      }
    } on DioException catch (e) {
      print("❌ Dio Error: ${e.type}");
      print("❌ Error Message: ${e.message}");

      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        // Even if timeout, the OTP might have been sent successfully
        _showSuccessSnackBar('OTP request sent. Please check your email.');
        _startCountdown();
        _clearOtp();
      } else {
        _showErrorSnackBar('Failed to resend OTP. Please try again.');
      }
    } catch (e) {
      print("❌ General Error: $e");
      _showErrorSnackBar('Failed to resend OTP: $e');
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final otp = _otpCode.trim();
    if (otp.length != 6) {
      _showErrorSnackBar("Please enter the complete 6-digit code");
      return;
    }

    if (args == null) {
      _showErrorSnackBar("Registration data not found");
      return;
    }

    setState(() => isLoading = true);

    final payload = {
      'full_name': args['full_name'],
      'email': args['email'],
      'phone': args['phone'],
      'location': args['location'],
      'latitude': args['latitude'],
      'longitude': args['longitude'],
      'password': args['password'],
      'otp': otp,
    };

    print('🚀 Verifying OTP with payload: $payload');

    try {
      final response = await Dio().post(
        "${ApiEndpoints.baseUrl}/api/register/",
        data: payload,
        options: Options(
          sendTimeout: const Duration(seconds: 30), // Increased timeout
          receiveTimeout: const Duration(seconds: 30), // Increased timeout
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print("✅ OTP Verification Response: ${response.statusCode}");
      print("📦 Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar("Registration successful!");
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showErrorSnackBar(
          "Error: ${response.data['error'] ?? 'Unknown error'}",
        );
        _clearOtp();
      }
    } on DioException catch (e) {
      print("❌ Dio Error Type: ${e.type}");
      print("❌ Error Message: ${e.message}");
      print("❌ Response Data: ${e.response?.data}");

      String errorMessage = "Verification failed";

      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = "Request timeout. Please try again.";
      } else if (e.response?.data != null) {
        errorMessage =
            e.response!.data['error'] ??
            e.response!.data['message'] ??
            errorMessage;
      }

      _showErrorSnackBar(errorMessage);
      _clearOtp();
    } catch (e) {
      print("❌ General Error: $e");
      _showErrorSnackBar("Request failed: $e");
      _clearOtp();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Back button and Logo
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const Spacer(),
                      Image.asset('assets/images/logo.png', height: 32),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'OTP Verification',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  if (args != null && args['email'] != null)
                    Text(
                      'Enter the code sent to ${args['email']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),

                  const SizedBox(height: 40),

                  // OTP Fields and Verification
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildOtpInputFields(),
                        const SizedBox(height: 24),
                        _buildVerifyButton(),
                        const SizedBox(height: 24),
                        _buildResendSection(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Back to Login
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        'Back to Login',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF43A047),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Image.asset('assets/images/logo.png', height: 40, width: 40),
        ),
        const SizedBox(height: 8),
        Text(
          'Aaba Shiti Haina',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Verify your email address',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpCard(Map<String, dynamic>? args) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.15),
            const Color(0xFF81C784).withOpacity(0.1),
            Colors.white.withOpacity(0.9),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  'OTP Verification',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Please enter OTP sent to your Email',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                if (args != null && args['email'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      args['email'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // OTP Input Fields
                _buildOtpInputFields(),

                const SizedBox(height: 24),

                // Verify Button
                _buildVerifyButton(),

                const SizedBox(height: 20),

                // Resend Section
                _buildResendSection(),

                const SizedBox(height: 16),

                // Clear Button
                _buildClearButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: 40,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _otpControllers[index].text.isNotEmpty
                  ? const Color(0xFF43A047)
                  : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onOtpChanged(value, index),
            onTap: () {
              _otpControllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: _otpControllers[index].text.length),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    final isEnabled = _otpCode.length == 6;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading || !isEnabled ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF43A047),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Verify',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          'Didn\'t receive the code?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: (_isResending || _countdown > 0) ? null : _resendOtp,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isResending)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    color: const Color(0xFF43A047),
                    strokeWidth: 2,
                  ),
                )
              else
                Text(
                  _countdown > 0 ? 'Resend in ${_countdown}s' : 'Resend Code',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _countdown > 0
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF43A047),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClearButton() {
    return GestureDetector(
      onTap: _clearOtp,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear_rounded, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              'Clear',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Remember your password? ",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text(
              'Sign In',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
