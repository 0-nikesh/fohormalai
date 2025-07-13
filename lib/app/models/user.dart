class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? location;
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final bool isAdmin;
  final String? registeredOn;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.location,
    this.latitude,
    this.longitude,
    this.isVerified = false,
    this.isAdmin = false,
    this.registeredOn,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      isVerified: json['is_verified'] ?? false,
      isAdmin: json['is_admin'] ?? false,
      registeredOn: json['registered_on'],
    );
  }

  get name => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'is_verified': isVerified,
      'is_admin': isAdmin,
      'registered_on': registeredOn,
    };
  }
}
