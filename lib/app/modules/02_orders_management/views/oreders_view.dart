import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/local/models/disbursement_order_model.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // --- ✅ جديد: شريط البحث والفلاتر ---
          _buildHeaderControls(controller, theme),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.ordersList.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد أوامر صرف تطابق بحثك أو الفلتر الحالي.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              // --- ✅ جديد: عرض البطاقات ---
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: controller.ordersList.length,
                itemBuilder: (context, index) {
                  final order = controller.ordersList[index];
                  return _buildOrderCard(order, controller, theme);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.openAddEditDialog(),
        label: const Text('إضافة أمر صرف'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // --- ✅ جديد: ويدجت لعناصر التحكم العلوية ---
  Widget _buildHeaderControls(OrdersController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // حقل البحث
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث برقم الأمر أو الجهة الصادرة...',
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
          const SizedBox(width: 20),
          // فلاتر الحالة
          Obx(
                () => SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'الكل', label: Text('الكل')),
                ButtonSegment(value: 'غير مستخدم', label: Text('غير مستخدم'), icon: Icon(Icons.radio_button_unchecked)),
                ButtonSegment(value: 'مستخدم', label: Text('مستخدم'), icon: Icon(Icons.check_circle_outline)),
              ],
              selected: {controller.activeFilter.value},
              onSelectionChanged: (newSelection) {
                controller.changeFilter(newSelection.first);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- ✅ جديد: ويدجت لبناء بطاقة أمر الصرف ---
  Widget _buildOrderCard(DisbursementOrderModel order, OrdersController controller, ThemeData theme) {
    final isUsed = order.status == 'مستخدم';
    final beneficiaryName = controller.getBeneficiaryNameById(order.beneficiaryId);

    return InkWell(
      onTap: () => controller.showOrderDetails(order),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isUsed ? Colors.grey.shade400 : theme.primaryColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- الصف العلوي: الرقم، الحالة، الأزرار ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text('رقم الأمر: ${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
                  Chip(
                    label: Text(order.status, style: TextStyle(color: isUsed ? Colors.black54 : Colors.white)),
                    backgroundColor: isUsed ? Colors.grey.shade300 : Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700),
                        onPressed: () => controller.openAddEditDialog(orderToEdit: order),
                        tooltip: 'تعديل',
                        splashRadius: 20,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                        onPressed: () => controller.deleteOrder(order.id!),
                        tooltip: 'حذف',
                        splashRadius: 20,
                      ),
                    ],
                  )
                ],
              ),
              const Divider(height: 24),
              // --- التفاصيل ---
              Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyLarge,
                  children: [
                    const TextSpan(text: 'بتاريخ: ', style: TextStyle(color: Colors.grey)),
                    TextSpan(text: DateFormat('yyyy-MM-dd').format(order.orderDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: '، الصادر من: ', style: TextStyle(color: Colors.grey)),
                    TextSpan(
                        text: order.issuingEntity ?? 'غير محدد', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyLarge,
                  children: [
                    const TextSpan(text: 'لصالح المستفيد: ', style: TextStyle(color: Colors.grey)),

                    TextSpan(text: beneficiaryName, style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                  ],
                ),
              ),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('ملاحظات: ${order.notes}', style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
