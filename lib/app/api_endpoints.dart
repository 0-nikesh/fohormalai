class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 🔄 Replace with your actual backend IP
  static const String baseUrl = "http://192.168.1.76:8000/api/";

  // ====================== Auth Routes ======================
  static const String requestOtp = "request-otp/";
  static const String verifyAndRegister = "verify-otp/";
  static const String login = "login/";
}
