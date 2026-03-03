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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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

  // --- ✅ جديد: ويدجت لعناصر التحكم العلوية بالهوية الجديدة ---
  Widget _buildHeaderControls(OrdersController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
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
                      hintText: 'ابحث برقم الأمر أو الجهة الصادرة...',
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
          const SizedBox(height: 16),
          // فلاتر الحالة
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => SegmentedButton<String>(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((
                    Set<MaterialState> states,
                  ) {
                    if (states.contains(MaterialState.selected)) {
                      return theme.primaryColor.withOpacity(0.9);
                    }
                    return theme.colorScheme.surface;
                  }),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>((
                    Set<MaterialState> states,
                  ) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return theme.textTheme.bodyLarge!.color!;
                  }),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                segments: const [
                  ButtonSegment(value: 'الكل', label: Text('الكل')),
                  ButtonSegment(
                    value: 'غير مستخدم',
                    label: Text('غير مستخدم'),
                    icon: Icon(Icons.radio_button_unchecked, size: 18),
                  ),
                  ButtonSegment(
                    value: 'مستخدم',
                    label: Text('مستخدم'),
                    icon: Icon(Icons.check_circle_outline, size: 18),
                  ),
                ],
                selected: {controller.activeFilter.value},
                onSelectionChanged: (newSelection) {
                  controller.changeFilter(newSelection.first);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ✅ جديد: ويدجت لبناء بطاقة أمر الصرف بالهوية الجديدة ---
  Widget _buildOrderCard(
    DisbursementOrderModel order,
    OrdersController controller,
    ThemeData theme,
  ) {
    final isUsed = order.status == 'مستخدم';
    final beneficiaryName = controller.getBeneficiaryNameById(
      order.beneficiaryId,
    );

    final Color statusColor = isUsed
        ? Colors.grey.shade600
        : Colors.green.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(
            isUsed ? 0.3 : 0.6,
          ),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => controller.showOrderDetails(order),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- الصف العلوي: الرقم، الحالة، الأزرار ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // رقم الأمر والحالة
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 18,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  order.orderNumber,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusColor.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUsed
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 14,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  order.status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // أزرار الإجراءات
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          icon: Icons.print_rounded,
                          color: Colors.blueGrey,
                          tooltip: 'طباعة السند',
                          onPressed: () => controller.printOrderReport(order),
                        ),
                        const SizedBox(width: 4),
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          color: Colors.blue.shade700,
                          tooltip: 'تعديل',
                          onPressed: () =>
                              controller.openAddEditDialog(orderToEdit: order),
                        ),
                        const SizedBox(width: 4),
                        _buildActionButton(
                          icon: Icons.delete_outline_rounded,
                          color: Colors.red.shade700,
                          tooltip: 'حذف',
                          onPressed: () => controller.deleteOrder(order.id!),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Colors.black12),
                ),
                // --- التفاصيل السفلية ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العمود الأول: التواريخ والجهات
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            icon: Icons.domain,
                            label: 'الجهة:',
                            value: order.issuingEntity ?? 'غير محدد',
                            theme: theme,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: 'التاريخ:',
                            value: DateFormat(
                              'yyyy-MM-dd',
                            ).format(order.orderDate),
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    // العمود الثاني: المستفيد والملاحظات
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            icon: Icons.person_pin,
                            label: 'المستفيد:',
                            value: beneficiaryName,
                            theme: theme,
                            valueColor: theme.primaryColor,
                            isBoldValue: true,
                          ),
                          if (order.notes != null &&
                              order.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              icon: Icons.notes,
                              label: 'ملاحظة:',
                              value: order.notes!,
                              theme: theme,
                              maxLines: 2,
                            ),
                          ],
                        ],
                      ),
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

  // --- دوال مساعدة للبطاقة ---
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    Color? valueColor,
    bool isBoldValue = false,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}
