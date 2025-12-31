import 'dart:async'; // لاستخدام الـ Timer في البحث
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medistock/app/core/utils/item_report_generator.dart'; // ✅ Re-added
import '../../../data/local/models/item_model.dart';
import '../../../data/local/providers/item_provider.dart';
import '../views/add_edit_item_dialog.dart';
import 'package:file_picker/file_picker.dart';

import '../views/manage_lookups_dialog.dart';
import '../views/print_preview_dialog.dart'; // ✅ جديد
import 'package:medistock/app/core/services/report_settings_service.dart'; // ✅ جديد
// --- ✅ تصحيح: توحيد مسار الاستيراد ---

class ItemsController extends GetxController {
  final ItemProvider _provider = ItemProvider();

  var _allItems = <ItemModel>[];
  var itemsList = <ItemModel>[].obs;
  var isGridView = false.obs;
  var itemFormsList = <String>[].obs; // ✅ جديد: قائمة الأشكال الدوائية
  var selectedItemForm = ''.obs; // ✅ جديد: الشكل الدوائي المختار
  // --- ✅ جديد: متغيرات الفلترة والترتيب ---
  var activeFilter = 'الكل'.obs;
  var sortOption = 'الجديد'.obs;
  var isSortAscending = false.obs; // الافتراضي تنازلي (الأحدث أولاً)

  var isLoading = true.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController scientificNameController;
  late TextEditingController itemCodeController;
  late TextEditingController batchNumberController;
  late TextEditingController quantityController;
  late TextEditingController alertLimitController;
  late TextEditingController productionDateController;
  late TextEditingController expiryDateController;
  late TextEditingController notesController;
  late TextEditingController searchController;
  late TextEditingController lookupTextController; // ✅ جديد
  Timer? _debounce;

  var totalItemsCount = 0.obs;
  var expiringSoonCount = 0.obs;
  var outOfStockCount = 0.obs;
  var lowStockCount = 0.obs; // جديد: للأصناف التي قاربت على النفاذ
  var expiredCount = 0.obs; // جديد: للأصناف منتهية الصلاحية

