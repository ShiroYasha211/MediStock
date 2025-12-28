import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/items_controller.dart'; // enum لتحديد نوع القائمة التي نديرها

enum LookupType { units, itemForms }

class ManageLookupsDialog extends StatelessWidget {

  final LookupType type;

  const ManageLookupsDialog
      ({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ItemsController>();
    final theme = Theme.of(context);
    final title = type == LookupType.units
        ? 'إدارة الوحدات'
        : 'إدارة الأشكال الدوائية';
    final list = type == LookupType.units
        ? controller.unitsList
        : controller.itemFormsList;

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.3,
        height: MediaQuery
            .of(context)
            .size
            .height * 0.5,
        child: Column(
          children: [
            // حقل الإضافة
            TextField(
              controller: controller.lookupTextController,
              decoration: InputDecoration(
                labelText: 'إضافة عنصر جديد',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => controller.addLookupItem(type),
                ),
              ),
            ),
            const Divider(height: 20),
            // قائمة العناصر الحالية
            Expanded(
              child: Obx(
                    () =>
                    ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return ListTile(
                          title: Text(item),
                          trailing: IconButton(
                            icon: const Icon(
                                Icons.delete_outline, color: Colors.red),
                            onPressed: () =>
                                controller.deleteLookupItem(item, type),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}