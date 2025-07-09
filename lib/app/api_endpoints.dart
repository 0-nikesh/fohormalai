class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Base URL
  //static const String baseUrl = "http://10.0.2.2:8000";
  static const String baseUrl = "http://192.168.1.181:8000";
  // Auth endpoints
  static const String sendOtp = "/api/send-otp/";
  static const String register = "/api/register/";
  static const String login = "/api/login/";

  // Marketplace endpoints
  static const String createMarketplacePost = "/api/marketplace-post/";
  static const String getMarketplacePosts = "/api/get-marketplace-post/";

  // Collection endpoints
  static const String createCollectionRequest = "/api/collection-request/";
  static const String getCollectionRequests = "/api/get-collection-request/";

  // Pickup Schedule endpoints
  static const String createPickupSchedule = "/api/pickup-schedule/";
  static const String getNearbyPickupSchedules =
      "/api/nearby-pickup-schedules/";

  // Profile endpoints
  static const String updateProfile = "/api/update-profile/";
  static const String changePassword = "/api/change-password/";

  // Map endpoints
  static const String getActivePickups = "/api/active-pickups/";
}
