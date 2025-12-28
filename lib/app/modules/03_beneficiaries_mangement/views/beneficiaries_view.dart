import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medistock/app/data/local/models/beneficiary_model.dart';
import '../controllers/beneficiaries_controller.dart';
class BeneficiariesView extends StatelessWidget {
  const BeneficiariesView({super.key});
  @override
  Widget build(
  BuildContext context) {
    final controller = Get.put(BeneficiariesController());
    final theme = Theme.of(context);
    return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Column(
            children: [
            _buildHeaderControls(controller, theme),
        Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.beneficiariesList.isEmpty) {
                return Center(
                    child: Text(
                      controller.searchController.text.isEmpty
                          ? 'لا يوجد مستفيدون مدخلون حاليًا.'
                          : 'لا يوجد مستفيدون يطابقون بحثك.',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                );
              }
              // --- ✅ جديد: عرض البطاقات ---
              return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20,
                      vertical: 10),
                  itemCount: controller.beneficiariesList.length,
                  itemBuilder: (context, index) {
                    final beneficiary = controller.beneficiariesList[index];
                    return _buildBeneficiaryCard(beneficiary, controller,
                        theme);
                  },
              );
            }),
        ),
            ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => controller.openAddEditDialog(),
            label: const Text('إضافة مستفيد'),
            icon: const Icon(Icons.add),
        ),
    );
  }

  // --- ✅ جديد: ويدجت لعناصر التحكم العلوية ---
  Widget _buildHeaderControls(BeneficiariesController controller,
      ThemeData theme) {
    return Padding(padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // حقل البحث
            Expanded(
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم، النوع، أو الرقم التعريفي...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clearSearch,
                  ),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  // --- ✅ جديد: ويدجت لبناء بطاقة المستفيد ---
  Widget _buildBeneficiaryCard(BeneficiaryModel beneficiary,
      BeneficiariesController controller, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            // أيقونة
            CircleAvatar(
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              child: Icon(
                  Icons.person_pin_circle_outlined, color: theme.primaryColor),
            ),
            const SizedBox(width: 16),
            // التفاصيل
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beneficiary.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (beneficiary.type != null &&
                          beneficiary.type!.isNotEmpty)
                        Chip(
                          label: Text(beneficiary.type!, style: const TextStyle(
                              fontSize: 12)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      const SizedBox(width: 8),
                      if (beneficiary.identifier != null &&
                          beneficiary.identifier!.isNotEmpty)
                        Text(
                          '#${beneficiary.identifier}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // أزرار الإجراءات
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700),
                  onPressed: () =>
                      controller.openAddEditDialog(beneficiary: beneficiary),
                  tooltip: 'تعديل',
                  splashRadius: 20,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  onPressed: () =>
                      controller.deleteBeneficiary(beneficiary.id!),
                  tooltip: 'حذف',
                  splashRadius: 20,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}