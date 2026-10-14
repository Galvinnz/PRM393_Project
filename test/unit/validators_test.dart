// UNIT TEST: kiểm tra các hàm validate form
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('Bỏ trống -> báo lỗi', () {
      expect(validateEmail(''), 'Email không được để trống');
    });
    test('Thiếu @ -> báo lỗi', () {
      expect(validateEmail('khachgmail.com'), 'Email không hợp lệ');
    });
    test('Email đúng -> null', () {
      expect(validateEmail('khach@gmail.com'), isNull);
    });
  });

  group('validatePassword', () {
    test('Dưới 6 ký tự -> báo lỗi', () {
      expect(validatePassword('123'), 'Mật khẩu phải có ít nhất 6 ký tự');
    });
    test('Đủ 6 ký tự -> null', () {
      expect(validatePassword('123456'), isNull);
    });
  });

  group('validatePhone', () {
    test('Không bắt đầu bằng 0 -> báo lỗi', () {
      expect(validatePhone('9123456789'), isNotNull);
    });
    test('Thiếu số -> báo lỗi', () {
      expect(validatePhone('091234'), isNotNull);
    });
    test('Đúng 10 số, bắt đầu bằng 0 -> null', () {
      expect(validatePhone('0912345678'), isNull);
    });
  });
}
