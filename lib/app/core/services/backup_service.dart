import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:medistock/app/data/local/db/database_handler.dart';

class BackupService {
  /// يقوم بإنشاء نسخة احتياطية من قاعدة البيانات
  Future<bool> createBackup() async {
    try {
      // 1. الحصول على مسار قاعدة البيانات الحالية
      final dbFolder = await getDatabasesPath();
      final dbPath = join(dbFolder, 'medistock.db');
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        Get.snackbar(
          'خطأ',
          'لم يتم العثور على قاعدة البيانات',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // 2. السماح للمستخدم باختيار مكان الحفظ واسم الملف
      // نستخدم التوقيت الحالي كاسم افتراضي
      final String fileName =
          'medistock_backup_${DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first}.db';

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ النسخة الاحتياطية',
        fileName: fileName,
        allowedExtensions: ['db'],
        type: FileType.custom,
      );

      if (outputFile == null) {
        // المستخدم ألغى العملية
        return false;
      }

      // 3. نسخ الملف إلى المكان المحدد
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
  /// يقوم باستعادة نسخة احتياطية
  Future<bool> restoreBackup() async {
    try {
      // 1. اختيار ملف النسخة الاحتياطية
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'اختر ملف النسخة الاحتياطية',
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final String backupPath = result.files.single.path!;

      // 2. الحصول على مسار قاعدة البيانات الحالية
      final dbFolder = await getDatabasesPath();
      final dbPath = join(dbFolder, 'medistock.db');

      // 3. ✅ إغلاق قاعدة البيانات الحالية لفك القفل عنها
      await DatabaseHandler.instance.closeDatabase();

      // 4. استبدال الملف الحالي بالنسخة الاحتياطية
      await File(backupPath).copy(dbPath);

      Get.defaultDialog(
        title: 'تمت الاستعادة',
        middleText:
            'تم استعادة النسخة الاحتياطية بنجاح. يرجى إعادة تشغيل التطبيق لتطبيق التغييرات.',
        textConfirm: 'حسناً',
        onConfirm: () {
          Get.back(); // إغلاق الحوار
          // يمكن هنا إضافة كود لإعادة تشغيل التطبيق أو الخروج منه إذا لزم الأمر
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
