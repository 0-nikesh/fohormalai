class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // 🔄 Replace with your actual backend IP
  //static const String baseUrl = "http://192.168.1.76:8000/api/";
  // static const String baseUrl = "http://192.168.63.1:8000/api/";
  static const String baseUrl = "http://10.0.2.2:8000/api/";

  // ====================== Auth Routes ======================
  static const String requestOtp = "send-otp/";
  static const String verifyAndRegister = "register/";
  static const String login = "login/";
}
