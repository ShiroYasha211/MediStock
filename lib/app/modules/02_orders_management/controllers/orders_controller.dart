import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medistock/app/data/local/models/disbursement_order_model.dart';
import 'package:medistock/app/data/local/providers/order_provider.dart';
import 'package:medistock/app/modules/02_orders_management/views/add_edit_order_dialog.dart';
import 'package:medistock/app/data/local/models/beneficiary_model.dart';
import 'package:medistock/app/data/local/providers/beneficiary_provider.dart';

import '../../03_beneficiaries_mangement/controllers/beneficiaries_controller.dart';
import '../views/order_details_dialog.dart';
import '../../../data/local/providers/transaction_provider.dart';
import '../../../core/services/report_settings_service.dart';
import '../../../core/utils/item_report_generator.dart';
import '../../01_items_management/views/print_preview_dialog.dart';

class OrdersController extends GetxController {
  final OrderProvider _provider = OrderProvider();

  var ordersList = <DisbursementOrderModel>[].obs;
  var isLoading = true.obs;

  // --- ✅ جديد: متغيرات المستفيدين ---
  final BeneficiaryProvider _beneficiaryProvider = BeneficiaryProvider();
  var beneficiariesList = <BeneficiaryModel>[].obs;
  var selectedBeneficiaryId = Rxn<int>(); // Rxn للسماح بقيمة null

  // --- ✅ جديد: مفتاح للفورم ووحدات تحكم للحقول ---
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController orderNumberController;
  late TextEditingController orderDateController;
  late TextEditingController issuingEntityController;
  late TextEditingController beneficiaryController;
  late TextEditingController notesController;
  var _allOrders = <DisbursementOrderModel>[]; // لتخزين كل الأوامر
  late TextEditingController searchController;
  var activeFilter = 'الكل'.obs;
  var selectedImagePath = ''.obs;

  // --- ✅ جديد: متغيرات لتخزين الحالة ---
  DateTime? _selectedOrderDate;
  // سيضاف متغير لمسار الصورة لاحقاً

  @override
  void onInit() {
    super.onInit();
    _initializeControllers(); // تهيئة وحدات التحكم
    fetchAllOrders();
    fetchBeneficiaries(); // ✅ جديد: جلب المستفيدين عند بدء التشغيل
  }

  void _initializeControllers() {
    orderNumberController = TextEditingController();
    orderDateController = TextEditingController();
    issuingEntityController = TextEditingController();
    beneficiaryController = TextEditingController();
    notesController = TextEditingController();
    searchController = TextEditingController(); // ✅ جديد
  }

  void fetchAllOrders() async {
    try {
      isLoading(true);
      _allOrders = await _provider.getAllOrders(); // <-- ✅ التصحيح
      _applyFilters(); // <-- ✅ التصحيح
    } catch (e) {
      Get.defaultDialog(
        title: "خطأ",
        middleText: "حدث خطأ أثناء جلب أوامر الصرف: ${e.toString()}",
      );
      print(e);
    } finally {
      isLoading(false);
    }
  }

  // --- ✅ جديد: دوال للتحكم في الحوار والحقول ---

  Future<void> openAddEditDialog({DisbursementOrderModel? orderToEdit}) async {
    await Get.dialog(
      // <-- ✅ التغيير
      Builder(
        builder: (context) => AddEditOrderDialog(orderToEdit: orderToEdit),
      ),
      barrierDismissible: false,
    );
  }

  void setupTextFieldsForEdit(DisbursementOrderModel order) {
    orderNumberController.text = order.orderNumber;
    issuingEntityController.text = order.issuingEntity ?? '';
    beneficiaryController.text =
        'مستفيد رقم ${order.beneficiaryId ?? ''}'; // مؤقت
    notesController.text = order.notes ?? '';
    updateOrderDate(order.orderDate);
    selectedImagePath.value = order.imagePath ?? '';
    selectedBeneficiaryId.value = order.beneficiaryId; // <-- ✅ التصحيح
  }

