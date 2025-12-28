import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/local/models/item_model.dart';
import '../controllers/dashboard_controller.dart';

// --- ✅ الحل: تحويل الواجهة إلى StatefulWidget لمراقبة دورة حياة التطبيق ---
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with WidgetsBindingObserver {
  // نحصل على الـ controller مرة واحدة
  final DashboardController controller = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    // تسجيل الـ observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // إزالة الـ observer عند إغلاق الواجهة
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // عندما يعود التطبيق إلى الواجهة، قم بتحديث البيانات
    if (state == AppLifecycleState.resumed) {
      print("App resumed. Refreshing dashboard...");
      controller.fetchDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          // --- ✅ إضافة: السحب للتحديث ---

          onRefresh: () async => controller.fetchDashboardData(),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // --- ✅ إضافة: زر التحديث اليدوي ---
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'تحديث البيانات',
                  onPressed: () => controller.fetchDashboardData(),
                ),
              ),
              const SizedBox(height: 8),
              _buildStatsRow(controller, theme),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildAlertsSection(controller, theme),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 3,
                    child: _buildChartsAndRecentActivitySection(
                        controller, theme),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // ... باقي دوال بناء الواجهة (_buildStatsRow, _buildInfoCard, etc.) تبقى كما هي تماماً ...
  // (لقد قمت بنسخها هنا للتأكد من أن الكود كامل وسليم)

  Widget _buildStatsRow(DashboardController controller, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard('إجمالي الأصناف', controller.totalItemsCount,
              Icons.inventory_2_outlined, theme.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard('قارب على النفاذ', controller.lowStockCount,
              Icons.warning_amber_rounded, Colors.orange.shade700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
              'قارب على الانتهاء', controller.expiringSoonCount,
              Icons.hourglass_bottom_outlined, Colors.blue.shade700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard('انتهت الصلاحية', controller.expiredCount,
              Icons.event_busy_outlined, theme.colorScheme.error),

        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard('نفدت من المخزون', controller.outOfStockCount,
              Icons.remove_shopping_cart_outlined,
              theme.colorScheme.error.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, RxInt value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(radius: 20,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade600)),
                Obx(() =>
                    Text(value.value.toString(), style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(DashboardController controller, ThemeData theme) {
    return Column(
      children: [
        Obx(() =>
            _buildAlertList(
                'أصناف قاربت على الانتهاء', controller.expiringSoonItems,
                Icons.hourglass_bottom_outlined, Colors.blue.shade700, (
                item) => 'تاريخ الانتهاء: ${DateFormat('yyyy-MM-dd').format(
                item.expiryDate)}')),
        const SizedBox(height: 20),
        Obx(() =>
            _buildAlertList('أصناف قاربت على النفاذ', controller.lowStockItems,
                Icons.warning_amber_rounded, Colors.orange.shade700, (
                    item) => 'الكمية المتبقية: ${item.quantity}')),
        const SizedBox(height: 20),
        Obx(() =>
            _buildAlertList(
                'أصناف انتهت صلاحيتها',
                controller.expiredItems,
                Icons.event_busy_outlined,
                theme.colorScheme.error,
                    (item) => 'تاريخ الانتهاء: ${DateFormat('yyyy-MM-dd')
                    .format(item.expiryDate)}')),

        // --- ✅ جديد: إضافة قائمة الأصناف النافدة ---
        const SizedBox(height: 20),
        Obx(() =>
            _buildAlertList(
                'أصناف نفدت من المخزون',
                controller.outOfStockItems,
                Icons.remove_shopping_cart_outlined,
                theme.colorScheme.error.withOpacity(0.8),
                    (item) => 'نفدت الكمية في: ${DateFormat('yyyy-MM-dd')
                    .format(
                    item.createdAt)}' // يمكناستخدام تاريخ آخر تحديث لاحقاً
            )),

      ],
    );
  }

  Widget _buildAlertList(String title, List<ItemModel> items, IconData icon,
      Color color, String Function(ItemModel) subtitleBuilder) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: color),
            title: Text(
                title, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: CircleAvatar(radius: 12,
                backgroundColor: color,
                child: Text(items.length.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12))),
          ),
          const Divider(height: 1),
          if (items.isEmpty)
            const Padding(padding: EdgeInsets.all(16.0),
                child: Text('لا توجد تنبيهات حالياً',
                    style: TextStyle(color: Colors.grey)))
          else
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(title: Text(item.name),
                      subtitle: Text(subtitleBuilder(item)));
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChartsAndRecentActivitySection(DashboardController controller,
      ThemeData theme) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أكثر 5 أصناف تم صرفها مؤخراً', style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                Obx(() =>
                    SizedBox(
                        height: 200, child: _buildBarChart(controller, theme))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              const ListTile(leading: Icon(Icons.history),
                  title: Text('آخر عمليات الصرف',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const Divider(height: 1),
              Obx(() =>
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: controller.recentTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = controller
                            .recentTransactions[index];
                        return ListTile(
                          title: Text('صرف ${transaction
                              .quantityDisbursed} من ${controller
                              .getItemNameById(transaction.itemId)}'),
                          subtitle: Text(DateFormat('yyyy-MM-dd, hh:mm a')
                              .format(transaction.transactionDate)),
                        );
                      },
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(DashboardController controller, ThemeData theme) {
    Map<String, int> itemCounts = {};
    for (var transaction in controller.recentTransactions) {
      final itemName = controller.getItemNameById(transaction.itemId);
      itemCounts[itemName] =
          (itemCounts[itemName] ?? 0) + transaction.quantityDisbursed;
    }
    var sortedItems = itemCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    sortedItems = sortedItems.take(5).toList();

    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: (sortedItems.isNotEmpty ? sortedItems.first.value * 1.2 : 10),
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < sortedItems.length) {
              return Padding(padding: const EdgeInsets.only(top: 6.0),
                  child: Text(sortedItems[index].key,
                      style: const TextStyle(fontSize: 10)));
            }
            return const Text('');
          },
          reservedSize: 38,
        )),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: sortedItems
          .asMap()
          .entries
          .map((entry) {
        final index = entry.key;
        final itemData = entry.value;
        return BarChartGroupData(x: index, barRods: [
          BarChartRodData(toY: itemData.value.toDouble(),
              color: theme.primaryColor,
              width: 20,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4), topRight: Radius.circular(4))),
        ]);
      }).toList(),
    ),
    );
  }
}