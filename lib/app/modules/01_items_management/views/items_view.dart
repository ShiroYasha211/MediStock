import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/local/models/item_model.dart';
import '../controllers/items_controller.dart';

class ItemsView extends StatelessWidget {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ItemsController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(controller, theme),
          _buildQuickFilters(controller, theme), // <-- ✅ أضف هذا السطر
          const Divider(height: 1),
          _buildViewControls(controller, theme),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.itemsList.isEmpty) {
                final isSearching = controller.searchController.text.isNotEmpty;
                return _buildEmptyState(isSearching: isSearching);
              }
              // --- ✅ جديد: التبديل بين طرق العرض ---
              return controller.isGridView.value
                  ? _buildGridView(controller)
                  : _buildListView(controller);
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.openAddEditDialog(),
        label: const Text('إضافة صنف جديد'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.secondary,
      ),
    );
  }

  // --- جديد: ويدجت لبناء بطاقة الصنف (القلب النابض للتصميم الجديد) ---
  Widget _buildItemCard(ItemModel item, ItemsController controller,
      {bool isListView = false}) {
    final theme = Get.theme;
    final bool isExpired = item.expiryDate.isBefore(DateTime.now());
    final bool isLowStock =
        item.quantity > 0 && item.quantity <= item.alertLimit;

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isExpired
              ? theme.colorScheme.error
              : (isLowStock ? Colors.orange.shade700 : Colors.transparent),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- الجزء العلوي: الصورة والأسماء ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصورة
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: isListView ? 80 : 100,
                    height: isListView ? 80 : 100,
                    child: item.imagePath != null &&
                        item.imagePath!.isNotEmpty
                        ? Image.file(File(item.imagePath!), fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                        const Icon(Icons.image_not_supported_outlined,
                            size: 40, color: Colors.grey))
                        : const Icon(Icons.image_not_supported_outlined,
                        size: 40, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                // الأسماء والأيقونات
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      if (item.scientificName != null &&
                          item.scientificName!.isNotEmpty)
                        Text(item.scientificName!,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (isExpired)
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 18),
                          if (isLowStock)
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.orange, size: 18),
                          if (item.quantity == 0)
                            const Icon(Icons.remove_shopping_cart_outlined,
                                color: Colors.red, size: 18),
                        ],
                      )
                    ],
                  ),
                ),
                // أزرار الإجراءات
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined,
                          color: Colors.blue.shade700, size: 20),
                      onPressed: () =>
                          controller.openAddEditDialog(itemToEdit: item),
                      tooltip: 'تعديل',
                      splashRadius: 20,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Colors.red.shade700, size: 20),
                      onPressed: () => controller.deleteItem(item.id!),
                      tooltip: 'حذف',
                      splashRadius: 20,
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 1),
          // --- الجزء السفلي: باقي التفاصيل ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _buildDetailChip('الكمية', item.quantity.toString(),
                    Icons.onetwothree, theme),
                _buildDetailChip(
                    'الانتهاء',
                    DateFormat('yyyy-MM-dd').format(item.expiryDate),
                    Icons.event_busy_outlined,
                    theme,
                    color: isExpired ? theme.colorScheme.error : null),
                if (item.batchNumber != null && item.batchNumber!.isNotEmpty)
                  _buildDetailChip(
                      'التشغيلة', item.batchNumber!, Icons.tag, theme),
                if (item.unit != null && item.unit!.isNotEmpty)
                  _buildDetailChip(
                      'الوحدة', item.unit!, Icons.widgets_outlined, theme),

                // --- ✅ تم التصحيح والترتيب هنا ---
                if (item.formId != null && item.formId! > 0 && controller.itemFormsList.length >= item.formId!)
                  _buildDetailChip(
                      'الشكل',
                      // نحصل على الاسم من القائمة باستخدام الـ ID
                      controller.itemFormsList[item.formId! - 1],
                      Icons.medication_outlined,
                      theme),

                if (item.itemCode != null && item.itemCode!.isNotEmpty)
                  _buildDetailChip(
                      'الكود', item.itemCode!, Icons.qr_code_2, theme),

                if (item.productionDate != null)
                  _buildDetailChip(
                      'الإنتاج',
                      DateFormat('yyyy-MM-dd').format(item.productionDate!),
                      Icons.calendar_today,
                      theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت مساعد لعرض تفصيلة داخل البطاقة
  Widget _buildDetailChip(
      String label, String value, IconData icon, ThemeData theme,
      {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text('$label: ',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(value,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // --- جديد: ويدجت لعرض خيارات التحكم ---
  Widget _buildViewControls(ItemsController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- ✅ جديد: عناصر التحكم في الترتيب ---
          Row(
            children: [
              Text('ترتيب حسب: ', style: theme.textTheme.bodyMedium),
              Obx(
                    () => DropdownButton<String>(
                  value: controller.sortOption.value,
                  items: ['الجديد', 'الاسم', 'الكمية'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.changeSortOption(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                    () => IconButton(
                  icon: Icon(controller.isSortAscending.value
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded),
                  onPressed: controller.toggleSortOrder,
                  tooltip: controller.isSortAscending.value ? 'تصاعدي' : 'تنازلي',
                ),
              ),
            ],
          ),
          // --- أزرار العرض والتصدير ---
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: controller.exportToPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('تصدير PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Obx(
                    () => ToggleButtons(
                  isSelected: [!controller.isGridView.value, controller.isGridView.value],
                  onPressed: (index) => controller.toggleView(index == 1),
                  borderRadius: BorderRadius.circular(8),
                  children: const [
                    Icon(Icons.view_list_rounded),
                    Icon(Icons.grid_view_rounded),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- جديد: ويدجت لعرض الأصناف كقائمة ---
  Widget _buildListView(ItemsController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: controller.itemsList.length,
      itemBuilder: (context, index) {
        final item = controller.itemsList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildItemCard(item, controller, isListView: true),
        );
      },
    );
  }

  // --- جديد: ويدجت لعرض الأصناف كشبكة ---
  Widget _buildGridView(ItemsController controller) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450, // أقصى عرض للبطاقة
        childAspectRatio: 1.7,   // نسبة العرض إلى الارتفاع
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.itemsList.length,
      itemBuilder: (context, index) {
        final item = controller.itemsList[index];
        return _buildItemCard(item, controller);
      },
    );
  }

  // باقي الدوال تبقى كما هي (Header, InfoCard, EmptyState)
  Widget _buildHeader(ItemsController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'إجمالي الأصناف',
                      () => controller.totalItemsCount.value.toString(),
                  Icons.inventory_2_outlined,
                  theme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'قارب على النفاذ',
                      () => controller.lowStockCount.value.toString(),
                  Icons.warning_amber_rounded,
                  Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'قارب على الانتهاء',
                      () => controller.expiringSoonCount.value.toString(),
                  Icons.hourglass_bottom_outlined,
                  Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'انتهت الصلاحية',
                      () => controller.expiredCount.value.toString(),
                  Icons.event_busy_outlined,
                  theme.colorScheme.error.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'نفدت الكمية',
                      () => controller.outOfStockCount.value.toString(),
                  Icons.remove_shopping_cart_outlined,
                  theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم التجاري, العلمي, أو الكود...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: controller.clearSearch,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: controller.searchItems,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String Function() valueBuilder, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade600),
                ),
                Obx(
                      () => Text(
                    valueBuilder(),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({bool isSearching = false}) {
    final IconData icon =
    isSearching ? Icons.search_off : Icons.inventory_2_outlined;
    final String title =
    isSearching ? 'لا توجد نتائج مطابقة' : 'لا توجد أصناف مدخلة حاليًا';
    final String subtitle = isSearching
        ? 'حاول استخدام كلمات بحث مختلفة'
        : 'اضغط على زر "إضافة صنف جديد" للبدء';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 22, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
  // --- ✅ جديد: ويدجت لبناء شريط الفلاتر السريعة ---
  Widget _buildQuickFilters(ItemsController controller, ThemeData theme) {
    final filters = ['الكل', 'قارب على النفاذ', 'نفد من المخزون', 'قارب على الانتهاء', 'منتهي الصلاحية'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Obx(
                () => ChoiceChip(
              label: Text(filter),
              selected: controller.activeFilter.value == filter,
              onSelected: (selected) {
                if (selected) {
                  controller.changeFilter(filter);
                }
              },
              selectedColor: theme.primaryColor,
              labelStyle: TextStyle(
                color: controller.activeFilter.value == filter ? Colors.white : null,
              ),
            ),
          );
        },
      ),
    );
  }

}