  void clearTextFields() {
    orderNumberController.clear();
    orderDateController.clear();
    issuingEntityController.clear();
    beneficiaryController.clear();
    notesController.clear();
    selectedImagePath.value = '';
    _selectedOrderDate = null;
    selectedBeneficiaryId.value = null; // <-- ✅ التصحيح
  }

  void updateOrderDate(DateTime date) {
    _selectedOrderDate = date;
    orderDateController.text = DateFormat('yyyy-MM-dd').format(date);
  }

  // --- ✅ جديد: دالة لحفظ أمر الصرف ---
  void saveOrder(DisbursementOrderModel? orderToEdit) async {
    if (formKey.currentState!.validate()) {
      final isEditMode = orderToEdit != null;

      final newOrder = DisbursementOrderModel(
        id: isEditMode ? orderToEdit.id : null,
        orderNumber: orderNumberController.text.trim(),
        orderDate: _selectedOrderDate!,
        issuingEntity: issuingEntityController.text.trim(),
        status: orderToEdit?.status ?? 'غير مستخدم', // الحالة الافتراضية
        notes: notesController.text.trim(),
        createdAt: isEditMode ? orderToEdit.createdAt : DateTime.now(),
        imagePath: selectedImagePath.value,
        beneficiaryId: selectedBeneficiaryId.value, // <-- ✅ التصحيح
      );

      try {
        if (isEditMode) {
          await _provider.updateOrder(newOrder);
        } else {
          await _provider.addOrder(newOrder);
        }
        Get.back(); // إغلاق الحوار
        fetchAllOrders(); // تحديث القائمة
        Get.defaultDialog(
          title: "نجاح",
          middleText: isEditMode
              ? "تم تعديل أمر الصرف بنجاح."
              : "تمت إضافة أمر الصرف بنجاح.",
        );
      } catch (e) {
        Get.defaultDialog(
          title: "خطأ",
          middleText: "فشل حفظ الأمر: ${e.toString()}",
        );
      }
    }
  }

