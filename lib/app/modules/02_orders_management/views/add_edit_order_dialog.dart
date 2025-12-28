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

    return AlertDialog(
      title: Text(isEditMode ? 'تعديل أمر صرف' : 'إضافة أمر صرف جديد'),
      content: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.4, // 40% من عرض الشاشة
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(controller.orderNumberController,
                    'رقم الأمر', icon: Icons.confirmation_number_outlined),
                const SizedBox(height: 16),
                _buildDatePicker(
                    controller.orderDateController, 'تاريخ الأمر', (date) {
                  controller.updateOrderDate(date!);
                }),
                const SizedBox(height: 16),
                _buildTextField(
                    controller.issuingEntityController,
                    'الجهة الصادرة للأمر'),
                const SizedBox(height: 16),
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.beneficiariesList.isEmpty)
                        TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'المستفيد',
                            prefixIcon: Icon(Icons.person_pin_circle_outlined),
                            border: OutlineInputBorder(),
                            hintText: 'لا يوجد مستفيدون',
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'المستفيد',
                            prefixIcon: Icon(Icons.person_pin_circle_outlined),
                            border: OutlineInputBorder(),
                          ),
                          value: controller.beneficiariesList.any((b) =>
                          b.id == controller.selectedBeneficiaryId.value)
                              ? controller.selectedBeneficiaryId.value
                              : null,
                          items: controller.beneficiariesList
                              .map((BeneficiaryModel beneficiary) {
                            return DropdownMenuItem<int>(
                              value: beneficiary.id,
                              child: Text(beneficiary.name),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              controller.selectedBeneficiaryId.value = newValue;
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'الرجاء اختيار مستفيد';
                            }
                            return null;
                          },
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: controller.openAddBeneficiaryDialog,
                          child: const Text('إضافة مستفيد جديد...'),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                _buildTextField(
                    controller.notesController, 'ملاحظات', isRequired: false),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.selectedImagePath.value.isNotEmpty) {
                    return ListTile(
                      leading: Image.file(File(controller.selectedImagePath
                          .value), width: 40, height: 40, fit: BoxFit.cover),
                      title: Text(controller.selectedImagePath.value
                          .split(Platform.pathSeparator)
                          .last),
                      subtitle: const Text('تم إرفاق صورة الأمر'),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () =>
                        controller.selectedImagePath.value = '',
                      ),
                    );
                  } else {
                    return ElevatedButton.icon(
                      onPressed: controller.pickOrderImage,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('إرفاق صورة الأمر'),
                    );
                  }
                }),

              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            controller.saveOrder(orderToEdit);
          }, child: Text(isEditMode ? 'حفظ التعديلات' : 'إضافة'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {IconData? icon, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String label,
      Function(DateTime?) onDatePicked) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_month),
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2050),);
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