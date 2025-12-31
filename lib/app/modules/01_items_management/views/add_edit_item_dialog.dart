import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/local/models/item_model.dart';
import '../controllers/items_controller.dart';
import 'manage_lookups_dialog.dart';

class AddEditItemDialog extends StatelessWidget {
  final ItemModel? itemToEdit;

  const AddEditItemDialog({super.key, this.itemToEdit});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ItemsController>();
    final theme = Theme.of(context);
    final isEditMode = itemToEdit != null;

    // استدعاء دوال التهيئة في بداية الـ build
    if (isEditMode) {
      controller.setupTextFieldsForEdit(itemToEdit!);
    } else {
      controller.clearTextFields();
    }

    return AlertDialog(
      // --- 1. تكبير حجم الحوار وتخصيص الشكل ---
      scrollable: true,
      title: Row(
        children: [
          Icon(
            isEditMode ? Icons.edit_note : Icons.add_box_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Text(isEditMode ? 'تعديل بيانات صنف' : 'إضافة صنف جديد'),
        ],
      ),
      // استخدام SizedBox لتحديد عرض الحوار
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6, // 60% من عرض الشاشة
        child: Form(
          key: controller.formKey,
          child: _buildFormContent(controller, theme),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        ElevatedButton.icon(
          onPressed: () {
            controller.saveItem(itemToEdit);
            Get.back();
          },
          icon: const Icon(Icons.save),
          label: Text(isEditMode ? 'حفظ التعديلات' : 'إضافة'),
        ),
      ],
    );
  }

  Widget _buildFormContent(ItemsController controller, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // قسم الصورة والأسماء
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 3. إضافة منطقة الصورة ---
            _buildImagePicker(controller, theme),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _buildTextField(
                    controller.nameController,
                    'الاسم التجاري',
                    Icons.business_center_outlined,
                  ),
                  const SizedBox(height: 16),
                  // --- 4. إضافة حقل الاسم العلمي ---
                  _buildTextField(
                    controller.scientificNameController,
                    'الاسم العلمي (اختياري)',
                    Icons.science_outlined,
                    isRequired: false,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 32),
        // قسم التفاصيل (الكود، التشغيلة، الوحدة)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller.itemCodeController,
                'كود الصنف',
                Icons.qr_code_2,
                isRequired: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller.batchNumberController,
                'رقم التشغيلة',
                Icons.tag,
                isRequired: false,
              ),
            ),
            const SizedBox(width: 16),
            // --- 5. إضافة القائمة المنسدلة للوحدات ---
            Expanded(child: _buildUnitsDropdown(controller, theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildItemFormsDropdown(controller, theme)),
          ],
        ),
        const Divider(height: 32),
        // قسم الكمية والتواريخ
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller.quantityController,
                'الكمية',
                Icons.onetwothree,
                isNumber: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller.alertLimitController,
                'الحد الأدنى للتنبيه',
                Icons.warning_amber_rounded,
                isNumber: true,
              ),
            ),
            const SizedBox(width: 16),
            // --- 6. إضافة منتقي تاريخ الإنتاج ---
            Expanded(
              child: _buildDatePicker(
                controller.productionDateController,
                'تاريخ الإنتاج',
                (date) => controller.updateProductionDate(date!),
                isRequired: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // تاريخ الانتهاء في سطر لوحده ليكون أوضح
        _buildDatePicker(
          controller.expiryDateController,
          'تاريخ الانتهاء',
          (date) => controller.updateExpiryDate(date!),
        ),
        const Divider(height: 32),

        // قسم الملاحظات
        _buildTextField(
          controller.notesController,
          'ملاحظات',
          Icons.notes_rounded,
          isRequired: false,
          maxLines: 3,
        ),
      ],
    );
  }

  // ويدجت مساعد لإنشاء حقول الإدخال بشكل موحد
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = true,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        if (isNumber && value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return 'الرجاء إدخال رقم صحيح';
          }
        }
        return null;
      },
    );
  }

  // ويدجت مساعد لإنشاء منتقي التاريخ
  Widget _buildDatePicker(
    TextEditingController controller,
    String label,
    Function(DateTime?) onDatePicked, {
    bool isRequired = true,
  }) {
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
          firstDate: DateTime(2010),
          lastDate: DateTime(2050),
        );
        if (pickedDate != null) {
          onDatePicked(pickedDate);
        }
      },
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }

  // ويدجت مساعد لإنشاء قائمة الوحدات المنسدلة
  Widget _buildUnitsDropdown(ItemsController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- ✅ الحل: تأكد من أن القائمة ليست فارغة قبل بناء الويدجت ---
        Obx(() {
          // إذا كانت القائمة فارغة، اعرض حقل نصي مؤقت مع مؤشر تحميل
          if (controller.unitsList.isEmpty) {
            return TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'الوحدة',
                prefixIcon: SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                border: OutlineInputBorder(),
              ),
            );
          }
          // إذا كانت القائمة تحتوي على بيانات، قم ببناء القائمة المنسدلة
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'الوحدة',
              prefixIcon: Icon(Icons.widgets_outlined),
              border: OutlineInputBorder(),
            ),
            // التأكد من أن القيمة المختارة موجودة في القائمة قبل تعيينها
            value: controller.unitsList.contains(controller.selectedUnit.value)
                ? controller.selectedUnit.value
                : null,
            items: controller.unitsList.map((String unit) {
              return DropdownMenuItem<String>(value: unit, child: Text(unit));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.selectedUnit.value = newValue;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء اختيار وحدة';
              }
              return null;
            },
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () =>
                controller.openManageLookupsDialog(LookupType.units),
            child: const Text('إدارة الوحدات...'),
          ),
        ),
      ],
    );
  }

  // ويدجت مساعد لعرض واختيار الصورة (مبدئي)
  Widget _buildImagePicker(ItemsController controller, ThemeData theme) {
    return GetBuilder<ItemsController>(
      // id: 'image_picker_update',
      builder: (ctrl) => DropTarget(
        onDragDone: (detail) {
          ctrl.selectedImagePath.value = detail.files.first.path;
          ctrl.update();
        },
        child: GestureDetector(
          onTap: ctrl.pickImage,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ctrl.selectedImagePath.value.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      File(ctrl.selectedImagePath.value),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.grey.shade600,
                          size: 50,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اسحب صورة إلى هنا\nأو اضغط للاختيار',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // --- ✅ جديد: ويدجت مساعد لإنشاء قائمة الأشكال الدوائية ---
  Widget _buildItemFormsDropdown(ItemsController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- ✅ الحل: تأكد من أن القائمة ليست فارغة قبل بناء الويدجت ---
        Obx(() {
          if (controller.itemFormsList.isEmpty) {
            return TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'الشكل الدوائي',
                prefixIcon: SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                border: OutlineInputBorder(),
              ),
            );
          }
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'الشكل الدوائي',
              prefixIcon: Icon(Icons.medication_outlined),
              border: OutlineInputBorder(),
            ),
            value:
                controller.itemFormsList.contains(
                  controller.selectedItemForm.value,
                )
                ? controller.selectedItemForm.value
                : null,
            items: controller.itemFormsList.map((String form) {
              return DropdownMenuItem<String>(value: form, child: Text(form));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.selectedItemForm.value = newValue;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء اختيار شكل دوائي';
              }
              return null;
            },
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () =>
                controller.openManageLookupsDialog(LookupType.itemForms),
            child: const Text('إدارة الأشكال...'),
          ),
        ),
      ],
    );
  }
}
