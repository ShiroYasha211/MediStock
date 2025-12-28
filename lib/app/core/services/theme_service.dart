import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  /// تحميل الثيم من الذاكرة. يعيد `true` إذا كان الوضع الداكن هو المختار.
  bool _loadThemeFromBox() => _box.read(_key) ?? false; // الافتراضي هو الفاتح

  /// حفظ اختيار الثيم في الذاكرة.
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  /// الحصول على الثيم الحالي.
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  /// التبديل بين الوضع الفاتح والداكن.
  void switchTheme() {
    // --- ✅ الحل: الطريقة الأبسط والأكثر أماناً ---

    // 1. اقرأ الحالة الحالية مرة واحدة
    final isCurrentlyDark = Get.isDarkMode;

    // 2. اعكس الحالة
    if (isCurrentlyDark) {
      Get.changeThemeMode(ThemeMode.light);
      _saveThemeToBox(false);
    } else {
      Get.changeThemeMode(ThemeMode.dark);
      _saveThemeToBox(true);
    }
  }
}