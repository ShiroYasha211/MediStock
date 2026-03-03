import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medistock/app/data/local/models/beneficiary_model.dart';
import 'package:medistock/app/data/local/providers/beneficiary_provider.dart';
import 'package:medistock/app/data/local/providers/transaction_provider.dart';
import 'package:medistock/app/core/services/report_settings_service.dart';
import 'package:medistock/app/core/utils/item_report_generator.dart';
import '../../01_items_management/views/print_preview_dialog.dart';

import '../../02_orders_management/controllers/orders_controller.dart';
import '../views/beneficiaries_view.dart'; // ✅ Added to access BeneficiaryOrdersDialog

class BeneficiariesController extends GetxController {
  final BeneficiaryProvider _provider = BeneficiaryProvider();

  var beneficiariesList = <BeneficiaryModel>[].obs;
  var isLoading = true.obs;

  // وحدات تحكم لحوار الإضافة والتعديل
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController identifierController;
  var _allBeneficiaries = <BeneficiaryModel>[];
  late TextEditingController searchController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    typeController = TextEditingController();
    identifierController = TextEditingController();
    searchController = TextEditingController(); // ✅ جديد
    fetchAllBeneficiaries();
  }

  void fetchAllBeneficiaries() async {
    try {
      isLoading(true);
      _allBeneficiaries = await _provider.getAllBeneficiaries();
      _applyFilters();
    } catch (e) {
      Get.defaultDialog(title: "خطأ", middleText: "فشل جلب قائمة المستفيدين.");
    } finally {
      isLoading(false);
    }
  }

  void openAddEditDialog({BeneficiaryModel? beneficiary}) {
    // ملء الحقول في حالة التعديل
    if (beneficiary != null) {
      nameController.text = beneficiary.name;
      typeController.text = beneficiary.type ?? '';
      identifierController.text = beneficiary.identifier ?? '';
    } else {
      // تفريغ الحقول في حالة الإضافة
      nameController.clear();
      typeController.clear();
      identifierController.clear();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Get.theme.colorScheme.surface,
        child: Container(
          width: 450, // عرض ثابت مناسب للحوار
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Get.theme.colorScheme.surface,
                Get.theme.colorScheme.surface.withOpacity(0.95),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      beneficiary == null
                          ? Icons.person_add_alt_1_rounded
                          : Icons.manage_accounts_rounded,
                      color: Get.theme.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      beneficiary == null
                          ? 'إضافة مستفيد جديد'
                          : 'تعديل بيانات المستفيد',
                      style: Get.theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Get.theme.primaryColor,
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
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'اسم المستفيد',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'هذا الحقل مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: typeController,
                        decoration: InputDecoration(
                          labelText: 'النوع (مثال: كتيبة، فرد...)',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: identifierController,
                        decoration: InputDecoration(
                          labelText: 'الرقم التعريفي (إن وجد)',
                          prefixIcon: const Icon(Icons.numbers_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Footer ---
              const Divider(height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
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
                      onPressed: () => saveBeneficiary(beneficiary),
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
                        'حفظ البيانات',
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
      ),
    );
  }

  void saveBeneficiary(BeneficiaryModel? beneficiary) async {
    if (formKey.currentState!.validate()) {
      final newBeneficiary = BeneficiaryModel(
        id: beneficiary?.id,
        name: nameController.text,
        type: typeController.text,
        identifier: identifierController.text,
        createdAt: beneficiary?.createdAt ?? DateTime.now(),
      );
      try {
        if (beneficiary == null) {
          await _provider.addBeneficiary(newBeneficiary);
        } else {
          await _provider.updateBeneficiary(newBeneficiary);
        }
        Get.back();
        fetchAllBeneficiaries();
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().fetchBeneficiaries();
        }
        Get.defaultDialog(title: "نجاح", middleText: "تم الحفظ بنجاح.");
      } catch (e) {
        Get.defaultDialog(
          title: "خطأ",
          middleText: "فشل الحفظ: قد يكون الاسم مكرراً.",
        );
      }
    }
  }

  void deleteBeneficiary(int id) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل أنت متأكد منحذف هذا المستفيد؟",
      textConfirm: "حذف",
      textCancel: "إلغاء",
      onConfirm: () async {
        Get.back();
        try {
          await _provider.deleteBeneficiary(id);
          fetchAllBeneficiaries();
          // تحديث قائمةالمستفيدين في شاشة أوامر الصرف أيضاً
          if (Get.isRegistered<OrdersController>()) {
            Get.find<OrdersController>().fetchBeneficiaries();
          }
          Get.defaultDialog(title: "نجاح", middleText: "تم الحذف بنجاح.");
        } catch (e) {
          Get.defaultDialog(
            title: "خطأ",
            middleText:
                "فشل الحذف: قد يكون هذا المستفيد مستخدماً في أحد أوامر الصرف.",
          );
        }
      },
    );
  }

  void _applyFilters() {
    final keyword = searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      beneficiariesList.assignAll(_allBeneficiaries);
      return;
    }

    // تطبيق فلتر البحث النصي مباشرة عبر where لتحسين الأداء
    final filtered = _allBeneficiaries.where((b) {
      return b.name.toLowerCase().contains(keyword) ||
          (b.type?.toLowerCase().contains(keyword) ?? false) ||
          (b.identifier?.toLowerCase().contains(keyword) ?? false);
    }).toList();

    beneficiariesList.assignAll(filtered);
  }

  void onSearchChanged(String value) {
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    _applyFilters();
  }

  // --- ✅ جديد: طباعة تقرير المستفيد ---
  void printReport(BeneficiaryModel beneficiary) async {
    try {
      // 1. جلب العمليات
      // نحتاج للوصول لـ TransactionProvider. يمكننا استخدامه مباشرة أو حقنه.
      // للتبسيط سأقوم بإنشاء instance هنا أو الوصول للـ Provider العام إن وجد.
      // بما أن TransactionProvider موجود في data layer، سأستنشئه.
      // (الأفضل استخدام Get.find لاحقاً إذا قمنا بتسجيله)
      final transactionProvider = Get.put(
        TransactionProvider(),
      ); // Lazy put likely better but this works for now
      final transactions = await transactionProvider
          .getTransactionsForBeneficiary(beneficiary.id!);

      if (transactions.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'لا توجد عمليات صرف لهذا المستفيد لطباعتها',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // 2. تحميل الإعدادات
      final settingsService = ReportSettingsService();
      final settings = settingsService.loadSettings();

      // 3. فتح المعاينة
      Get.dialog(
        PrintPreviewDialog(
          initialSettings: settings,
          initialRecipientName: beneficiary.name, // Auto-fill recipient name
          pdfBuilder: (settings, suffix) async {
            return ItemReportGenerator.generateBeneficiaryReportPdf(
              transactions,
              beneficiary.name,
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
        middleText: "حدث خطأ أثناء إعداد التقرير: $e",
      );
    }
  }

  // --- ✅ جديد: عرض سجل أوامر الصرف للمستفيد ---
  void showBeneficiaryOrders(BeneficiaryModel beneficiary) {
    // 1. Get OrdersController to fetch orders
    late final OrdersController ordersController;
    if (Get.isRegistered<OrdersController>()) {
      ordersController = Get.find<OrdersController>();
    } else {
      ordersController = Get.put(OrdersController());
    }

    // 2. Fetch the orders for this beneficiary
    final orders = ordersController.getOrdersForBeneficiary(beneficiary.id!);

    // 3. Show dialog
    Get.dialog(
      BeneficiaryOrdersDialog(
        beneficiary: beneficiary,
        orders: orders,
        ordersController: ordersController,
      ),
      barrierDismissible: true,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    typeController.dispose();
    identifierController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
