import 'package:get/get.dart';
import 'package:medistock/app/core/services/backup_service.dart'; // تأكد من صحة المسار
import 'package:medistock/app/core/services/theme_service.dart';

class SettingsController extends GetxController {
  final ThemeService _themeService = ThemeService();
  final BackupService _backupService =
      BackupService(); // إنشاء كائن من خدمة النسخ

  // --- إدارة الثيم ---
  void switchTheme() {
    _themeService.switchTheme();
  }

  // --- النسخ الاحتياطي والاستعادة ---

  /// دالة لإنشاء نسخة احتياطية
  Future<void> createBackup() async {
    // يمكن هنا إضافة مؤشر تحميل (Loading) إذا أردت
    // Get.showOverlay(...)

    await _backupService.createBackup();

    // إخفاء مؤشر التحميل
  }

  /// دالة لاستعادة نسخة احتياطية
  Future<void> restoreBackup() async {
    await _backupService.restoreBackup();
  }
}
