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
      backgroundColor: theme.colorScheme.background,
      body: ListView(
        padding: const EdgeInsets.all(32.0),
        children: [
          Text('الإعدادات العامة', style: theme.textTheme.headlineMedium),
          const Divider(height: 30),

          // --- ✅ قسم إعدادات المظهر ---
          _buildThemeSettingsCard(theme, controller),
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
                value: Get.isDarkMode, // متغير جاهز من GetX لمعرفة الثيم الحالي
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
}
