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
    final beneficiaryName =
    controller.getBeneficiaryNameById(order.beneficiaryId);

    return AlertDialog(
      title: const Text('تفاصيل أمر الصرف'),
      content: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.6,
        height: MediaQuery
            .of(context)
            .size
            .height * 0.7,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- العمود الأيسر: التفاصيل النصية ---
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('رقم الأمر:', order.orderNumber, theme),
                    _buildDetailRow('تاريخ الأمر:', DateFormat('yyyy-MM-dd')
                        .format(order.orderDate), theme),
                    _buildDetailRow(
                        'الجهة الصادرة:', order.issuingEntity ?? 'غير محدد',
                        theme), _buildDetailRow(
                        'المستفيد:', beneficiaryName, theme,
                        valueColor: theme.primaryColor),
                    _buildDetailRow('الحالة:', order.status, theme,
                        valueColor: order.status == 'مستخدم'
                            ? Colors.green
                            : Colors.orange),
                    _buildDetailRow('تاريخ الإنشاء:',
                        DateFormat('yyyy-MM-dd, hh:mm a').format(
                            order.createdAt), theme),
                    if (order.notes != null && order.notes!.isNotEmpty)
                      _buildDetailRow('ملاحظات:', order.notes!, theme),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // --- العمود الأيمن: الصورة المرفقة ---
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الصورة المرفقة:', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: (order.imagePath != null && order.imagePath!
                            .isNotEmpty)
                            ? InteractiveViewer( // لجعل الصورة قابلة للتكبير والتحريك
                          child: Image.file(
                            File(order.imagePath!),
                            fit: BoxFit.contain,
                          ),
                        )
                            : const Text('لا توجد صورة مرفقة'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Get.back(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text.rich(
        TextSpan(
          style: theme.textTheme.bodyLarge,
          children: [
            TextSpan(text: '$label ',
                style: const TextStyle(color: Colors.grey)),
            TextSpan(
                text: value,
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: valueColor ?? theme.textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }
}