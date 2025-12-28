import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medistock/app/modules/04_transactions_management/controllers/transactions_controller.dart';

import '../../../data/local/models/item_model.dart';

class AddTransactionDialog extends StatelessWidget {
  const AddTransactionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('إضافة عملية صرف جديدة'),
      content: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.5, // 50% من عرض الشاشة
        height: MediaQuery
            .of(context)
            .size
            .height * 0.6,
        child: Obx(
              () =>
              Stepper(
                type: StepperType.horizontal,
                currentStep: controller.currentStep.value,
                onStepContinue: controller.nextStep,
                onStepCancel: controller.previousStep,
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        if (details.currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('السابق'),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(details.currentStep == 1
                              ? 'تنفيذ الصرف'
                              : 'التالي'),
                        ),
                      ],
                    ),
                  );
                },
                steps: [
                  _buildStep1(theme, controller), // خطوة اختيار أمر الصرف
                  _buildStep2(theme, controller), // خطوة إضافة الأصناف
                ],
              ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),child: const Text('إلغاء العملية'),
        ),
      ],
    );
  }

  Step _buildStep1(ThemeData theme, TransactionsController controller) {
    return Step(
      title: const Text('اختيار الأمر'),
      isActive: controller.currentStep.value >= 0,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // محاذاة لليمين
        children: [
          const Text(
            'أولاً, اختر أمر الصرف الذي سيتم التنفيذ بناءً عليه:',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.availableOrders.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                          'لا توجد أوامر صرف متاحة. قم بإضافة أمر جديد.',
                          style: TextStyle(color: Colors.grey.shade600)),
                    );
                  }
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'أمر الصرف',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedOrderId.value,
                    items: controller.availableOrders.map((order) {
                      return DropdownMenuItem<int>(
                        value: order.id,
                        child: Text(
                            '${order.orderNumber} - ${order.issuingEntity ??
                                ''}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null)
                        controller.selectedOrderId.value = value;
                    },
                  );
                }),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.add_box_outlined, size: 30),
                  onPressed: controller.openAddOrderDialog,
                  tooltip: 'إضافة أمر صرف جديد',
                  color: theme.primaryColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Step _buildStep2(ThemeData theme, TransactionsController controller) {
    return Step(
      title: const Text('تحديد الأصناف'),
      isActive: controller.currentStep.value >= 1,
      state: controller.currentStep.value > 1
          ? StepState.complete
          : StepState.editing,
      content: Column(
        children: [
          // ---✅ جديد: منطقة إضافة الأصناف ---
          Form(
            key: controller.formKeyStep2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // قائمة منسدلة لاختيار الصنف
                Expanded(
                  flex: 3,
                  child: Obx(() =>
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                            labelText: 'الصنف', border: OutlineInputBorder()),
                        value: controller.selectedItemId.value,
                        items: controller.allItems.map((item) {
                          return DropdownMenuItem<int>(
                            value: item.id,
                            child: Text('${item.name} (المتاح: ${item
                                .quantity})'),
                          );
                        }).toList(), onChanged: (value) {
                        if (value != null)
                          controller.selectedItemId.value = value;
                      },
                      )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: controller.quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'الكمية', border: OutlineInputBorder()),
                  ),),
                const SizedBox(width: 10),
                // زر الإضافة
                IconButton.filled(
                  onPressed: controller.addItemToDisbursementList,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                      backgroundColor: theme.primaryColor),
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          SizedBox(
            height
                : 200, // تحديد ارتفاع لمنطقة الجدول
            child: Obx(
                  () =>
                  ListView.builder(
                    itemCount: controller.itemsToDisburse.length,
                    itemBuilder: (context, index) {
                      final entry = controller.itemsToDisburse[index];
                      final ItemModel item = entry['item'];
                      final int quantity = entry['quantity'];

                      return ListTile(
                        leading: CircleAvatar(child: Text((index + 1)
                            .toString())),
                        title: Text(item.name),
                        subtitle: Text('الكمية المطلوبة: $quantity'),
                        trailing: IconButton(icon: const Icon(
                            Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () =>
                              controller.removeItemFromList(item.id!),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}