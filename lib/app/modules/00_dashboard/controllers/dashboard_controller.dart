import 'package:get/get.dart';
import 'package:medistock/app/data/local/models/item_model.dart';
import 'package:medistock/app/data/local/models/transaction_model.dart';
import 'package:medistock/app/data/local/providers/item_provider.dart';
import 'package:medistock/app/data/local/providers/transaction_provider.dart';

class DashboardController extends GetxController {
  final ItemProvider _itemProvider = ItemProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();

  var isLoading = true.obs;

  // --- متغيرات الكروت الإحصائية ---
  var totalItemsCount = 0.obs;
  var lowStockCount = 0.obs;
  var expiringSoonCount = 0.obs;
  var expiredCount = 0.obs;
  var outOfStockCount = 0.obs; // ✅ جديد: لكرت الإحصاء

  // --- متغيرات قوائم التنبيهات ---
  var expiringSoonItems = <ItemModel>[].obs;
  var lowStockItems = <ItemModel>[].obs;
  var expiredItems = <ItemModel>[].obs; // ✅ جديد: قائمة الأصناف المنتهية
  var outOfStockItems = <ItemModel>[].obs; // ✅ جديد: قائمة الأصناف النافدة

  // --- متغيرات الرسم البياني والجدول السريع ---
  var recentTransactions = <TransactionModel>[].obs;
  var allItems = <ItemModel>[].obs; // لتسهيل الحصول على اسم الصنف

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  @override
  void onReady() {
    super.onReady();
    ever(Get.routing.obs, (routing) {
      if (routing.current == '/') {
        print('Returned to Dashboard. Fetching data...'); // لغرض الاختبار
        fetchDashboardData();
      }
    });
  }

  void fetchDashboardData() async {
    try {
      isLoading(true);

      // جلب البيانات بشكل متوازي لتحسين الأداء
      final futureItems = _itemProvider.getAllItems();
      final futureTransactions = _transactionProvider.getAllTransactions();

      // انتظار اكتمال العمليتين
      final allItemsResult = await futureItems;
      final allTransactionsResult = await futureTransactions;

      allItems.assignAll(allItemsResult);

      // --- حساب الإحصائيات ---
      totalItemsCount.value = allItemsResult.length;
      final ninetyDaysFromNow = DateTime.now().add(const Duration(days: 90));

      expiringSoonItems.assignAll(allItemsResult.where((item) =>
      !item.expiryDate.isBefore(DateTime.now()) &&
          item.expiryDate.isBefore(ninetyDaysFromNow)).toList());
      expiringSoonCount.value = expiringSoonItems.length;

      lowStockItems.assignAll(allItemsResult.where((item) =>
      item.quantity > 0 && item.quantity <= item.alertLimit).toList());
      lowStockCount.value = lowStockItems.length;

      expiredCount.value = allItemsResult
          .where((item) => item.expiryDate.isBefore(DateTime.now()))
          .length;
      expiredItems.assignAll(allItemsResult.where((item) =>
          item.expiryDate.isBefore(DateTime.now())).toList()); // ✅
      expiredCount.value = expiredItems.length;
      outOfStockItems.assignAll(allItemsResult.where((item) => item.quantity == 0).toList()); // ✅ جديد
      outOfStockCount.value = outOfStockItems.length; // ✅ جديد


      // --- إعداد بيانات الجدول السريع ---
      // عرض آخر 5 عمليات فقط
      recentTransactions.assignAll(allTransactionsResult.take(5).toList());
    } catch (e) {
      print("Failed to load dashboard data: $e");
    } finally {
      isLoading(false);
    }
  }

  // دالة مساعدة للحصول على اسم الصنف من الـ ID
  String getItemNameById(int id) {
    try {
      return allItems
          .firstWhere((item) => item.id == id)
          .name;
    } catch (e) {
      return 'صنف محذوف';
    }
  }
}