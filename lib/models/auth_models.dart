enum UserRole {
  supplier,
  forwarder,
  buyer,
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final String country;
  final String? gstin;
  final UserRole role;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    required this.country,
    this.gstin,
    required this.role,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    UserRole role;
    final roleStr = (json['role'] ?? json['user_type'] ?? '').toString().toLowerCase();
    switch (roleStr) {
      case 'supplier':
        role = UserRole.supplier;
        break;
      case 'forwarder':
        role = UserRole.forwarder;
        break;
      case 'buyer':
        role = UserRole.buyer;
        break;
      default:
        role = UserRole.supplier;
    }

    return User(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? '',
      companyName: json['company_name'] ?? json['company'],
      country: json['country'] ?? '',
      gstin: json['gstin'] ?? json['gst_in'],
      role: role,
      isVerified: json['is_verified'] ?? json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company_name': companyName,
      'country': country,
      'gstin': gstin,
      'role': role.name,
      'is_verified': isVerified,
    };
  }
}

