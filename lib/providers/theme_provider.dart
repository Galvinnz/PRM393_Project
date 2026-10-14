import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Chế độ sáng/tối, lưu bằng SharedPreferences (Module 9 - Demo 9.1)
class ThemeProvider extends ChangeNotifier {
  static const _key = 'is_dark_mode';

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Đọc lựa chọn đã lưu khi mở app
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners(); // đổi giao diện ngay
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
