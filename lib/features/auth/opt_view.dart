import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fohormalai/app/api_endpoints.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and slogan
                Image.asset(
                  'assets/images/logo.png', // Update path if needed
                  height: 100,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aaba Shiti Haina',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 40),
                const Text(
                  'OTP Verification',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please Enter OTP sent to your Email.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                // OTP input fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (index) => Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _otpControllers[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Verify OTP button
                SizedBox(
                  width: 320,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final otp = _otpControllers
                                .map((c) => c.text)
                                .join()
                                .trim();
                            if (otp.length != 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Enter 6 digit OTP"),
                                ),
                              );
                              return;
                            }
                            if (args == null) return;
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
                            print('Payload: $payload');

                            try {
                              final response = await Dio().post(
                                "${ApiEndpoints.baseUrl}register/",
                                data: payload,
                              );
                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Registration successful!"),
                                  ),
                                );
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Error: ${response.data['error'] ?? 'Unknown error'}",
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Request failed: $e")),
                              );
                            }
                            setState(() => isLoading = false);
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify OTP',
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
