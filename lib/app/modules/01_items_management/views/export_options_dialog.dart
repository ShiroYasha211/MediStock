import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExportOptionsDialog extends StatelessWidget {
  final VoidCallback onPdfSelected;
  final VoidCallback onWordSelected;

  const ExportOptionsDialog({
    Key? key,
    required this.onPdfSelected,
    required this.onWordSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر نوع التقرير',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildOption(
              context,
              icon: Icons.picture_as_pdf,
              color: Colors.red,
              title: 'التقرير الافتراضي (PDF)',
              subtitle: 'تقرير النظام الاساسي',
              onTap: onPdfSelected,
            ),
            const SizedBox(height: 15),
            _buildOption(
              context,
              icon: Icons.description,
              color: Colors.blue,
              title: 'قالب مخصص (Word)',
              subtitle: 'استخدام قالب وورد خارجي',
              onTap: onWordSelected,
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Get.back(); // Close dialog
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
