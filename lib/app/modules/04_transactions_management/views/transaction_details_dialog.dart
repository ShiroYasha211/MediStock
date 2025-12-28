import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medistock/app/data/local/models/transaction_model.dart';
import 'package:medistock/app/modules/04_transactions_management/controllers/transactions_controller.dart';
import '../../../data/local/models/disbursement_order_model.dart';
import '../../../data/local/models/item_model.dart';

class TransactionDetailsDialog extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailsDialog({super.key, required this.transaction});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();
    final theme = Theme.of(context);
    final item = controller.getItemById(transaction.itemId);
    final order = controller.getOrderById(transaction.orderId);
    final beneficiaryName = order != null
        ? controller.getBeneficiaryNameById(order.beneficiaryId)
        : 'غير معروف';
    final returnStatus = controller.getReturnStatusForTransaction(transaction);
    final returnedQty = controller.getReturnedQuantity(transaction.id!);
    final isFullyReturned = returnStatus == 'مرتجع بالكامل';
    return AlertDialog(
      title: const Text('تفاصيل عملية الصرف'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.75,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.receipt_long), text: 'تفاصيل العملية'),
                  Tab(icon: Icon(Icons.medication), text: 'تفاصيل الصنف المصروف'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTransactionInfoTab(
                      theme,
                      item?.name ?? 'صنف محذوف',
                      order,
                      beneficiaryName,
                      returnedQty, // ✅ تمرير الكمية المرتجعة
                    ),
                    _buildItemInfoTab(theme, item, order?.imagePath),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isFullyReturned) // إذا كان مرتجع بالكامل
          const Chip(
            label: Text('مرتجع بالكامل'),
            backgroundColor: Colors.grey,
            labelStyle: TextStyle(color: Colors.white),
          )
        else // إذا لم يكن مرتجع بالكامل
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              controller.openReturnDialog(transaction);
            },
            icon: const Icon(Icons.undo),
            label: const Text('إرجاع الصنف'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            ),
          ),
        const Spacer(),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
  Widget _buildTransactionInfoTab(ThemeData theme, String itemName,
      DisbursementOrderModel? order, String beneficiaryName, int returnedQty) { // ✅ استقبال الكمية
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('الصنف المصروف:', itemName, theme, valueColor: theme.primaryColor),
          _buildDetailRow('الكمية المصروفة:', '${transaction.quantityDisbursed}', theme),
          // --- ✅ جديد: عرض الكمية المرتجعة ---
          if (returnedQty > 0)
            _buildDetailRow('الكمية المرتجعة:', '$returnedQty', theme, valueColor: theme.colorScheme.error),

          _buildDetailRow('تاريخ الصرف:', DateFormat('yyyy-MM-dd, hh:mm a').format(transaction.transactionDate), theme),
          if (transaction.notes != null && transaction.notes!.isNotEmpty)
            _buildDetailRow('ملاحظات العملية:', transaction.notes!, theme),
          const Divider(height: 30, thickness: 1),
          Text('بناءً على أمر الصرف التالي:', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          if (order != null) ...[
            _buildDetailRow('رقم الأمر:', order.orderNumber, theme),
            _buildDetailRow('تاريخ الأمر:', DateFormat('yyyy-MM-dd').format(order.orderDate), theme),
            _buildDetailRow('الجهة الصادرة:', order.issuingEntity ?? 'غير محدد', theme),
            _buildDetailRow('المستفيد:', beneficiaryName, theme),
          ] else
            const Text('بيانات أمر الصرف غير متاحة (قد يكون قد حُذف).'),
        ],
      ),
    );
  }
  Widget _buildItemInfoTab(ThemeData theme, ItemModel? item,
      String? orderImagePath) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: item != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('الاسم التجاري:', item.name, theme,
                    valueColor: theme.primaryColor),
                _buildDetailRow(
                    'الاسم العلمي:', item.scientificName ?? 'لا يوجد', theme),
                _buildDetailRow(
                    'كود الصنف:', item.itemCode ?? 'لا يوجد', theme),
                _buildDetailRow(
                    'رقم التشغيلة:', item.batchNumber ?? 'لا يوجد', theme),
                _buildDetailRow('تاريخ الإنتاج:',
                    item.productionDate != null ? DateFormat('yyyy-MM-dd')
                        .format(item.productionDate!) : 'لا يوجد', theme),
                _buildDetailRow('تاريخ الانتهاء:',
                    DateFormat('yyyy-MM-dd').format(item.expiryDate), theme),
              ],
            )
                : const Text('بيانات الصنف غير متاحة (قد يكون قد حُذف).'),
          ),
        ),
        const VerticalDivider(width: 1),
        // --- العمود الأيمن: صورة أمر الصرف ---
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('صورة أمر الصرف:', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: (orderImagePath != null &&
                          orderImagePath.isNotEmpty)
                          ? InteractiveViewer(child: Image.file(File(
                          orderImagePath), fit: BoxFit.contain))
                          : const Text('لا توجد صورة مرفقة لأمر الصرف هذا'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- ويدجت مساعد لعرض التفاصيل ---
  Widget _buildDetailRow(String label, String value, ThemeData theme,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(child: SelectableText(value, style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: valueColor))),
        ],
      ),
    );
  }
}