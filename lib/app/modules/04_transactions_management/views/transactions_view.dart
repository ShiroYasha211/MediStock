import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medistock/app/data/local/models/transaction_model.dart';
import '../controllers/transactions_controller.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionsController());
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
              if (controller.transactionsList.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد عمليات صرف تطابق بحثك أو الفلتر الحالي.',
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
                itemCount: controller.transactionsList.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactionsList[index];
                  return _buildTransactionCard(transaction, controller, theme);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.openAddTransactionDialog();
        },
        label: const Text('إضافة عملية صرف'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // --- ✅ جديد: ويدجت لعناصر التحكم العلوية ---
  // --- ✅ تم التعديل: ويدجت لعناصر التحكم العلوية بالهوية الجديدة ---
  Widget _buildHeaderControls(
    TransactionsController controller,
    ThemeData theme,
  ) {
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
                      hintText: 'ابحث باسم الصنف المصروف...',
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
          // صف الفلاتر
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "الحالة:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'الكل', label: Text('الكل')),
                            ButtonSegment(value: 'مرتجع', label: Text('مرتجع')),
                            ButtonSegment(
                              value: 'غير مرتجع',
                              label: Text('غير مرتجع'),
                            ),
                          ],
                          selected: {controller.activeStatusFilter.value},
                          onSelectionChanged: (newSelection) {
                            controller.changeStatusFilter(newSelection.first);
                          },
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "التاريخ:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'الكل', label: Text('الكل')),
                            ButtonSegment(value: 'اليوم', label: Text('اليوم')),
                            ButtonSegment(
                              value: 'آخر 7 أيام',
                              label: Text('7 أيام'),
                            ),
                            ButtonSegment(
                              value: 'هذا الشهر',
                              label: Text('الشهر'),
                            ),
                          ],
                          selected: {controller.activeDateFilter.value},
                          onSelectionChanged: (newSelection) {
                            controller.changeDateFilter(newSelection.first);
                          },
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    TransactionModel transaction,
    TransactionsController controller,
    ThemeData theme,
  ) {
    final itemName = controller.getItemNameById(transaction.itemId);
    final orderNumber = controller.getOrderNumberById(transaction.orderId);
    final returnStatus = controller.getReturnStatusForTransaction(transaction);

    // Dynamic styling based on return status
    Color cardColor = theme.colorScheme.surface;
    Color borderColor = theme.primaryColor.withOpacity(0.15);
    Color iconColor = theme.primaryColor;
    IconData statusIcon = Icons.inventory_2_outlined;

    if (returnStatus == 'مرتجع بالكامل') {
      cardColor = Colors.grey.shade50;
      borderColor = Colors.grey.shade400;
      iconColor = Colors.grey.shade600;
      statusIcon = Icons.keyboard_return_rounded;
    } else if (returnStatus == 'مرتجع جزئياً') {
      cardColor = Colors.orange.shade50.withOpacity(0.5);
      borderColor = Colors.orange.shade300;
      iconColor = Colors.orange.shade700;
      statusIcon = Icons.settings_backup_restore_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => controller.showTransactionDetails(transaction),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(statusIcon, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.confirmation_number_outlined,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'أمر صرف رقم: $orderNumber',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (returnStatus != 'لم يرجع')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: borderColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          returnStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1),
                ),
                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.unfold_more_rounded,
                        label: 'الكمية المصروفة',
                        value: transaction.quantityDisbursed.toString(),
                        theme: theme,
                        isHighlight: true,
                        highlightColor: theme.primaryColor,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'تاريخ الصرف',
                        value: DateFormat(
                          'yyyy-MM-dd',
                        ).format(transaction.transactionDate),
                        theme: theme,
                      ),
                    ),
                  ],
                ),
                if (transaction.notes != null &&
                    transaction.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transaction.notes!,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    bool isHighlight = false,
    Color? highlightColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isHighlight ? highlightColor : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
