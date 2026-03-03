import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/local/models/item_model.dart';
import '../controllers/items_controller.dart';
import 'package:medistock/app/data/local/providers/transaction_provider.dart'
    as medistock_transaction_provider; // ✅ جديد: جلب حركة الأصناف

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
  Widget _buildItemCard(
    ItemModel item,
    ItemsController controller, {
    bool isListView = false,
  }) {
    final theme = Get.theme;
    final bool isExpired = item.expiryDate.isBefore(DateTime.now());
    final bool isLowStock =
        item.quantity > 0 && item.quantity <= item.alertLimit;

    final Color borderCol = isExpired
        ? theme.colorScheme.error
        : (isLowStock ? Colors.orange.shade700 : Colors.transparent);

    return Card(
      elevation: 4, // Increased elevation
      shadowColor: borderCol.withOpacity(0.4), // Colored shadow
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderCol, width: 1.5),
        borderRadius: BorderRadius.circular(16), // Softer radius
      ),
      clipBehavior: Clip.antiAlias, // Apply clipping for gradient
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              borderCol.withOpacity(0.08), // Light tint
              Colors.white.withOpacity(0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- الجزء العلوي: الصورة والأسماء ---
            Padding(
              padding: const EdgeInsets.all(16.0), // increased padding
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الصورة
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12), // Match BoxDeco
                      child: SizedBox(
                        width: isListView ? 80 : 80,
                        height: isListView ? 80 : 80,
                        child:
                            item.imagePath != null && item.imagePath!.isNotEmpty
                            ? Image.file(
                                File(item.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: theme.colorScheme.surfaceVariant,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Container(
                                color: theme.colorScheme.surfaceVariant,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // الأسماء والأيقونات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.scientificName != null &&
                            item.scientificName!.isNotEmpty)
                          Text(
                            item.scientificName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (isExpired)
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                            if (isLowStock)
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 18,
                              ),
                            if (item.quantity == 0)
                              const Icon(
                                Icons.remove_shopping_cart_outlined,
                                color: Colors.red,
                                size: 18,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // أزرار الإجراءات
                  Column(
                    children: [
                      // Action Buttons styling
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.history_rounded,
                            color: Colors.purple.shade500,
                            size: 20,
                          ),
                          onPressed: () =>
                              _showItemHistory(Get.context!, item, controller),
                          tooltip: 'سجل الحركات',
                          splashRadius: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          onPressed: () =>
                              controller.openAddEditDialog(itemToEdit: item),
                          tooltip: 'تعديل',
                          splashRadius: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          onPressed: () => controller.deleteItem(item.id!),
                          tooltip: 'حذف',
                          splashRadius: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            // --- الجزء السفلي: باقي التفاصيل ---
            isListView
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      children: [
                        _buildDetailChip(
                          'المتاح',
                          item.quantity.toString(),
                          Icons.inventory_2_rounded,
                          theme,
                          color: Colors.green.shade700,
                        ),
                        // ✅ جديد: الكمية المنصرفة
                        Obx(() {
                          final dispensed =
                              controller.dispensedQuantitiesMap[item.id] ?? 0;
                          return _buildDetailChip(
                            'المنصرف',
                            dispensed.toString(),
                            Icons.outbound_rounded,
                            theme,
                            color: Colors.orange.shade700,
                          );
                        }),
                        _buildDetailChip(
                          'الانتهاء',
                          DateFormat('yyyy-MM-dd').format(item.expiryDate),
                          Icons.event_busy_outlined,
                          theme,
                          color: isExpired ? theme.colorScheme.error : null,
                        ),
                        if (item.batchNumber != null &&
                            item.batchNumber!.isNotEmpty)
                          _buildDetailChip(
                            'التشغيلة',
                            item.batchNumber!,
                            Icons.tag,
                            theme,
                          ),
                        if (item.unit != null && item.unit!.isNotEmpty)
                          _buildDetailChip(
                            'الوحدة',
                            item.unit!,
                            Icons.widgets_outlined,
                            theme,
                          ),

                        // --- ✅ تم التصحيح والترتيب هنا ---
                        if (item.formId != null &&
                            item.formId! > 0 &&
                            controller.itemFormsList.length >= item.formId!)
                          _buildDetailChip(
                            'الشكل',
                            // نحصل على الاسم من القائمة باستخدام الـ ID
                            controller.itemFormsList[item.formId! - 1],
                            Icons.medication_outlined,
                            theme,
                          ),

                        if (item.itemCode != null && item.itemCode!.isNotEmpty)
                          _buildDetailChip(
                            'الكود',
                            item.itemCode!,
                            Icons.qr_code_2,
                            theme,
                          ),
                      ],
                    ),
                  )
                : Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 10,
                          children: [
                            _buildDetailChip(
                              'المتاح',
                              item.quantity.toString(),
                              Icons.inventory_2_rounded,
                              theme,
                              color: Colors.green.shade700,
                            ),
                            // ✅ جديد: الكمية المنصرفة
                            Obx(() {
                              final dispensed =
                                  controller.dispensedQuantitiesMap[item.id] ??
                                  0;
                              return _buildDetailChip(
                                'المنصرف',
                                dispensed.toString(),
                                Icons.outbound_rounded,
                                theme,
                                color: Colors.orange.shade700,
                              );
                            }),
                            _buildDetailChip(
                              'الانتهاء',
                              DateFormat('yyyy-MM-dd').format(item.expiryDate),
                              Icons.event_busy_outlined,
                              theme,
                              color: isExpired ? theme.colorScheme.error : null,
                            ),
                            if (item.batchNumber != null &&
                                item.batchNumber!.isNotEmpty)
                              _buildDetailChip(
                                'التشغيلة',
                                item.batchNumber!,
                                Icons.tag,
                                theme,
                              ),
                            if (item.unit != null && item.unit!.isNotEmpty)
                              _buildDetailChip(
                                'الوحدة',
                                item.unit!,
                                Icons.widgets_outlined,
                                theme,
                              ),

                            // --- ✅ تم التصحيح والترتيب هنا ---
                            if (item.formId != null &&
                                item.formId! > 0 &&
                                controller.itemFormsList.length >= item.formId!)
                              _buildDetailChip(
                                'الشكل',
                                // نحصل على الاسم من القائمة باستخدام الـ ID
                                controller.itemFormsList[item.formId! - 1],
                                Icons.medication_outlined,
                                theme,
                              ),

                            if (item.itemCode != null &&
                                item.itemCode!.isNotEmpty)
                              _buildDetailChip(
                                'الكود',
                                item.itemCode!,
                                Icons.qr_code_2,
                                theme,
                              ),
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

  Widget _buildDetailChip(
    String label,
    String value,
    IconData icon,
    ThemeData theme, {
    Color? color,
  }) {
    final chipColor = color ?? theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- ✅ جديد: دالة عرض نافذة سجل الحركات للصنف ---
  void _showItemHistory(
    BuildContext context,
    ItemModel item,
    ItemsController controller,
  ) {
    if (item.id == null) return;

    // إظهار نافذة تحميل أولاً أو نافذة مباشرة تجلب البيانات
    showDialog(
      context: context,
      builder: (context) {
        return _ItemHistoryDialog(item: item);
      },
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
                  icon: Icon(
                    controller.isSortAscending.value
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                  ),
                  onPressed: controller.toggleSortOrder,
                  tooltip: controller.isSortAscending.value
                      ? 'تصاعدي'
                      : 'تنازلي',
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
                  isSelected: [
                    !controller.isGridView.value,
                    controller.isGridView.value,
                  ],
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
        childAspectRatio: 1.7, // نسبة العرض إلى الارتفاع
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
    String title,
    String Function() valueBuilder,
    IconData icon,
    Color color,
  ) {
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
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Obx(
                  () => Text(
                    valueBuilder(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
    final IconData icon = isSearching
        ? Icons.search_off
        : Icons.inventory_2_outlined;
    final String title = isSearching
        ? 'لا توجد نتائج مطابقة'
        : 'لا توجد أصناف مدخلة حاليًا';
    final String subtitle = isSearching
        ? 'حاول استخدام كلمات بحث مختلفة'
        : 'اضغط على زر "إضافة صنف جديد" للبدء';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 22, color: Colors.grey)),
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
    final filters = [
      'الكل',
      'قارب على النفاذ',
      'نفد من المخزون',
      'قارب على الانتهاء',
      'منتهي الصلاحية',
    ];

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
              label: Text(
                filter,
                style: TextStyle(
                  fontWeight: controller.activeFilter.value == filter
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              selected: controller.activeFilter.value == filter,
              onSelected: (selected) {
                if (selected) {
                  controller.changeFilter(filter);
                }
              },
              selectedColor: theme.primaryColor,
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
                0.5,
              ),
              elevation: controller.activeFilter.value == filter ? 2 : 0,
              labelStyle: TextStyle(
                color: controller.activeFilter.value == filter
                    ? Colors.white
                    : theme.colorScheme.onSurface,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- ✅ جديد: ويدجت داخلي لعرض نافذة سجل الحركات (Ledger) ---
class _ItemHistoryDialog extends StatefulWidget {
  final ItemModel item;

  const _ItemHistoryDialog({required this.item});

  @override
  State<_ItemHistoryDialog> createState() => _ItemHistoryDialogState();
}

class _ItemHistoryDialogState extends State<_ItemHistoryDialog> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _history = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final provider = Get.put(
        medistock_transaction_provider.TransactionProvider(),
      );
      final data = await provider.getTransactionsHistoryForItem(
        widget.item.id!,
      );
      setState(() {
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.all(0),
      title: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Colors.purple,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'سجل حركات: ${widget.item.name}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Text(
                  'خطأ: $_errorMessage',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              )
            : _history.isEmpty
            ? const Center(child: Text('لا توجد حركات صرف لهذا الصنف.'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      theme.colorScheme.surfaceContainerHighest,
                    ),
                    columns: const [
                      DataColumn(label: Text('تاريخ الصرف')),
                      DataColumn(label: Text('رقم أمر الصرف')),
                      DataColumn(label: Text('المستفيد')),
                      DataColumn(label: Text('الكمية المصروفة')),
                      DataColumn(label: Text('الكمية المرتجعة')),
                      DataColumn(label: Text('الصافي')),
                    ],
                    rows: _history.map((record) {
                      final String rawDate = record['transaction_date']
                          .toString();
                      final DateTime parsedDate =
                          DateTime.tryParse(rawDate) ?? DateTime.now();
                      final String date = DateFormat(
                        'yyyy/MM/dd  hh:mm a',
                      ).format(parsedDate);
                      final String orderNumber = record['order_number'] ?? '-';
                      final String beneficiary =
                          record['beneficiary_name'] ?? 'مجهول';
                      final int disbursed = record['quantity_disbursed'] ?? 0;
                      final int returned = record['quantity_returned'] ?? 0;
                      final int net = disbursed - returned;

                      return DataRow(
                        cells: [
                          DataCell(Text(date)),
                          DataCell(Text(orderNumber)),
                          DataCell(Text(beneficiary)),
                          DataCell(
                            Text(
                              disbursed.toString(),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              returned.toString(),
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                          DataCell(
                            Text(
                              net.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
