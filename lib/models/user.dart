import '../utils/constants.dart';

// Người dùng: khách hàng hoặc chủ quán (admin)
class User {
  final int? id; // null khi chưa lưu vào database
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role; // 'customer' hoặc 'admin'

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.role = roleCustomer,
  });

  bool get isAdmin => role == roleAdmin;

  // Tạo bản sao với vài thông tin mới (vì các trường là final).
  // Email và vai trò không đổi.
  User copyWith({String? name, String? phone, String? password}) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      role: role,
    );
  }

  // Chuyển object -> Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
    };
  }

  // Chuyển Map (1 dòng trong SQLite) -> object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String,
      role: map['role'] as String,
    );
  }
}
