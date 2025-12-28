import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medistock/app/data/local/db/database_handler.dart'; // ✅ جديد: للوصول إلى قاعدة البيانات مباشرة
import 'package:medistock/app/data/local/models/disbursement_order_model.dart';
import 'package:medistock/app/data/local/models/item_model.dart';
import 'package:medistock/app/data/local/models/transaction_model.dart';
import 'package:medistock/app/data/local/providers/item_provider.dart';
import 'package:medistock/app/data/local/providers/order_provider.dart';
import 'package:medistock/app/data/local/providers/transaction_provider.dart';
import 'package:medistock/app/modules/04_transactions_management/views/add_transaction_dialog.dart';
import '../../00_dashboard/controllers/dashboard_controller.dart';
import '../../01_items_management/controllers/items_controller.dart';
import '../../02_orders_management/controllers/orders_controller.dart';
import 'package:medistock/app/data/local/models/return_transaction_model.dart';
import 'package:medistock/app/data/local/providers/return_transaction_provider.dart';


import '../views/transaction_details_dialog.dart';

class TransactionsController extends GetxController {
  // --- ✅ جديد: جلب كل الـ Providers اللازمة ---
  final TransactionProvider _transactionProvider = TransactionProvider();
  final OrderProvider _orderProvider = OrderProvider();
  final ItemProvider _itemProvider = ItemProvider();
  final ReturnTransactionProvider _returnProvider = ReturnTransactionProvider(); // ✅ جديد
  late TextEditingController returnQuantityController;
  late TextEditingController returnReasonController;
  final formKeyReturn = GlobalKey<FormState>();
  var returnedTransactionsInfo = <int, int>{}.obs; // Map<originalTransactionId, totalReturnedQuantity>
  // --- ✅ جديد: متغيرات البحث والفلترة ---
  var _allTransactions = <TransactionModel>[];
  late TextEditingController searchController;
  var activeDateFilter = 'الكل'.obs;
  var activeStatusFilter = 'الكل'.obs; // <-- ✅ جديد: أضف هذا المتغير

  var transactionsList = <TransactionModel>[].obs;
  var isLoading = true.obs;

  // --- ✅ جديد: متغيرات حالة الحوار متعدد الخطوات ---
  var currentStep = 0.obs;
  final formKeyStep1 = GlobalKey<FormState>();
  final formKeyStep2 = GlobalKey<FormState>();
  var _allOrders = <DisbursementOrderModel>[]; // ✅ جديد: لتخزين كل الأوامر

  // --- متغيرات الخطوة 1: اختيار أمر الصرف ---
  var availableOrders = <DisbursementOrderModel>[].obs;
  var selectedOrderId = Rxn<int>();

  // --- متغيرات الخطوة 2: إضافة الأصناف ---
  var allItems = <ItemModel>[].obs; // كل الأصناف المتاحة للصرف
  var selectedItemId = Rxn<int>();
  late TextEditingController quantityController;

