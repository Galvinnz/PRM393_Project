// Các hàm validator dùng cho TextFormField (Module 7 - Forms & Validation)
// Quy ước: hợp lệ -> trả về null, không hợp lệ -> trả về câu thông báo lỗi

// Họ tên: không rỗng, ít nhất 2 ký tự
String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Họ tên không được để trống';
  }
  if (value.trim().length < 2) {
    return 'Họ tên phải có ít nhất 2 ký tự';
  }
  return null;
}

// Email: không rỗng, phải có '@' và '.'
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email không được để trống';
  }
  final email = value.trim();
  if (!email.contains('@') || !email.contains('.')) {
    return 'Email không hợp lệ';
  }
  return null;
}

// Mật khẩu: không rỗng, ít nhất 6 ký tự
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Mật khẩu không được để trống';
  }
  if (value.length < 6) {
    return 'Mật khẩu phải có ít nhất 6 ký tự';
  }
  return null;
}

// Số điện thoại: 10 chữ số, bắt đầu bằng 0
String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Số điện thoại không được để trống';
  }
  if (!RegExp(r'^0[0-9]{9}$').hasMatch(value.trim())) {
    return 'Số điện thoại phải gồm 10 số và bắt đầu bằng 0';
  }
  return null;
}

// Địa chỉ giao hàng: không rỗng, ít nhất 5 ký tự
String? validateAddress(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Địa chỉ không được để trống';
  }
  if (value.trim().length < 5) {
    return 'Địa chỉ quá ngắn';
  }
  return null;
}
