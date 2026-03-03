import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medistock/app/data/local/models/disbursement_order_model.dart';
import 'package:medistock/app/modules/02_orders_management/controllers/orders_controller.dart';

class OrderDetailsDialog extends StatelessWidget {
  final DisbursementOrderModel order;

  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final theme = Theme.of(context);
    final beneficiaryName = controller.getBeneficiaryNameById(
      order.beneficiaryId,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: theme.colorScheme.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.65,
        height: MediaQuery.of(context).size.height * 0.75,
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
                    Icons.receipt_long_rounded,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'تفاصيل أمر الصرف',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (order.status == 'مستخدم'
                                  ? Colors.green
                                  : Colors.orange)
                              .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            (order.status == 'مستخدم'
                                    ? Colors.green
                                    : Colors.orange)
                                .withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: order.status == 'مستخدم'
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Left Column: Text Details ---
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'معلومات الأمر الأساسية',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                Icons.tag,
                                'رقم الأمر:',
                                order.orderNumber,
                                theme,
                              ),
                              _buildDetailRow(
                                Icons.calendar_month,
                                'تاريخ الأمر:',
                                DateFormat(
                                  'yyyy-MM-dd',
                                ).format(order.orderDate),
                                theme,
                              ),
                              _buildDetailRow(
                                Icons.business,
                                'الجهة الصادرة:',
                                order.issuingEntity ?? 'غير محدد',
                                theme,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Divider(),
                              ),
                              Text(
                                'معلومات ذات صلة',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                Icons.person,
                                'المستفيد:',
                                beneficiaryName,
                                theme,
                                valueColor: theme.primaryColor,
                                isBold: true,
                              ),
                              _buildDetailRow(
                                Icons.access_time,
                                'تاريخ الإنشاء:',
                                DateFormat(
                                  'yyyy-MM-dd, hh:mm a',
                                ).format(order.createdAt),
                                theme,
                              ),
                              if (order.notes != null &&
                                  order.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.yellow.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.notes,
                                            size: 16,
                                            color: Colors.orange.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'ملاحظات:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(order.notes!),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // --- Right Column: Attached Image ---
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'الصورة المرفقة',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.02),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child:
                                    (order.imagePath != null &&
                                        order.imagePath!.isNotEmpty)
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
                                            Icons.image_not_supported_outlined,
                                            size: 64,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'لا توجد صورة مرفقة\nمع هذا الأمر',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
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
                  ],
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
                    child: const Text('إغلاق'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back(); // Close dialog first
                      controller.printOrderReport(order);
                    },
                    icon: const Icon(Icons.print_rounded),
                    label: const Text(
                      'طباعة سند صرف',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: theme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
