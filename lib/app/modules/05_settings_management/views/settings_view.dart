import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import 'report_settings_view.dart';

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

          // --- ✅ قسم إعدادات التقارير (جديد) ---
          _buildReportSettingsCard(theme),

          const SizedBox(height: 20),

          const SizedBox(height: 20),

          // --- ✅ قسم النسخ الاحتياطي ---
          _buildBackupSettingsCard(theme, controller),

          const SizedBox(height: 20),

          // --- ✅ قسم المطور (جديد) ---
          _buildDeveloperInfoCard(theme),

          const SizedBox(height: 40),
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

  // --- دالة واجهة إعدادات التقارير ---
  Widget _buildReportSettingsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.print, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text('إعدادات الطباعة', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.description)),
              title: const Text('تصميم الترويسة والتقارير'),
              subtitle: const Text('تخصيص الشعار، الترويسة، والتذييلات'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.to(() => const ReportSettingsView());
              },
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

  // --- ✅ دالة واجهة معلومات المطور (جديد) ---
  Widget _buildDeveloperInfoCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.code_rounded,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تم التطوير بواسطة',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Mohammed Alhemyari',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 32),
              _buildContactRow(
                theme,
                Icons.chat,
                'تواصل عبر واتساب',
                '+967773468708',
              ),
              const SizedBox(height: 16),
              _buildContactRow(
                theme,
                Icons.email_outlined,
                'البريد الإلكتروني',
                'alhemyarimohammed211@gmail.com',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              SelectableText(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
