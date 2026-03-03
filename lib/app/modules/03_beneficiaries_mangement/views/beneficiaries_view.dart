import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medistock/app/data/local/models/beneficiary_model.dart';
import 'package:medistock/app/data/local/models/disbursement_order_model.dart';
import '../../02_orders_management/controllers/orders_controller.dart';
import '../controllers/beneficiaries_controller.dart';

class BeneficiariesView extends StatelessWidget {
  const BeneficiariesView({super.key});
  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: controller.beneficiariesList.length,
                itemBuilder: (context, index) {
                  final beneficiary = controller.beneficiariesList[index];
                  return _buildBeneficiaryCard(beneficiary, controller, theme);
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

  // --- ✅ جديد: ويدجت لعناصر التحكم العلوية بالهوية الجديدة ---
  Widget _buildHeaderControls(
    BeneficiariesController controller,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          // حقل البحث
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم، النوع، أو الرقم التعريفي...',
                  prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: controller.clearSearch,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ✅ جديد: ويدجت لبناء بطاقة المستفيد بالهوية الجديدة ---
  Widget _buildBeneficiaryCard(
    BeneficiaryModel beneficiary,
    BeneficiariesController controller,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.15),
          width: 1.5,
        ),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.primaryColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => controller.showBeneficiaryOrders(beneficiary),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 20.0,
            ),
            child: Row(
              children: [
                // أيقونة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: theme.primaryColor,
                    size: 28,
                  ),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (beneficiary.type != null &&
                              beneficiary.type!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(
                                  0.15,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                beneficiary.type!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (beneficiary.identifier != null &&
                              beneficiary.identifier!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tag,
                                    size: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    beneficiary.identifier!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
                    _buildActionButton(
                      icon: Icons.receipt_long_rounded,
                      color: Colors.teal.shade700,
                      tooltip: 'سجل الأوامر',
                      onPressed: () =>
                          controller.showBeneficiaryOrders(beneficiary),
                    ),
                    const SizedBox(width: 4),
                    _buildActionButton(
                      icon: Icons.print_rounded,
                      color: Colors.indigo.shade700,
                      tooltip: 'التقرير الإجمالي',
                      onPressed: () => controller.printReport(beneficiary),
                    ),
                    const SizedBox(width: 4),
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      color: Colors.blue.shade700,
                      tooltip: 'تعديل',
                      onPressed: () => controller.openAddEditDialog(
                        beneficiary: beneficiary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildActionButton(
                      icon: Icons.delete_outline_rounded,
                      color: Colors.red.shade700,
                      tooltip: 'حذف',
                      onPressed: () =>
                          controller.deleteBeneficiary(beneficiary.id!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        splashRadius: 20,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}

// --- ✅ جديد: نافذة عرض أوامر الصرف لمستفيد معين (فاتورة) ---
class BeneficiaryOrdersDialog extends StatelessWidget {
  final BeneficiaryModel beneficiary;
  final List<DisbursementOrderModel> orders;
  final OrdersController ordersController;

  const BeneficiaryOrdersDialog({
    required this.beneficiary,
    required this.orders,
    required this.ordersController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: theme.colorScheme.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(minWidth: 600, minHeight: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // --- Header ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'سجل أوامر الصرف',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 16, color: theme.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          beneficiary.name,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    color: Colors.grey.shade600,
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            // --- Content ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد أوامر صرف لهذا المستفيد',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final isUsed = order.status == 'مستخدم';
                          final statusColor = isUsed
                              ? Colors.grey.shade600
                              : Colors.green.shade600;

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUsed
                                    ? Colors.grey.shade200
                                    : theme.primaryColor.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () =>
                                    ordersController.showOrderDetails(order),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      // Status Icon
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isUsed
                                              ? Icons.check_circle_rounded
                                              : Icons.pending_actions_rounded,
                                          color: statusColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Order Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'أمر صرف رقم:',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  order.orderNumber,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(order.orderDate),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color: statusColor
                                                          .withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    order.status,
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Action Buttons
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              ordersController.printOrderReport(
                                                order,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.print_rounded,
                                              size: 18,
                                            ),
                                            label: const Text('طباعة السند'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  Colors.blueGrey.shade700,
                                              side: BorderSide(
                                                color: Colors.blueGrey.shade200,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.grey.shade400,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            // --- Footer ---
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('إغلاق السجل'),
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
