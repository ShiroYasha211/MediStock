import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medistock/app/data/local/models/transaction_model.dart';
import 'package:medistock/app/modules/04_transactions_management/controllers/transactions_controller.dart';

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.transparent, // For gradient container
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // --- Header ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'تفاصيل الفاتورة / عملية الصرف',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isFullyReturned) // حالة الارتجاع في الترويسة
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'مرتجع بالكامل',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
            ),
            // --- Body Content (Split Layout) ---
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عمود التفاصيل النصية
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'بيانات الصرف الأساسية',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            Icons.inventory_2_outlined,
                            'الصنف المصروف:',
                            item?.name ?? 'غير معروف',
                            theme,
                            valueColor: theme.primaryColor,
                          ),
                          _buildDetailRow(
                            Icons.unfold_more_rounded,
                            'الكمية المصروفة:',
                            '${transaction.quantityDisbursed}',
                            theme,
                          ),
                          if (returnedQty > 0)
                            _buildDetailRow(
                              Icons.keyboard_return_rounded,
                              'الكمية المرتجعة:',
                              '$returnedQty',
                              theme,
                              valueColor: theme.colorScheme.error,
                            ),
                          _buildDetailRow(
                            Icons.calendar_today_outlined,
                            'تاريخ الصرف:',
                            DateFormat(
                              'yyyy-MM-dd, hh:mm a',
                            ).format(transaction.transactionDate),
                            theme,
                          ),
                          if (transaction.notes != null &&
                              transaction.notes!.isNotEmpty)
                            _buildDetailRow(
                              Icons.notes_rounded,
                              'ملاحظات العملية:',
                              transaction.notes!,
                              theme,
                            ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Divider(),
                          ),
                          Text(
                            'بناءً على أمر الصرف التالي:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (order != null) ...[
                            _buildDetailRow(
                              Icons.confirmation_number_outlined,
                              'رقم الأمر:',
                              order.orderNumber,
                              theme,
                            ),
                            _buildDetailRow(
                              Icons.event_outlined,
                              'تاريخ الأمر:',
                              DateFormat('yyyy-MM-dd').format(order.orderDate),
                              theme,
                            ),
                            _buildDetailRow(
                              Icons.business_outlined,
                              'الجهة الصادرة:',
                              order.issuingEntity ?? 'غير محدد',
                              theme,
                            ),
                            _buildDetailRow(
                              Icons.person_outline,
                              'المستفيد:',
                              beneficiaryName,
                              theme,
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'بيانات أمر الصرف غير متاحة (قد يكون قد حُذف).',
                                style: TextStyle(color: Colors.orange.shade800),
                              ),
                            ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Divider(),
                          ),
                          Text(
                            'معلومات الصنف من المخزن:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (item != null) ...[
                            _buildDetailRow(
                              Icons.medication_outlined,
                              'الاسم العلمي:',
                              item.scientificName ?? 'لا يوجد',
                              theme,
                            ),
                            _buildDetailRow(
                              Icons.qr_code_2_outlined,
                              'كود الصنف:',
                              item.itemCode ?? 'لا يوجد',
                              theme,
                            ),
                            _buildDetailRow(
                              Icons.numbers_outlined,
                              'رقم التشغيلة:',
                              item.batchNumber ?? 'لا يوجد',
                              theme,
                            ),
                            _buildDetailRow(
                              Icons.date_range_outlined,
                              'تاريخ الانتهاء:',
                              DateFormat('yyyy-MM-dd').format(item.expiryDate),
                              theme,
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'بيانات الصنف غير متاحة (قد يكون قد حُذف من المستودع).',
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  // عمود الصورة المرفقة
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'صورة أمر الصرف المرفقة',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Center(
                                child:
                                    (order?.imagePath != null &&
                                        order!.imagePath!.isNotEmpty)
                                    ? InteractiveViewer(
                                        minScale: 0.5,
                                        maxScale: 4.0,
                                        child: Image.file(
                                          File(order.imagePath!),
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.hide_image_outlined,
                                            size: 64,
                                            color: Colors.grey.shade300,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'لا توجد صورة مرفقة لأمر الصرف هذا',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // --- Actions Footer ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (!isFullyReturned) // زر الإرجاع إن لم يكن مرتجع بالكامل
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.openReturnDialog(transaction);
                      },
                      icon: const Icon(Icons.undo),
                      label: const Text('إرجاع الصنف المعطى'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.errorContainer,
                        foregroundColor: theme.colorScheme.onErrorContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('إغلاق', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ويدجت مساعد لعرض التفاصيل ---
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          SizedBox(
            width: 140, // Fixed width for labels to align values
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