  // --- ✅ جديد: دالة لحذف أمر صرف مع تأكيد ---
  void deleteOrder(int id) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText:
          "هل أنت متأكد من حذف أمر الصرف هذا؟ لا يمكن التراجع عن هذا الإجراء.",
      textConfirm: "حذف",
      textCancel: "إلغاء",
      buttonColor: Get.theme.colorScheme.error,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // إغلاق حوار التأكيد
        try {
          await _provider.deleteOrder(id);
          fetchAllOrders(); // تحديث القائمة
          Get.defaultDialog(
            title: "نجاح",
            middleText: "تم حذف أمر الصرف بنجاح.",
          );
        } catch (e) {
          Get.defaultDialog(
            title: "خطأ",
            middleText: "فشل حذف الأمر: ${e.toString()}",
          );
        }
      },
    );
  }

  void pickOrderImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      selectedImagePath.value = result.files.single.path!;
    }
  }

  void fetchBeneficiaries() async {
    try {
      beneficiariesList.assignAll(
        await _beneficiaryProvider.getAllBeneficiaries(),
      );
    } catch (e) {
      print("Error fetching beneficiaries: $e");
    }
  }

  // --- ✅ جديد: دالة لفتح حوار إضافة مستفيد جديد ---
  void openAddBeneficiaryDialog() {
    // نتأكد من أن BeneficiariesController موجود قبل استدعائه
    if (Get.isRegistered<BeneficiariesController>()) {
      final beneficiariesController = Get.find<BeneficiariesController>();
      beneficiariesController.openAddEditDialog();
    } else {
      // كحل احتياطي، يمكننا إنشاء instance جديدة إذا لم يكن موجوداً
      final beneficiariesController = Get.put(BeneficiariesController());
      beneficiariesController.openAddEditDialog();
    }
  }

  // --- ✅ جديد: دالة لتطبيق الفلترة والبحث ---
  void _applyFilters() {
    var filtered = _allOrders.where((order) {
      // 1. Filter by Status
      if (activeFilter.value != 'الكل' && order.status != activeFilter.value) {
        return false;
      }

      // 2. Filter by Search Keyword
      final keyword = searchController.text.trim().toLowerCase();
      if (keyword.isNotEmpty) {
        final matchesNumber = order.orderNumber.toLowerCase().contains(keyword);
        final matchesEntity =
            order.issuingEntity?.toLowerCase().contains(keyword) ?? false;

        // يمكننا أيضاً البحث باسم المستفيد إذا أردنا:
        // final beneficiaryName = getBeneficiaryNameById(order.beneficiaryId).toLowerCase();
        // final matchesBeneficiary = beneficiaryName.contains(keyword);

        if (!matchesNumber && !matchesEntity) {
          return false; // && !matchesBeneficiary
        }
      }

      return true;
    }).toList();

    ordersList.assignAll(filtered);
  }

  void onSearchChanged(String value) {
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    _applyFilters();
  }

  void changeFilter(String newFilter) {
    activeFilter.value = newFilter;
    _applyFilters();
  }

  // --- ✅ جديد: دالة لجلب اسم المستفيد من الـ ID بأمان ---
  String getBeneficiaryNameById(int? id) {
    if (id == null) return 'غير محدد';

    // استخدام firstWhereOrNull لتجنب StateError إذا تم حذف المستفيد
    final beneficiary = beneficiariesList.firstWhere(
      (b) => b.id == id,
      orElse: () => BeneficiaryModel(
        id: -1,
        name: 'مستفيد محذوف',
        notes: '',
        createdAt: DateTime.now(),
      ),
    );

    return beneficiary.name;
  }

  void showOrderDetails(DisbursementOrderModel order) {
    Get.dialog(OrderDetailsDialog(order: order), barrierDismissible: true);
  }

  // --- ✅ جديد: جلب كل أوامر الصرف لمستفيد معين ---
  List<DisbursementOrderModel> getOrdersForBeneficiary(int beneficiaryId) {
    return _allOrders
        .where((order) => order.beneficiaryId == beneficiaryId)
        .toList();
  }

  // --- ✅ جديد: طباعة تقرير بأمر الصرف (فاتورة/سند) ---
  void printOrderReport(DisbursementOrderModel order) async {
    try {
      // 1. جلب العمليات المرتبطة بهذا الأمر
      final transactionProvider = Get.put(TransactionProvider());
      final transactions = await transactionProvider.getTransactionsForOrder(
        order.id!,
      );

      if (transactions.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'لا توجد أصناف منصرفة في هذا الأمر لطباعتها',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // 2. تحميل الإعدادات
      final settingsService = ReportSettingsService();
      final settings = settingsService.loadSettings();

      final beneficiaryName = getBeneficiaryNameById(order.beneficiaryId);

      // 3. فتح المعاينة
      Get.dialog(
        PrintPreviewDialog(
          initialSettings: settings,
          initialRecipientName: beneficiaryName, // Auto-fill recipient name
          pdfBuilder: (settings, suffix) async {
            return ItemReportGenerator.generateOrderReportPdf(
              transactions,
              beneficiaryName,
              order.orderNumber,
              settings: settings,
              recipientSuffix: suffix,
            );
          },
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.defaultDialog(
        title: "خطأ",
        middleText: "حدث خطأ أثناء إعداد السند: $e",
      );
    }
  }

  @override
  void onClose() {
    orderNumberController.dispose();
    orderDateController.dispose();
    issuingEntityController.dispose();
    beneficiaryController.dispose();
    notesController.dispose();
    searchController.dispose(); // <-- ✅ التصحيح
    super.onClose();
  }
}
