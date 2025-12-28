import 'package:flutter/material.dart';

class ThemeShowcaseView extends StatelessWidget {
  const ThemeShowcaseView({super.key});@override
  Widget build(BuildContext context) {
    // للوصول السريع إلى الثيم والنصوص
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('معرض مكونات النظام'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. قسم الألوان ---
            _buildSectionTitle('1. لوحة الألوان (Color Palette)', context),
            _buildColorPalette(theme),
            const SizedBox(height: 30),

            // --- 2. قسم الخطوط ---
            _buildSectionTitle('2. أنماط النصوص (Typography)', context),
            Text('Display Large', style: textTheme.displayLarge),
            Text('Headline Large', style: textTheme.headlineLarge),
            Text('Headline Medium', style: textTheme.headlineMedium),
            Text('Headline Small', style: textTheme.headlineSmall),
            const Divider(height: 20),
            Text('Title Large: عنوان قسم رئيسي', style: textTheme.titleLarge),
            Text('Title Medium: عنوان قسم فرعي', style: textTheme.titleMedium),
            Text('Title Small: عنوان عنصر', style: textTheme.titleSmall),
            const Divider(height: 20),
            Text(
              'Body Large: هذا نص أساسي يمثل المحتوى الرئيسي في الفقرات. يقرأه المستخدم لمعرفة التفاصيل.',
              style: textTheme.bodyLarge,
            ),
            Text(
              'Body Medium: هذا نص ثانوي يستخدم للملاحظات أو المعلومات الإضافية الأقل أهمية.',
              style: textTheme.bodyMedium,
            ),
            Text('Label Large: نص على زر', style: textTheme.labelLarge),
            const SizedBox(height: 30),

            // --- 3. قسم الأزرار ---
            _buildSectionTitle('3. الأزرار (Buttons)', context),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('زر أساسي (حفظ)'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('زر ثانوي (إلغاء)'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('زر نصي'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- 4. قسم حقول الإدخال ---
            _buildSectionTitle('4. حقول الإدخال (Text Fields)', context),
            const TextField(
              decoration: InputDecoration(
                labelText: 'حقل عادي',
                hintText: 'ادخل اسم الصنف...',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'حقل بخطأ',
                hintText: 'ادخل الكمية...',
                errorText: 'هذا الحقل مطلوب.',
              ),
            ),
            const SizedBox(height: 30),

            // --- 5. قسم الكروت ---
            _buildSectionTitle('5. الكروت (Cards)', context),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('عنوان داخل كرت', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'هذا محتوى يوضع داخل كرت لعرض معلومات صنف معين أو ملخص تقرير.',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- 6. قسم التنبيهات ---
            _buildSectionTitle('6. عناصر التنبيه (Alert Elements)', context),
            _buildAlertCard(
              context: context,
              title: 'تنبيه: قرب نفاد الكمية',
              content: 'صنف "Panadol Extra" وصل إلى الحد الأدنى للكمية.',
              color: theme.colorScheme.secondary, // Green for positive/info
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              context: context,
              title: 'خطر: صنف منتهي الصلاحية',
              content: 'صنف "Amoxicillin 500mg" قد انتهت صلاحيته.',
              color: theme.colorScheme.error, // Red for errors
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت مساعد لعرض عنوان كل قسم
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  // ويدجت مساعد لعرض لوحة الألوان
  Widget _buildColorPalette(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildColorChip('Primary', theme.colorScheme.primary),
        _buildColorChip('Secondary', theme.colorScheme.secondary),
        _buildColorChip('Error', theme.colorScheme.error),
        _buildColorChip('Warning', const Color(0xFFFFA000)), // From theme file
        _buildColorChip('Background', theme.colorScheme.background),
        _buildColorChip('Surface', theme.colorScheme.surface),
      ],
    );
  }

  // ويدجت مساعد لعرض شريحة لون
  Widget _buildColorChip(String name, Color color) {
    return Chip(
      label: Text(name),
      backgroundColor: color,
      labelStyle: TextStyle(
        color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      ),
      side: BorderSide(color: Colors.grey.shade300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // ويدجت مساعد لعرض كرت تنبيه
  Widget _buildAlertCard({
    required BuildContext context,
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
                  Text(content, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
