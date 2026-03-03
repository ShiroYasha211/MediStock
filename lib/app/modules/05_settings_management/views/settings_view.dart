import 'dart:ui';
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
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background Effect
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ),

          ListView(
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                'الإعدادات العامة',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // --- ✅ المظهر ---
              _buildGlassyCard(
                theme: theme,
                title: 'المظهر',
                icon: Icons.palette_outlined,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'الوضع الداكن',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('قم بالتبديل بين الوضع الفاتح والداكن'),
                  value: Get.isDarkMode,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (value) => controller.switchTheme(),
                ),
              ),
              const SizedBox(height: 16),

              // --- ✅ إعدادات التقارير ---
              _buildGlassyCard(
                theme: theme,
                title: 'إعدادات الطباعة والتقارير',
                icon: Icons.print_outlined,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    'تصميم الترويسة والتقارير',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('تخصيص الشعار، الترويسة، والتذييلات'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Get.to(() => const ReportSettingsView()),
                ),
              ),
              const SizedBox(height: 16),

              // --- ✅ النسخ الاحتياطي ---
              _buildGlassyCard(
                theme: theme,
                title: 'النسخ الاحتياطي والاستعادة',
                icon: Icons.storage_rounded,
                subtitle:
                    'احفظ بياناتك محلياً أو استعدها من ملف سابق للحفاظ على مأمونية السجلات.',
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.download_rounded,
                          color: Colors.green,
                        ),
                      ),
                      title: const Text(
                        'إنشاء نسخة احتياطية',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('حفظ قاعدة البيانات في ملف خارجي'),
                      onTap: () => controller.createBackup(),
                    ),
                    Divider(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.upload_rounded,
                          color: Colors.orange,
                        ),
                      ),
                      title: const Text(
                        'استعادة نسخة احتياطية',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'استرجاع البيانات من ملف سابق (سيحذف الحالي)',
                      ),
                      onTap: () {
                        Get.defaultDialog(
                          title: 'تأكيد الاستعادة',
                          titleStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          middleText:
                              'استعادة النسخة الاحتياطية سيقوم باستبدال جميع البيانات الحالية بالنسخة المختارة.\nهل أنت متأكد؟',
                          textConfirm: 'نعم، استعد',
                          textCancel: 'إلغاء',
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.orange,
                          cancelTextColor: theme.colorScheme.onSurface,
                          onConfirm: () async {
                            Get.back();
                            await controller.restoreBackup();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- ✅ معلومات المطور ---
              _buildDeveloperInfoCard(theme),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassyCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    String? subtitle,
    required Widget child,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperInfoCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.05),
            theme.colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.code_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تم التطوير بواسطة',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohammed Alhemyari',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildContactRow(
              theme,
              Icons.chat_bubble_outline_rounded,
              'تواصل عبر واتساب',
              '+967773468708',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(indent: 50, endIndent: 50),
            ),
            _buildContactRow(
              theme,
              Icons.email_outlined,
              'البريد الإلكتروني',
              'alhemyarimohammed211@gmail.com',
            ),
          ],
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Optional: Launch URL logic
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  SelectableText(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
