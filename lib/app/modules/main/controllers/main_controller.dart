import 'package:get/get.dart';

class MainController extends GetxController {
  // متغير لتتبع مؤشر الصفحة المختارة حاليًا
  var selectedIndex = 0.obs;

  // --- جديد: متغير لتتبع حالة القائمة الجانبية (ممتدة أم مطوية) ---
  var isRailExtended = true.obs;

  // دالة لتغيير الصفحة عند الضغط على أيقونة في شريط التنقل
  void changePage(int index) {
    selectedIndex.value = index;
  }

  // --- جديد: دالة لطي أو إظهار القائمة الجانبية ---
  void toggleRail() {
    isRailExtended.value = !isRailExtended.value;
  }
}
