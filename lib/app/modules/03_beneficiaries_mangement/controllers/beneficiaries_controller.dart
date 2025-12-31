import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medistock/app/data/local/models/beneficiary_model.dart';
import 'package:medistock/app/data/local/providers/beneficiary_provider.dart';
import 'package:medistock/app/data/local/providers/transaction_provider.dart'; // ✅ Added
import 'package:medistock/app/core/services/report_settings_service.dart'; // ✅ Added
import 'package:medistock/app/core/utils/item_report_generator.dart'; // ✅ Added
import '../../01_items_management/views/print_preview_dialog.dart'; // ✅ Added

import '../../02_orders_management/controllers/orders_controller.dart';

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
      AlertDialog(
        title: Text(beneficiary == null ? 'إضافة مستفيد جديد' : 'تعديل مستفيد'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المستفيد'),
                validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: typeController,
                decoration: const InputDecoration(
                  labelText: 'النوع (مثال: كتيبة)',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: identifierController,
                decoration: const InputDecoration(
                  labelText: 'الرقم التعريفي (إن وجد)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => saveBeneficiary(beneficiary),
            child: const Text('حفظ'),
          ),
        ],
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
    List<BeneficiaryModel> filteredList = List.from(_allBeneficiaries);

    // تطبيق فلتر البحث النصي
    final keyword = searchController.text.trim().toLowerCase();
    if (keyword.isNotEmpty) {
      filteredList = filteredList
          .where(
            (b) =>
                b.name.toLowerCase().contains(keyword) ||
                (b.type?.toLowerCase().contains(keyword) ?? false) ||
                (b.identifier?.toLowerCase().contains(keyword) ?? false),
          )
          .toList();
    }

    beneficiariesList.assignAll(filteredList);
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

  @override
  void onClose() {
    nameController.dispose();
    typeController.dispose();
    identifierController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
