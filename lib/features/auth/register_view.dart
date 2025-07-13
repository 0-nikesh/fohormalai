import 'package:flutter/material.dart';
import 'package:fohormalai/app/api_endpoints.dart';
import 'package:fohormalai/features/auth/login_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  double? latitude;
  double? longitude;
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackBar("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackBar("Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorSnackBar("Location permission permanently denied.");
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    latitude = pos.latitude;
    longitude = pos.longitude;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude!,
        longitude!,
      );
      final place = placemarks.first;
      setState(() {
        _locationController.text =
            '${place.street}, ${place.locality}, ${place.administrativeArea}';
      });
    } catch (e) {
      setState(() {
        _locationController.text = 'Location detected';
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      print("[❌] Form validation failed");
      return;
    }

    if (latitude == null || longitude == null) {
      print("[📍] Trying to get current location...");
      await _getCurrentLocation();
      if (latitude == null || longitude == null) {
        print("[❌] Location not detected");
        _showErrorSnackBar("Location not detected.");
        return;
      }
    }

    setState(() => isLoading = true);

    final payload = {"email": _emailController.text.trim()};

    print("[🚀] Submitting form with payload: $payload");
    print("[🌐] Endpoint: ${ApiEndpoints.baseUrl + ApiEndpoints.sendOtp}");

    try {
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

      print("[✅] Response Status: ${response.statusCode}");
      print("[📦] Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => isLoading = false);
        if (!mounted) return;
        _showSuccessSnackBar("OTP sent to your email. Please verify.");

        Navigator.pushNamed(
          context,
          '/otp',
          arguments: {
            'full_name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'location': _locationController.text.trim(),
            'latitude': latitude,
            'longitude': longitude,
            'password': _passwordController.text.trim(),
          },
        );
      } else {
        setState(() => isLoading = false);
        _showErrorSnackBar(
          "Error: ${response.data['error'] ?? 'Unknown error'}",
        );
      }
    } on DioException catch (e) {
      setState(() => isLoading = false);
      print("[🔥] DioException Type: ${e.type}");
      print("[🔥] DioException Message: ${e.message}");

      // Handle timeout - OTP might still have been sent successfully
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        print(
          "[⚠️] Timeout occurred, but OTP might have been sent. Proceeding to OTP page.",
        );

        if (!mounted) return;
        _showSuccessSnackBar(
          "OTP request sent. Please check your email and enter the code.",
        );

        // Navigate to OTP page even on timeout since backend might have processed the request
        Navigator.pushNamed(
          context,
          '/otp',
          arguments: {
            'full_name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'location': _locationController.text.trim(),
            'latitude': latitude,
            'longitude': longitude,
            'password': _passwordController.text.trim(),
          },
        );
      } else {
        // Handle other Dio exceptions
        _showErrorSnackBar(
          "Network Error: ${e.response?.data?['error'] ?? e.message ?? 'Please check your connection'}",
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("[💥] Unknown Exception: $e");
      _showErrorSnackBar("Unexpected Error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
        content: Text(message),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header Section - Compact
                  _buildCompactHeader(),

                  const SizedBox(height: 20),

                  // Register Form Card - Compact
                  _buildCompactRegisterCard(),

                  const SizedBox(height: 16),

                  // Login Link - Compact
                  _buildCompactLoginLink(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
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
          'Create your account',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactRegisterCard() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign Up',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Name Field
            _buildCompactInputField(
              controller: _nameController,
              icon: Icons.person_outline,
              label: 'Full Name',
              validator: (val) => val!.isEmpty ? 'Enter your name' : null,
            ),

            const SizedBox(height: 12),

            // Phone Field
            _buildCompactInputField(
              controller: _phoneController,
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (val) =>
                  val!.length != 10 ? 'Enter a valid 10-digit number' : null,
            ),

            const SizedBox(height: 12),

            // Email Field
            _buildCompactInputField(
              controller: _emailController,
              icon: Icons.email_outlined,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (val) =>
                  val!.contains('@') ? null : 'Enter a valid email',
            ),

            const SizedBox(height: 12),

            // Location Field
            _buildLocationField(),

            const SizedBox(height: 12),

            // Password Field
            _buildCompactInputField(
              controller: _passwordController,
              icon: Icons.lock_outline,
              label: 'Password',
              obscureText: _obscurePassword,
              validator: (val) =>
                  val!.length < 6 ? 'Minimum 6 characters' : null,
              suffixIcon: IconButton(
                iconSize: 18,
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            // Confirm Password Field
            _buildCompactInputField(
              controller: _confirmPasswordController,
              icon: Icons.lock_outline,
              label: 'Confirm Password',
              obscureText: _obscureConfirmPassword,
              validator: (val) => val != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
              suffixIcon: IconButton(
                iconSize: 18,
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Register Button
            _buildCompactRegisterButton(),

            const SizedBox(height: 16),

            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300], height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Or',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300], height: 1)),
              ],
            ),

            const SizedBox(height: 16),

            // Google Sign Up Button
            _buildCompactGoogleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 18),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: _locationController,
        readOnly: true,
        validator: (val) => val!.isEmpty ? 'Location is required' : null,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
        decoration: InputDecoration(
          hintText: "Tap location icon to detect",
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: Colors.grey[600],
            size: 18,
          ),
          suffixIcon: IconButton(
            iconSize: 18,
            icon: Icon(Icons.my_location, color: const Color(0xFF4CAF50)),
            onPressed: _getCurrentLocation,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRegisterButton() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildCompactGoogleButton() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: OutlinedButton.icon(
        icon: const FaIcon(
          FontAwesomeIcons.google,
          color: Color(0xFFDB4437),
          size: 16,
        ),
        label: Text(
          'Continue with Google',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLoginLink() {
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
            "Already have an account? ",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            child: Text(
              'Sign In',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
