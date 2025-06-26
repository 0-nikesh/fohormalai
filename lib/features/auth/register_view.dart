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

class _RegisterPageState extends State<RegisterPage> {
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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permission permanently denied."),
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location not detected."),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
    }

    setState(() => isLoading = true);

    final payload = {"email": _emailController.text.trim()};

    print("[🚀] Submitting form with payload: $payload");
    print("[🌐] Endpoint: ${ApiEndpoints.baseUrl + ApiEndpoints.requestOtp}");
    print(
      "[⏱️] Timeouts: send=${ApiEndpoints.connectionTimeout.inMilliseconds}ms, receive=${ApiEndpoints.receiveTimeout.inMilliseconds}ms",
    );

    try {
      final response = await Dio().post(
        ApiEndpoints.baseUrl + ApiEndpoints.requestOtp,
        data: payload,
        options: Options(
          sendTimeout: ApiEndpoints.connectionTimeout,
          receiveTimeout: ApiEndpoints.receiveTimeout,
        ),
      );

      print("[✅] Response Status: ${response.statusCode}");
      print("[📦] Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP sent to your email. Please verify."),
            duration: Duration(seconds: 2),
          ),
        );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${response.data['error'] ?? 'Unknown error'}",
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } on DioException catch (e) {
      setState(() => isLoading = false);
      print("[🔥] DioException: $e");
      print("[📦] Dio Error Data: ${e.response?.data}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Dio Error: ${e.response?.data?['error'] ?? e.message}",
          ),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      print("[💥] Unknown Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unexpected Error: $e"),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo.png', // Update path if needed
                  height: 100,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Aaba Shiti Haina',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                Text(
                  "Register",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                _buildInputField(
                  Icons.person,
                  'Full Name',
                  _nameController,
                  validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                ),
                _buildInputField(
                  Icons.phone,
                  'Phone Number',
                  _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val!.length != 10
                      ? 'Enter a valid 10-digit number'
                      : null,
                ),
                _buildInputField(
                  Icons.email,
                  'Email',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      val!.contains('@') ? null : 'Enter a valid email',
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: TextFormField(
                    controller: _locationController,
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _getCurrentLocation,
                      ),
                      hintText: "Tap the location icon to detect",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Location is required' : null,
                  ),
                ),

                _buildInputField(
                  Icons.lock,
                  'Password',
                  _passwordController,
                  obscure: true,
                  validator: (val) =>
                      val!.length < 6 ? 'Minimum 6 characters' : null,
                ),
                _buildInputField(
                  Icons.lock_outline,
                  'Confirm Password',
                  _confirmPasswordController,
                  obscure: true,
                  validator: (val) => val != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register', style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 16),
                const Text("Or sign up with"),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.redAccent,
                  ),
                  label: const Text("Continue with Google"),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: const Text(
                        "Login Now",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    IconData icon,
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
