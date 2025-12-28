import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme
          .colorScheme
          .surface, // استخدام surface بدلاً من background للنسخ الأحدث
      body: ListView(
        padding: const EdgeInsets.all(32.0),
        children: [
          Text('الإعدادات العامة', style: theme.textTheme.headlineMedium),
          const Divider(height: 30),

          // --- ✅ قسم إعدادات المظهر ---
          _buildThemeSettingsCard(theme, controller),

          const SizedBox(height: 20),

          // --- ✅ قسم النسخ الاحتياطي ---
          _buildBackupSettingsCard(theme, controller),
        ],
      ),
    );
  }

  Widget _buildThemeSettingsCard(
    ThemeData theme,
    SettingsController controller,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المظهر', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('الوضع الداكن'),
              subtitle: const Text('قم بالتبديل بين الوضع الفاتح والداكن'),
              trailing: Switch(
                value: Get.isDarkMode,
                onChanged: (value) {
                  controller.switchTheme();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- دالة واجهة النسخ الاحتياطي الجديدة ---
  Widget _buildBackupSettingsCard(
    ThemeData theme,
    SettingsController controller,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'النسخ الاحتياطي والاستعادة',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'يمكنك حفظ نسخة من بياناتك لاستعادتها لاحقاً في حالة حدوث أي مشكلة.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // زر النسخ الاحتياطي
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.download)),
              title: const Text('إنشاء نسخة احتياطية'),
              subtitle: const Text('حفظ قاعدة البيانات في ملف خارجي'),
              onTap: () async {
                await controller.createBackup();
              },
            ),
            const Divider(),

            // زر الاستعادة
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.upload)),
              title: const Text('استعادة نسخة احتياطية'),
              subtitle: const Text('استرجاع البيانات من ملف سابق'),
              onTap: () async {
                // إضافة تأكيد قبل الاستعادة لأنها ستحذف البيانات الحالية
                Get.defaultDialog(
                  title: 'تأكيد الاستعادة',
                  middleText:
                      'استعادة النسخة الاحتياطية سيقوم بحذف جميع البيانات الحالية واستبدالها بالنسخة المختارة. هل أنت متأكد؟',
                  textConfirm: 'نعم، استعد',
                  textCancel: 'إلغاء',
                  confirmTextColor: Colors.white,
                  onConfirm: () async {
                    Get.back(); // إغلاق الديالوج
                    await controller.restoreBackup();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
