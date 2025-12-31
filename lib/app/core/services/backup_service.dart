import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; // ✅ إضافة هذا الاستيراد
import 'package:medistock/app/data/local/db/database_handler.dart';

class BackupService {
  /// دالة مساعدة للحصول على مسار قاعدة البيانات الجديد
  Future<String> _getDbPath() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String dbFolder = join(appDocDir.path, 'MediStock_DB');
    return join(dbFolder, 'medistock.db');
  }

  /// يقوم بإنشاء نسخة احتياطية من قاعدة البيانات
  Future<bool> createBackup() async {
    try {
      // 1. استخدام المسار الجديد
      final dbPath = await _getDbPath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        Get.snackbar(
          'خطأ',
          'لم يتم العثور على قاعدة البيانات',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final String fileName =
          'medistock_backup_${DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first}.db';

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ النسخة الاحتياطية',
        fileName: fileName,
        allowedExtensions: ['db'],
        type: FileType.custom,
      );

      if (outputFile == null) {
        return false;
      }

      await dbFile.copy(outputFile);

      Get.snackbar(
        'نجاح',
        'تم إنشاء النسخة الاحتياطية بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إنشاء النسخة الاحتياطية: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Backup Error: $e');
      return false;
    }
  }

  /// يقوم باستعادة نسخة احتياطية
  Future<bool> restoreBackup() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'اختر ملف النسخة الاحتياطية',
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final String backupPath = result.files.single.path!;

      // 1. استخدام المسار الجديد
      final dbPath = await _getDbPath();

      // 2. إغلاق قاعدة البيانات
      await DatabaseHandler.instance.closeDatabase();

      // 3. استبدال الملف
      await File(backupPath).copy(dbPath);

      Get.defaultDialog(
        title: 'تمت الاستعادة',
        middleText:
            'تم استعادة النسخة الاحتياطية بنجاح. يرجى إعادة تشغيل التطبيق لتطبيق التغييرات.',
        textConfirm: 'حسناً',
        onConfirm: () {
          Get.back();
        },
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل استعادة النسخة الاحتياطية: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Restore Error: $e');
      return false;
    }
  }
}