  var selectedImagePath = ''.obs;
  var unitsList = <String>[].obs;
  var selectedUnit = ''.obs;
  DateTime? _selectedProductionDate;
  DateTime? _selectedExpiryDate;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchAllItems();
    fetchUnits();
    fetchItemForms(); // ✅ جديد: جلب الأشكال الدوائية عند بدء التشغيل
  }

  void toggleView(bool isGrid) {
    isGridView.value = isGrid;
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    scientificNameController = TextEditingController();
    itemCodeController = TextEditingController();
    batchNumberController = TextEditingController();
    quantityController = TextEditingController();
    alertLimitController = TextEditingController();
    productionDateController = TextEditingController();
    expiryDateController = TextEditingController();
    notesController = TextEditingController();
    searchController = TextEditingController();
    lookupTextController = TextEditingController(); // ✅ جديد
  }

  void fetchUnits() async {
    try {
      var units = await _provider.getAllUnits();
      unitsList.assignAll(units);
    } catch (e) {
      print("Error fetching units: $e");
    }
  }

  void fetchAllItems() async {
    try {
      isLoading(true);
      _allItems = await _provider.getAllItems();
      _calculateStats();
      _applyFiltersAndSort(); // <-- ✅ تم التعديل
    } catch (e) {
      _showErrorDialog('حدث خطأ أثناء جلب البيانات', e.toString());
      print(e);
    } finally {
      isLoading(false);
    }
  }

  void _calculateStats() {
    totalItemsCount.value = _allItems.length;
    final ninetyDaysFromNow = DateTime.now().add(const Duration(days: 90));
    expiringSoonCount.value = _allItems
        .where(
          (item) =>
              !item.expiryDate.isBefore(DateTime.now()) &&
              item.expiryDate.isBefore(ninetyDaysFromNow),
        )
        .length;
    outOfStockCount.value = _allItems
        .where((item) => item.quantity == 0)
        .length;

    lowStockCount.value = _allItems
        .where((item) => item.quantity > 0 && item.quantity <= item.alertLimit)
        .length;

    // --- ✅ جديد: حساب الأصناف منتهية الصلاحية ---
    expiredCount.value = _allItems
        .where((item) => item.expiryDate.isBefore(DateTime.now()))
        .length;
  }

  void searchItems(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _applyFiltersAndSort(); // <-- ✅ تم التعديل
    });
  }

  void clearSearch() {
    searchController.clear();
    _applyFiltersAndSort(); // <-- ✅ تم التعديل
  }

  void openAddEditDialog({ItemModel? itemToEdit}) {
    Get.dialog(
      Builder(
        builder: (context) {
          return AddEditItemDialog(itemToEdit: itemToEdit);
        },
      ),
      barrierDismissible: false,
    );
  }

  void setupTextFieldsForEdit(ItemModel item) {
    nameController.text = item.name;
    scientificNameController.text = item.scientificName ?? '';
    itemCodeController.text = item.itemCode ?? '';
    batchNumberController.text = item.batchNumber ?? '';
    quantityController.text = item.quantity.toString();
    alertLimitController.text = item.alertLimit.toString();
    notesController.text = item.notes ?? '';
    selectedUnit.value = item.unit ?? '';
    selectedItemForm.value =
        item.formId?.toString() ??
        ''; // ✅ جديد: سنحتاج لتحويل ID إلى اسم لاحقاً
    if (item.productionDate != null) {
      updateProductionDate(item.productionDate!);
    }
    updateExpiryDate(item.expiryDate);
    selectedImagePath.value = item.imagePath ?? '';
  }

  void clearTextFields() {
    nameController.clear();
    scientificNameController.clear();
    itemCodeController.clear();
    batchNumberController.clear();
    quantityController.clear();
    alertLimitController.clear();
    productionDateController.clear();
    expiryDateController.clear();
    notesController.clear();
    selectedUnit.value = '';
    selectedItemForm.value = ''; // ✅ جديد
    _selectedProductionDate = null;
    _selectedExpiryDate = null;
    selectedImagePath.value = '';
  }

  void updateProductionDate(DateTime date) {
    _selectedProductionDate = date;
    productionDateController.text = DateFormat('yyyy-MM-dd').format(date);
  }

  void updateExpiryDate(DateTime date) {
    _selectedExpiryDate = date;
    expiryDateController.text = DateFormat('yyyy-MM-dd').format(date);
  }

  void saveItem(ItemModel? itemToEdit) async {
    if (formKey.currentState!.validate()) {
      final isEditMode = itemToEdit != null;
      final newItem = ItemModel(
        id: isEditMode ? itemToEdit.id : null,
        name: nameController.text.trim(),
        scientificName: scientificNameController.text.trim(),
        itemCode: itemCodeController.text.trim(),
        batchNumber: batchNumberController.text.trim(),
        unit: selectedUnit.value,
        formId: itemFormsList.indexOf(selectedItemForm.value) + 1,
        quantity: int.parse(quantityController.text),
        alertLimit: int.tryParse(alertLimitController.text) ?? 0,
        productionDate: _selectedProductionDate,
        expiryDate: _selectedExpiryDate!,
        notes: notesController.text.trim(),
        imagePath: selectedImagePath.value,
        createdAt: isEditMode ? itemToEdit.createdAt : DateTime.now(),
      );

      try {
        if (isEditMode) {
          await _provider.updateItem(newItem);
          Get.back(); // إغلاق نافذة الإضافة/التعديل أولاً
          _showSuccessDialog('تم التعديل بنجاح', 'تم تحديث بيانات الصنف.');
        } else {
          await _provider.addItem(newItem);
          Get.back(); // إغلاق نافذة الإضافة/التعديل أولاً
          _showSuccessDialog(
            'تمت الإضافة بنجاح',
            'تم حفظ الصنف الجديد في قاعدة البيانات.',
          );
        }
        fetchAllItems();
      } catch (e) {
        // --- ✅ تم التعديل: استبدال Snackbar بـ Dialog ---
        _showErrorDialog('فشل حفظ الصنف', e.toString());
      }
    } else {
      // --- ✅ تم التعديل: استبدال Snackbar بـ Dialog ---
      Get.defaultDialog(
        title: "تنبيه",
        middleText: "الرجاء ملء جميع الحقول المطلوبة بشكل صحيح.",
        titleStyle: TextStyle(color: Colors.orange.shade800),
        textConfirm: "موافق",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    }
  }

  void deleteItem(int id) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText:
          "هل أنت متأكد أنك تريد حذف هذا الصنف؟ لا يمكن التراجع عن هذا الإجراء.",
      textConfirm: "حذف",
      textCancel: "إلغاء",
      buttonColor: Get.theme.colorScheme.error,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // إغلاق نافذة التأكيد
        try {
          await _provider.deleteItem(id);
          fetchAllItems();
          // --- ✅ تم التعديل: استبدال Snackbar بـ Dialog ---
          _showSuccessDialog('تم الحذف', 'تم حذف الصنف من قاعدة البيانات.');
        } catch (e) {
          // --- ✅ تم التعديل: استبدال Snackbar بـ Dialog ---
          _showErrorDialog('فشل حذف الصنف', e.toString());
        }
      },
    );
  }

  void pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      selectedImagePath.value = result.files.single.path!;
      update();
    }
  }

  // --- جديد: دوال مساعدة لعرض مربعات الحوار ---
  void _showSuccessDialog(String title, String message) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      titleStyle: TextStyle(color: Get.theme.colorScheme.secondary),
      textConfirm: "موافق",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  void _showErrorDialog(String title, String message) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      titleStyle: TextStyle(color: Get.theme.colorScheme.error),
      textConfirm: "موافق",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  // --- ✅ تم التعديل: فتح نافذة المعاينة والطباعة ---
  void exportToPdf() {
    // 1. تحميل الإعدادات الحالية للتقارير
    final reportSettingsService = ReportSettingsService();
    final settings = reportSettingsService.loadSettings();

    // 2. فتح نافذة المعاينة
    Get.dialog(
      PrintPreviewDialog(
        initialSettings: settings,
        pdfBuilder: (settings, suffix) async {
          return ItemReportGenerator.generatePdf(
            itemsList.toList(),
            settings: settings,
            recipientSuffix: suffix,
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  // ✅ جديد: دالة لجلب الأشكال الدوائية
  void fetchItemForms() async {
    try {
      var forms = await _provider.getAllItemForms();
      itemFormsList.assignAll(forms);
    } catch (e) {
      print("Error fetching item forms: $e");
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    scientificNameController.dispose();
    itemCodeController.dispose();
    batchNumberController.dispose();
    quantityController.dispose();
    alertLimitController.dispose();
    productionDateController.dispose();
    expiryDateController.dispose();
    notesController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void openManageLookupsDialog(LookupType type) {
    lookupTextController.clear();
    Get.dialog(ManageLookupsDialog(type: type));
  }

  void addLookupItem(LookupType type) async {
    final value = lookupTextController.text.trim();
    if (value.isEmpty) return;
    try {
      if (type == LookupType.units) {
        // ... (منطق إضافة الوحدة في قاعدة البيانات)
        await _provider.addUnit(value);
        fetchUnits(); // إعادة تحميل القائمة
      } else {
        await _provider.addItemForm(value);
        fetchItemForms(); // إعادة تحميل القائمة
      }
      lookupTextController.clear();
    } catch (e) {
      _showErrorDialog('خطأ في الإضافة', 'قد يكون هذا العنصر موجوداً بالفعل.');
    }
  }

  void deleteLookupItem(String value, LookupType type) async {
    // عرض رسالة تأكيد
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل أنت متأكد من حذف '$value'؟",
      textConfirm: "حذف",
      textCancel: "إلغاء",
      onConfirm: () async {
        Get.back(); // إغلاق رسالة التأكيد
        try {
          if (type == LookupType.units) {
            // ... (منطق حذف الوحدة)
            await _provider.deleteUnit(value);
            fetchUnits();
          } else {
            // ... (منطق حذف الشكل الدوائي)
            await _provider.deleteItemForm(value);
            fetchItemForms();
          }
          _showSuccessDialog('نجاح', 'تم حذف العنصر بنجاح.');
        } catch (e) {
          _showErrorDialog(
            'خطأ في الحذف',
            'لا يمكن حذف هذا العنصر لأنه مستخدم حالياً.',
          );
        }
      },
    );
  }

  // --- ✅ جديد: دالة لتطبيق كل الفلاتر والترتيب ---
  void _applyFiltersAndSort() {
    List<ItemModel> filteredList = List.from(_allItems);

    // 1. تطبيق فلتر الحالة (مثل: منتهي الصلاحية)
    switch (activeFilter.value) {
      case 'قارب على النفاذ':
        filteredList = filteredList
            .where((i) => i.quantity > 0 && i.quantity <= i.alertLimit)
            .toList();
        break;
      case 'نفد من المخزون':
        filteredList = filteredList.where((i) => i.quantity == 0).toList();
        break;
      case 'قارب على الانتهاء':
        final ninetyDaysFromNow = DateTime.now().add(const Duration(days: 90));
        filteredList = filteredList
            .where(
              (i) =>
                  !i.expiryDate.isBefore(DateTime.now()) &&
                  i.expiryDate.isBefore(ninetyDaysFromNow),
            )
            .toList();
        break;
      case 'منتهي الصلاحية':
        filteredList = filteredList
            .where((i) => i.expiryDate.isBefore(DateTime.now()))
            .toList();
        break;
      default: // 'الكل'
        // لا تفعل شيئًا، استخدم القائمة الكاملة
        break;
    }

    // 2. تطبيق فلتر البحث النصي
    final keyword = searchController.text.trim().toLowerCase();
    if (keyword.isNotEmpty) {
      filteredList = filteredList
          .where(
            (item) =>
                item.name.toLowerCase().contains(keyword) ||
                (item.scientificName?.toLowerCase().contains(keyword) ??
                    false) ||
                (item.itemCode?.toLowerCase().contains(keyword) ?? false),
          )
          .toList();
    }

    // 3. تطبيق الترتيب
    filteredList.sort((a, b) {
      int comparison;
      switch (sortOption.value) {
        case 'الاسم':
          comparison = a.name.compareTo(b.name);
          break;
        case 'الكمية':
          comparison = a.quantity.compareTo(b.quantity);
          break;
        default: // 'الجديد'
          comparison = b.createdAt.compareTo(a.createdAt); // الأحدث أولاً
          break;
      }
      return isSortAscending.value ? comparison : -comparison;
    });

    // 4. تحديث الواجهة بالقائمة النهائية
    itemsList.assignAll(filteredList);
  }

  // --- ✅ جديد: دوال لتغيير الفلتر والترتيب من الواجهة ---
  void changeFilter(String newFilter) {
    activeFilter.value = newFilter;
    _applyFiltersAndSort();
  }

  void changeSortOption(String newSortOption) {
    sortOption.value = newSortOption;
    _applyFiltersAndSort();
  }

  void toggleSortOrder() {
    isSortAscending.value = !isSortAscending.value;
    _applyFiltersAndSort();
  }
}
