import 'package:flutter/material.dart';
import 'package:fohormalai/features/notifications/notifications_view.dart';
import 'package:provider/provider.dart';
import 'package:fohormalai/features/auth/login_view.dart';
import 'package:fohormalai/features/auth/opt_view.dart';
import 'package:fohormalai/features/auth/register_view.dart';
import 'package:fohormalai/features/dashboard/dashboard_view.dart';
import 'package:fohormalai/features/schedule_pickup/schedule_pickup_view.dart';
import 'package:fohormalai/app/providers/auth_provider.dart';
import 'package:fohormalai/features/collection/add_collection_request.dart';
import 'package:fohormalai/features/marketplace/add_marketplace_post.dart';
import 'package:fohormalai/app/providers/notification_provider.dart';
import 'package:fohormalai/features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const FohorMalaiApp(),
    ),
  );
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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/otp': (context) => const OtpView(),
        '/dashboard_new': (context) => const DashboardPage(),
        '/schedule_pickup': (context) => const SchedulePickupPage(),
        // '/marketplace': (context) => const MarketplacePage(),
        // '/my_collections': (context) => const MyCollectionsPage(),
        // '/profile': (context) => const ProfilePage(),
        '/add_collection_request': (context) => const AddCollectionRequest(),
        '/add-marketplace-post': (context) => const AddMarketplacePost(),
        //'/add_marketplace_item': (context) => const AddMarketplaceItemPage(),
        '/notifications': (context) => const NotificationsView(),
        '/map': (context) => const DashboardPage(initialTabIndex: 1),
      },
    );
  }
}
