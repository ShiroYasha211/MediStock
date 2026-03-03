import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medistock/app/data/local/models/disbursement_order_model.dart';
import '../controllers/orders_controller.dart';
import 'package:medistock/app/data/local/models/beneficiary_model.dart';
import 'dart:io';

class AddEditOrderDialog extends StatelessWidget {
  final DisbursementOrderModel? orderToEdit;

  const AddEditOrderDialog({super.key, this.orderToEdit});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final isEditMode = orderToEdit != null;

    // تهيئة الحقول في حالة التعديل
    if (isEditMode) {
      controller.setupTextFieldsForEdit(orderToEdit!);
    } else {
      controller.clearTextFields();
    }

    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: theme.colorScheme.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        constraints: const BoxConstraints(minWidth: 400, maxHeight: 800),
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    isEditMode
                        ? Icons.edit_note_rounded
                        : Icons.post_add_rounded,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditMode ? 'تعديل أمر صرف' : 'إضافة أمر صرف جديد',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
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
            // --- Form Content ---
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller.orderNumberController,
                              'رقم الأمر',
                              icon: Icons.confirmation_number_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDatePicker(
                              controller.orderDateController,
                              'تاريخ الأمر',
                              (date) {
                                controller.updateOrderDate(date!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller.issuingEntityController,
                        'الجهة الصادرة للأمر',
                        icon: Icons.business_outlined,
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'بيانات المستفيد',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (controller.beneficiariesList.isEmpty)
                                TextFormField(
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: 'المستفيد',
                                    prefixIcon: Icon(
                                      Icons.person_pin_circle_outlined,
                                    ),
                                    border: OutlineInputBorder(),
                                    hintText: 'لا يوجد مستفيدون',
                                  ),
                                )
                              else
                                DropdownButtonFormField<int>(
                                  decoration: const InputDecoration(
                                    labelText: 'اختر المستفيد',
                                    prefixIcon: Icon(
                                      Icons.person_pin_circle_outlined,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  value:
                                      controller.beneficiariesList.any(
                                        (b) =>
                                            b.id ==
                                            controller
                                                .selectedBeneficiaryId
                                                .value,
                                      )
                                      ? controller.selectedBeneficiaryId.value
                                      : null,
                                  items: controller.beneficiariesList.map((
                                    BeneficiaryModel beneficiary,
                                  ) {
                                    return DropdownMenuItem<int>(
                                      value: beneficiary.id,
                                      child: Text(beneficiary.name),
                                    );
                                  }).toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      controller.selectedBeneficiaryId.value =
                                          newValue;
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'الرجاء اختيار مستفيد';
                                    }
                                    return null;
                                  },
                                ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed:
                                      controller.openAddBeneficiaryDialog,
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 18,
                                  ),
                                  label: const Text('إضافة مستفيد جديد'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller.notesController,
                        'ملاحظات (اختياري)',
                        icon: Icons.notes_outlined,
                        isRequired: false,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'صورة الأمر المرفقة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (controller.selectedImagePath.value.isNotEmpty) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(controller.selectedImagePath.value),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                controller.selectedImagePath.value
                                    .split(Platform.pathSeparator)
                                    .last,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: const Text(
                                'تم الإرفاق بنجاح',
                                style: TextStyle(color: Colors.green),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    controller.selectedImagePath.value = '',
                                tooltip: 'حذف الصورة',
                              ),
                            ),
                          );
                        } else {
                          return OutlinedButton.icon(
                            onPressed: controller.pickOrderImage,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('إرفاق صورة أمر الصرف'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
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
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => controller.saveOrder(orderToEdit),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditMode ? 'حفظ التعديلات' : 'إضافة الأمر',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    bool isRequired = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(
    TextEditingController controller,
    String label,
    Function(DateTime?) onDatePicked,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_month),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2050),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          onDatePicked(pickedDate);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }
}
