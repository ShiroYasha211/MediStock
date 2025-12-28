import 'package:get/get.dart';
import 'package:medistock/app/core/services/theme_service.dart';

class SettingsController extends GetxController {
  final ThemeService _themeService = ThemeService();// دالة لتبديل الثيم
  void switchTheme() {
    _themeService.switchTheme();
  }
}
