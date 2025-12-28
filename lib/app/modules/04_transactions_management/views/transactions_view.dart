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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
  // --- ✅ تم التعديل: ويدجت لعناصر التحكم العلوية ---
  Widget _buildHeaderControls(TransactionsController controller, ThemeData theme) {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            children: [
        Row(
        children: [
        // حقل البحث
        Expanded(
        child: TextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(hintText: 'ابحث باسم الصنف المصروف...',
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
    const SizedBox(height: 16),
    // صف الفلاتر
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    // فلاتر الحالة
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text("فلترة حسب الحالة:"),
    const SizedBox(height: 4),
    Obx(
    () => SegmentedButton<String>(
    segments: const [
    ButtonSegment(value: 'الكل', label: Text('الكل')),
    ButtonSegment(value: 'مرتجع', label: Text('المرتجعات')),
    ButtonSegment(value: 'غير مرتجع', label: Text('غير المرتجعات')),
    ],
    selected: {controller.activeStatusFilter.value},
    onSelectionChanged: (newSelection) {
    controller.changeStatusFilter(newSelection.first);
    },
    ),
    ),
    ],
    ),
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text("فلترة حسب التاريخ:"),
    const SizedBox(height: 4), Obx(
    () => SegmentedButton<String>(
    segments:const [
    ButtonSegment(value: 'الكل', label: Text('الكل')),
    ButtonSegment(value: 'اليوم', label: Text('اليوم')),ButtonSegment(value: 'آخر 7 أيام', label: Text('آخر 7 أيام')),
    ButtonSegment(value: 'هذا الشهر', label:Text('هذا الشهر')),
    ],
    selected: {controller.activeDateFilter.value},
    onSelectionChanged: (newSelection) {
    controller.changeDateFilter(newSelection.first);
    },
    ),
    ),
    ],
    ),
    ],
    ),
    ],
    ),
    );
    }

  Widget _buildTransactionCard
  (TransactionModel transaction, TransactionsController controller, ThemeData theme) {
    final itemName = controller.getItemNameById(transaction.itemId);
    final orderNumber = controller.getOrderNumberById(transaction.orderId);
    final returnStatus = controller.getReturnStatusForTransaction(transaction);
    // تحديد اللون بناءً على الحال
    Color? cardColor;
    Color borderColor = theme.dividerColor;
    if (returnStatus == 'مرتجع بالكامل') {
      cardColor = Colors.grey.shade200;
      borderColor = Colors.grey.shade500;
    } else if (returnStatus == 'مرتجع جزئياً') {
      cardColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade400;
    }
    return InkWell(
        onTap: () => controller.showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Card(
            color: cardColor,
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: borderColor, width: 1.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Expanded(
                  child: Text(
                  itemName,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
            ), // عرض حالة الإرجاع
                    if (returnStatus != 'لم يرجع')
                      Chip(
                        label: Text(
                            returnStatus, style: const TextStyle(fontSize: 11)),
                        backgroundColor: borderColor,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                  ],
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'الكمية المصروفة:',
                  value: transaction.quantityDisbursed.toString(),
                  theme: theme,
                ),
                const SizedBox(height: 8), _buildDetailRow(
              icon: Icons.confirmation_number_outlined,
              label: 'بناءً على أمر الصرف رقم:',
              value: orderNumber,
              theme: theme,
            ),
                const SizedBox(height: 8),
                _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                  label: 'تاريخ الصرف:',
                  value: DateFormat('yyyy-MM-dd, hh:mm a')
                      .format(transaction.transactionDate),
                  theme: theme,
                ),
                if (transaction.notes != null && transaction.notes!.isNotEmpty)
            ...[
            const SizedBox(height: 8),
        _buildDetailRow(icon: Icons.notes_outlined,
          label: 'ملاحظات:',
          value: transaction.notes!,
          theme: theme,
        ),
            ]
                    ],
                ),
            ),
        ),);
  }
  Widget _buildDetailRow({required IconData icon, required String label, required String value, required ThemeData theme}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(width: 4),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }
}