  // قائمة الأصناف المؤقتة التي سيتم صرفها في هذه العملية
  var itemsToDisburse = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    quantityController = TextEditingController();
    fetchAllTransactions();
    // جلب البيانات اللازمة للحوار
    _fetchPrerequisites();
    _initializeControllers();
  }


  // الدالة الجديدة
  void _initializeControllers() {
    quantityController = TextEditingController();
    searchController = TextEditingController(); // ✅ جديد
    returnQuantityController = TextEditingController(); // ✅ جديد
    returnReasonController = TextEditingController(); // ✅
  }

  void _fetchPrerequisites() async {
    try {
      // ✅جديد: جلب كل الأوامر وتخزينها
      _allOrders = await _orderProvider.getAllOrders();

      // ✅ جديد: فلترة الأوامر المتاحة من القائمة الكاملة
      availableOrders.assignAll(_allOrders.where((o) => o.status == 'غير مستخدم'));

      // جلب كل الأصناف المتوفرة
      allItems.assignAll(await _itemProvider.getAllItems());
    } catch (e) {
      debugPrint("Error fetching prerequisites: $e");
    }
  }

  void fetchAllTransactions() async {
    try {
      isLoading(true);

      // جلب العمليات بشكل متوازي
      final transactionsFuture = _transactionProvider.getAllTransactions();
      final returnsFuture = _returnProvider.getAllReturnTransactions();

      final List<TransactionModel> transactionsResult = await transactionsFuture;
      final List<ReturnTransactionModel> returnsResult = await returnsFuture;

      // --- ✅ جديد: معالجة بيانات الإرجاع ---
      // بناء Map لتخزين إجمالي الكمية المرتجعة لكل عملية صرف أصلية
      returnedTransactionsInfo.clear();
      for (var returnedItem in returnsResult) {
        final originalId = returnedItem.originalTransactionId;
        final quantity = returnedItem.quantityReturned;
        returnedTransactionsInfo[originalId] = (returnedTransactionsInfo[originalId] ?? 0) + quantity;
      }

      _allTransactions = transactionsResult;
      _applyFilters();

    } catch (e) {
      Get.defaultDialog(title: "خطأ", middleText: "فشل جلب سجل العمليات: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  // --- ✅ جديد: دوال التحكم في الحوار ---
  void openAddTransactionDialog() {
    // إعادة تعيين كل شيء إلى الحالة الأولية عند فتح الحوار
    currentStep.value = 0;
    selectedOrderId.value = null;
    itemsToDisburse.clear();
    quantityController.clear();
    selectedItemId.value = null;
    _fetchPrerequisites(); // تحديث القوائم

    Get.dialog(
      const AddTransactionDialog(),
      barrierDismissible: false,
    );
  }

  void nextStep() {
    if (currentStep.value == 0) {
      // التحقق من اختيار أمر صرف
      if (selectedOrderId.value != null) {
        currentStep.value++;
      } else {
        Get.snackbar('تنبيه', 'الرجاء اختيار أمر صرف للمتابعة');
      }
    } else if (currentStep.value == 1) {
      // تنفيذ عملية الصرف النهائية
      executeTransaction();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // --- ✅ جديد: دوال لإدارة الأصناف المؤقتة ---
  void addItemToDisbursementList() {
    if (selectedItemId.value == null || quantityController.text.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء اختيار صنف وإدخال الكمية');
      return;
    }
    final quantity = int.tryParse(quantityController.text);
    if (quantity == null || quantity <= 0) {
      Get.snackbar('خطأ', 'الرجاء إدخال كمية صحيحة');
      return;
    }

    final item = allItems.firstWhere((i) => i.id == selectedItemId.value);

    // التحقق من الكمية المتاحة
    if (quantity > item.quantity) {
      Get.snackbar('خطأ', 'الكمية المطلوبة ($quantity}) أكبر من الكمية المتاحة (${item.quantity})');
      return;
    }

    // إضافة الصنف للقائمة المؤقتة
    itemsToDisburse.add({
      'item': item,
      'quantity': quantity,
    });

    // تفريغ الحقول
    selectedItemId.value = null;
    quantityController.clear();
  }

  void removeItemFromList(int itemId) {
    itemsToDisburse.removeWhere((map) => (map['item'] as ItemModel).id == itemId);
  }

  // --- ✅ جديد: الدالة الأهم لتنفيذ عملية الصرف ---
  Future<void> executeTransaction() async {
    if (itemsToDisburse.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء إضافة صنف واحد على الأقل لعملية الصرف');
      return;
    }

    final db = await DatabaseHandler.instance.database;
    try {
      // بدء حركة ذرية (Transaction)
      await db.transaction((txn) async {
        for (var entry in itemsToDisburse) {
          final ItemModel item = entry['item'];
          final int quantityDisbursed = entry['quantity'];

          // 1. إضافة سجل في جدول العمليات
          final transaction = TransactionModel(
            transactionDate: DateTime.now(),
            itemId: item.id!,
            quantityDisbursed: quantityDisbursed,
            orderId: selectedOrderId.value!,
          );
          await txn.insert('disbursement_transactions', transaction.toMap());

          // 2. تحديث (إنقاص) الكمية في جدول الأصناف
          final newQuantity = item.quantity - quantityDisbursed;
          await txn.update(
            'items',
            {'quantity': newQuantity},
            where: 'id = ?',
            whereArgs: [item.id],
          );
        }

        // 3. تحديث حالة أمر الصرف إلى "مستخدم"
        await txn.update(
          'disbursement_orders',
          {'status': 'مستخدم'},
          where: 'id = ?',
          whereArgs: [selectedOrderId.value],
        );
      });

      // إذا نجحت كل العمليات
      Get.back(); // إغلاق حوار الصرف
      Get.defaultDialog(title: "نجاح", middleText: "تم تنفيذ عملية الصرف بنجاح.");
      // تحديث كل الواجهات المتأثرة
      fetchAllTransactions();
      if (Get.isRegistered<ItemsController>()) {
        Get.find<ItemsController>().fetchAllItems();
      }
    } catch (e) {
      Get.defaultDialog(title: "خطأ فادح", middleText: "فشل تنفيذ عملية الصرف: ${e.toString()}");
    }
  }

  // --- ✅ جديد: دوال مساعدة لجلب التفاصيل للعرض ---

  String getItemNameById(int id) {
    // ابحث في قائمة الأصناف التي تم جلبها
    final item = allItems.firstWhere((item) => item.id == id,
        orElse: () =>
            ItemModel(
              name: 'صنف محذوف',
              expiryDate: DateTime.now(),
              quantity: 0,
              createdAt: DateTime.now(),
            ));
    return item.name;
  }

  String getOrderNumberById(int id) {
    // ابحث في قائمة أوامر الصرف التي تم جلبها
    final order = _allOrders.firstWhere((order) => order.id == id,
        orElse: () =>
            DisbursementOrderModel(
                orderNumber: 'أمر محذوف',
                orderDate: DateTime.now(),
                status: '',
              createdAt: DateTime.now(),
            ));
    return order.orderNumber;
  }

  // --- ✅ جديد: دالة لفتح حوار إضافة أمر صرف من داخل هذا الحوار ---
  void openAddOrderDialog() async {
    // نتأكد من أن OrdersController موجود
    if (!Get.isRegistered<OrdersController>()) {
      Get.put(OrdersController());
    }
    final ordersController = Get.find<OrdersController>();
    await ordersController.openAddEditDialog();
    // --- الأهم: بعد إغلاق الحوار، قم بتحديث قائمة أوامر الصرف المتاحة ---
    _fetchPrerequisites();
  }

  // --- ✅ جديد: دالة لتطبيق الفلترة والبحث ---
  void _applyFilters() {
    List<TransactionModel> filteredList = List.from(_allTransactions);

    // --- الخطوة 1: تطبيق فلتر الحالة (مرتجع / غير مرتجع) ---
    switch (activeStatusFilter.value) {
      case 'مرتجع':
        filteredList = filteredList.where((t) => returnedTransactionsInfo.containsKey(t.id)).toList();
        break;
      case 'غير مرتجع':
        filteredList = filteredList.where((t) => !returnedTransactionsInfo.containsKey(t.id)).toList();
        break;
    // case 'الكل': لا تفعل شيئاً
    }

    // --- الخطوة 2: تطبيق فلتر التاريخ ---
    final now = DateTime.now();
    switch (activeDateFilter.value) {
      case 'اليوم':
        filteredList = filteredList.where((t) =>
        t.transactionDate.year == now.year &&
            t.transactionDate.month == now.month &&
            t.transactionDate.day == now.day).toList();
        break;
      case 'آخر 7 أيام':
        final weekAgo = now.subtract(const Duration(days: 7));
        filteredList = filteredList.where((t) => t.transactionDate.isAfter(weekAgo)).toList();
        break;
      case 'هذا الشهر':
        filteredList = filteredList.where((t) =>
        t.transactionDate.year == now.year &&
            t.transactionDate.month == now.month).toList();
        break;
    // case 'الكل': لا تفعل شيئاً
    }

    // --- الخطوة 3: تطبيق فلتر البحث النصي (باسم الصنف) ---
    final keyword = searchController.text.trim().toLowerCase();
    if (keyword.isNotEmpty) {
      filteredList = filteredList.where((t) {
        final itemName = getItemNameById(t.itemId).toLowerCase();
        return itemName.contains(keyword);
      }).toList();
    }

    transactionsList.assignAll(filteredList);
  }
  // --- ✅ جديد: دوال للتحكم من الواجهة ---
  void onSearchChanged(String value) {
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    _applyFilters();
  }

  void changeDateFilter(String newFilter) {
    activeDateFilter.value = newFilter;
    _applyFilters();
  }
  void changeStatusFilter(String newFilter) {
    activeStatusFilter.value = newFilter;
    _applyFilters();
  }
  // --- ✅ جديد: دوال للحصول على الكائنات الكاملة ---
  ItemModel? getItemById(int id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  DisbursementOrderModel? getOrderById(int id) {
    try {
      return _allOrders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // --- ✅ جديد: دالة لفتح حوار التفاصيل ---
  void showTransactionDetails(TransactionModel transaction) {
    Get.dialog(
      TransactionDetailsDialog(transaction: transaction),
      barrierDismissible: true,
    );
  }

  // --- ✅ جديد: دالة لجلب اسم المستفيد من الـ ID ---
  String getBeneficiaryNameById(int? id) {
    if (id == null) return 'غير محدد';
    try {

      if (Get.isRegistered<OrdersController>()) {
    final ordersController = Get.find<OrdersController>();
    return ordersController.getBeneficiaryNameById(id);
      }
      return '...'; // نص مؤقت إذا لم يتم العثور على الـ Controller
    } catch (e) {
      return 'مستفيد محذوف';
    }
  }

  // --- ✅ جديد: الدالة الأهم لتنفيذ عملية الإرجاع ---
  Future<void> executeReturnTransaction(
      TransactionModel originalTransaction) async {
    if (!formKeyReturn.currentState!.validate()) return;

    final quantityToReturn = int.parse(returnQuantityController.text);
    final reason = returnReasonController.text.trim();
    final item = getItemById(originalTransaction.itemId);

    if (item == null) {
      Get.defaultDialog(
          title: "خطأ", middleText: "الصنف الأصلي لم يعد موجوداً.");
      return;
    }

    final db = await DatabaseHandler.instance.database;
    try {
      // بدء حركة ذرية (Transaction)
      await db.transaction((txn) async {
        // 1. إضافة سجل في جدول عمليات الإرجاع
        final returnTransaction = ReturnTransactionModel(
          returnDate: DateTime.now(),
          originalTransactionId: originalTransaction.id!,
          quantityReturned: quantityToReturn,
          reason: reason,
        );
        await txn.insert('return_transactions', returnTransaction.toMap());

        // 2. تحديث (زيادة) كمية الصنف في جدول الأصناف
        final newQuantity = item.quantity + quantityToReturn;
        await txn.update(
          'items',
          {'quantity': newQuantity},
          where: 'id = ?',
          whereArgs: [item.id],
        );
      });

      // إذا نجحت كل العمليات
      Get.back(); // إغلاق حوار الإرجاع
      Get.defaultDialog(title: "نجاح", middleText: "تم إرجاع الصنف بنجاح.");
      fetchAllTransactions();

      // تحديث كل الواجهات المتأثرة
      _fetchPrerequisites(); // لتحديث كميات الأصناف المتاحة
      if (Get.isRegistered<ItemsController>()) {
        Get.find<ItemsController>().fetchAllItems();
      }
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchDashboardData();
      }
    } catch (e) {
      Get.defaultDialog(title: "خطأ فادح",
          middleText: "فشل تنفيذ عملية الإرجاع: ${e.toString()}");
    }
  }

  // --- ✅ جديد: دالة لفتح حوار إرجاع الصنف ---
  void openReturnDialog(TransactionModel originalTransaction) async {
    // تفريغ الحقول قبل فتح الحوار
    returnQuantityController.clear();
    returnReasonController.clear();

    // حساب الكميةالتي يمكن إرجاعها
    final alreadyReturned =
    await _returnProvider.getReturnedQuantityForTransaction(
        originalTransaction.id!);
    final maxReturnable =
        originalTransaction.quantityDisbursed - alreadyReturned;

    if (maxReturnable <= 0) {
      Get.defaultDialog(
          title: "مكتمل",
          middleText: "تم إرجاع كل الكمية المصروفة من هذا الصنف بالفعل.");
      return;
    }

    Get.dialog(AlertDialog(
        title: const Text('إرجاع صنف'),
        content: Form(
            key: formKeyReturn,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Text("الكمية القصوى الممكن إرجاعها: $maxReturnable"),
            const SizedBox(height: 16),
            TextFormField(
                controller: returnQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'الكمية المرتجعة', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'أدخلكمية صحيحة';
                  }
                  if (quantity > maxReturnable) {
                    return 'لا يمكن إرجاع أكثر من $maxReturnable';
                  }
                  return null;
                },
            ),
            const SizedBox(height: 16),
                  TextFormField(
                    controller: returnReasonController,
                    decoration: const InputDecoration(
                        labelText: 'سبب الإرجاع (اختياري)',
                        border: OutlineInputBorder()),
                  ),
                ],
            ),
        ),
        actions: [TextButton(
            onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => executeReturnTransaction(originalTransaction),
            child: const Text('تنفيذ الإرجاع'),
          ),
        ],
    ),
    );
  }
  // --- ✅ جديد: دالة مساعدة لمعرفة حالة الإرجاع ---
  String getReturnStatusForTransaction(TransactionModel transaction) {
    final returnedQty = returnedTransactionsInfo[transaction.id] ?? 0;

  if (returnedQty == 0) {
    return 'لم يرجع';
  } else if (returnedQty >= transaction.quantityDisbursed) {
    return 'مرتجع بالكامل';
  } else {
    return 'مرتجع جزئياً';
  }
  }
  // --- ✅ جديد: دالة للحصول على الكمية المرتجعة ---
  int getReturnedQuantity(int originalTransactionId) {
    return returnedTransactionsInfo[originalTransactionId] ?? 0;
  }


  @override
  void onClose() {
    quantityController.dispose();
    searchController.dispose();
    returnQuantityController.dispose();
    returnReasonController.dispose();
    super.onClose();
  }
}
