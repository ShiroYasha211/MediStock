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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.transparent, // For gradient container
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        height: MediaQuery.of(context).size.height * 0.7,
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
            // Header
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
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'إضافة عملية صرف جديدة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Theme(
                data: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: theme.primaryColor,
                  ),
                ),
                child: Obx(
                  () => Stepper(
                    type: StepperType.horizontal,
                    currentStep: controller.currentStep.value,
                    onStepContinue: controller.nextStep,
                    onStepCancel: controller.previousStep,
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (details.currentStep > 0)
                              TextButton(
                                onPressed: details.onStepCancel,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'السابق',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                details.currentStep == 1
                                    ? 'تنفيذ الصرف'
                                    : 'التالي',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
            ),
          ],
        ),
      ),
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
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }
                  return DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'أمر الصرف',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    value: controller.selectedOrderId.value,
                    items: controller.availableOrders.map((order) {
                      return DropdownMenuItem<int>(
                        value: order.id,
                        child: Text(
                          '${order.orderNumber} - ${order.issuingEntity ?? ''}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null)
                        controller.selectedOrderId.value = value;
                    },
                  );
                }),
              ),
              const SizedBox(width: 16),
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
          ),
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
                  child: Obx(() {
                    // Fix: Access observable synchronously to register listener
                    final items = controller.allItems.toList();

                    return Autocomplete<ItemModel>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<ItemModel>.empty();
                        }
                        final matches = items.where((item) {
                          return item.name.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                        });

                        if (matches.isEmpty) {
                          // Return a dummy item to signal 'Not Found'
                          return [
                            ItemModel(
                              id: -1,
                              name: 'الصنف غير موجود',
                              quantity: 0,
                              expiryDate: DateTime.now(),
                              createdAt: DateTime.now(),
                              notes: 'dummy',
                            ),
                          ];
                        }
                        return matches;
                      },
                      displayStringForOption: (ItemModel option) => option.name,
                      onSelected: (ItemModel selection) {
                        if (selection.id == -1) {
                          // Do nothing if dummy selected
                          return;
                        }
                        controller.selectedItemId.value = selection.id;
                        // Focus next field (Quantity)
                        controller.quantityFocusNode.requestFocus();
                      },
                      fieldViewBuilder:
                          (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              onFieldSubmitted: (String value) {
                                onFieldSubmitted();
                                // Also move focus to quantity on Enter
                                controller.quantityFocusNode.requestFocus();
                              },
                              decoration: InputDecoration(
                                labelText: 'ابحث عن الصنف...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                prefixIcon: const Icon(Icons.search),
                              ),
                            );
                          },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment:
                              Alignment.topRight, // RTL: TopRight is Start
                          child: Material(
                            elevation: 4.0,
                            child: SizedBox(
                              width: 300, // Constrain width
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true, // Fit content
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final ItemModel option = options.elementAt(
                                    index,
                                  );

                                  // Handle Not Found Case
                                  if (option.id == -1) {
                                    return ListTile(
                                      title: Text(
                                        option.name,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  }

                                  // Extract details
                                  final formName =
                                      controller.itemFormsMap[option.formId] ??
                                      '';
                                  final unitName = option.unit ?? '';
                                  String detailsText = '';
                                  if (formName.isNotEmpty)
                                    detailsText += formName;
                                  if (unitName.isNotEmpty) {
                                    if (detailsText.isNotEmpty)
                                      detailsText += ' - ';
                                    detailsText += unitName;
                                  }

                                  return ListTile(
                                    title: Text(
                                      option.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text.rich(
                                      TextSpan(
                                        children: [
                                          if (detailsText.isNotEmpty)
                                            TextSpan(
                                              text: '$detailsText\n',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          TextSpan(
                                            text:
                                                'الكمية المتاحة: ${option.quantity}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    isThreeLine: true,
                                    onTap: () {
                                      onSelected(option);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: controller.quantityController,
                    focusNode: controller.quantityFocusNode, // ✅ جديد
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'الكمية',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    onFieldSubmitted: (_) {
                      // عند الضغط على Enter يتم إضافة الدواء
                      controller.addItemToDisbursementList();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // زر الإضافة
                IconButton.filled(
                  onPressed: controller.addItemToDisbursementList,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Container(
            height: 220, // تحديد ارتفاع لمنطقة الجدول
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Obx(
              () => controller.itemsToDisburse.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لم يتم إضافة أي أصناف بعد',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: controller.itemsToDisburse.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = controller.itemsToDisburse[index];
                        final ItemModel item = entry['item'];
                        final int quantity = entry['quantity'];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.primaryColor.withOpacity(
                              0.1,
                            ),
                            foregroundColor: theme.primaryColor,
                            child: Text((index + 1).toString()),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'الكمية المطلوبة: $quantity',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          onTap: () => controller.openEditItemDialog(entry),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            tooltip: 'إزالة الصنف',
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
