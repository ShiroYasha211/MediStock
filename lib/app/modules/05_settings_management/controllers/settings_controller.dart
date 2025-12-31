import 'package:get/get.dart';
import 'package:medistock/app/core/services/backup_service.dart'; // تأكد من صحة المسار
import 'package:medistock/app/core/services/theme_service.dart';
import 'package:medistock/app/core/services/report_settings_service.dart';
import 'package:medistock/app/data/local/models/report_settings_model.dart';

class SettingsController extends GetxController {
  final ThemeService _themeService = ThemeService();
  final BackupService _backupService =
      BackupService(); // إنشاء كائن من خدمة النسخ
  final ReportSettingsService _reportSettingsService = ReportSettingsService();

  // --- إعدادات التقارير ---
  late Rx<ReportSettingsModel> reportSettings;

  @override
  void onInit() {
    super.onInit();
    try {
      final settings = _reportSettingsService.loadSettings();
      reportSettings = settings.obs;
    } catch (e) {
      reportSettings = ReportSettingsModel.defaults().obs;
    }
  }

  void saveReportSettings() {
    _reportSettingsService.saveSettings(reportSettings.value);
    update(); // لتحديث الواجهة إذا لزم الأمر
  }

  void updateLogo(String path) {
    reportSettings.update((val) {
      val?.logoPath = path;
    });
    saveReportSettings();
  }

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
