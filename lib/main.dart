import 'package:flutter/material.dart';
import 'package:fohormalai/features/auth/login_view.dart';
import 'package:fohormalai/features/auth/opt_view.dart';
import 'package:fohormalai/features/auth/register_view.dart';
import 'package:fohormalai/features/home/dashboard.dart';

void main() {
  runApp(const FohorMalaiApp());
}

class FohorMalaiApp extends StatelessWidget {
  const FohorMalaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FohorMalai',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/register',
      routes: {
        // '/': (context) => HomePage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/otp': (context) => const OtpView(),
        "/dashboard": (context) => const Dashboard(),
      },
    );
  }
}
