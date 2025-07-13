class OtpVerification {
  final String email;
  final String otpCode;
  final DateTime createdAt;

  OtpVerification({
    required this.email,
    required this.otpCode,
    required this.createdAt,
  });

  factory OtpVerification.fromJson(Map<String, dynamic> json) {
    return OtpVerification(
      email: json['email'] ?? '',
      otpCode: json['otp_code'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp_code': otpCode,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
