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

class _DashboardViewState extends State<DashboardView>
    with WidgetsBindingObserver {
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
                      controller,
                      theme,
                    ),
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
          child: _buildInfoCard(
            'إجمالي الأصناف',
            controller.totalItemsCount,
            Icons.inventory_2_outlined,
            theme.primaryColor,
            theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoCard(
            'قارب على النفاذ',
            controller.lowStockCount,
            Icons.warning_amber_rounded,
            Colors.orange.shade700,
            theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoCard(
            'قارب على الانتهاء',
            controller.expiringSoonCount,
            Icons.hourglass_bottom_outlined,
            Colors.blue.shade700,
            theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoCard(
            'انتهت الصلاحية',
            controller.expiredCount,
            Icons.event_busy_outlined,
            theme.colorScheme.error,
            theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoCard(
            'نفدت من المخزون',
            controller.outOfStockCount,
            Icons.remove_shopping_cart_outlined,
            theme.colorScheme.error.withOpacity(0.8),
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    RxInt value,
    IconData icon,
    Color baseColor,
    ThemeData theme,
  ) {
    // If we're in dark mode, lighten the baseColor so it doesn't blend into the dark surfaces
    Color color = baseColor;
    if (theme.brightness == Brightness.dark) {
      final hsl = HSLColor.fromColor(baseColor);
      color = hsl
          .withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0))
          .toColor();
    }

    return Card(
      elevation: 4, // Slightly higher for floating effect
      shadowColor: color.withOpacity(0.3), // Colored shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // Softer corners
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.05), color.withOpacity(0.01)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        value.value.toString(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsSection(DashboardController controller, ThemeData theme) {
    return Column(
      children: [
        Obx(
          () => _buildAlertList(
            'أصناف قاربت على الانتهاء',
            controller.expiringSoonItems,
            Icons.hourglass_bottom_outlined,
            Colors.blue.shade700,
            (item) =>
                'تاريخ الانتهاء: ${DateFormat('yyyy-MM-dd').format(item.expiryDate)}',
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => _buildAlertList(
            'أصناف قاربت على النفاذ',
            controller.lowStockItems,
            Icons.warning_amber_rounded,
            Colors.orange.shade700,
            (item) => 'الكمية المتبقية: ${item.quantity}',
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => _buildAlertList(
            'أصناف انتهت صلاحيتها',
            controller.expiredItems,
            Icons.event_busy_outlined,
            theme.colorScheme.error,
            (item) =>
                'تاريخ الانتهاء: ${DateFormat('yyyy-MM-dd').format(item.expiryDate)}',
          ),
        ),

        // --- ✅ جديد: إضافة قائمة الأصناف النافدة ---
        const SizedBox(height: 20),
        Obx(
          () => _buildAlertList(
            'أصناف نفدت من المخزون',
            controller.outOfStockItems,
            Icons.remove_shopping_cart_outlined,
            theme.colorScheme.error.withOpacity(0.8),
            (item) =>
                'نفدت الكمية في: ${DateFormat('yyyy-MM-dd').format(item.createdAt)}', // يمكناستخدام تاريخ آخر تحديث لاحقاً
          ),
        ),
      ],
    );
  }

  Widget _buildAlertList(
    String title,
    List<ItemModel> items,
    IconData icon,
    Color color,
    String Function(ItemModel) subtitleBuilder,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 4),
          ), // Accent border
        ),
        child: Column(
          children: [
            Container(
              color: color.withOpacity(0.05),
              child: ListTile(
                leading: Icon(icon, color: color),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    items.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 40,
                      color: Colors.green.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'لا توجد تنبيهات حالياً',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 180, // Slightly taller for better scrolling
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // TODO: Navigate to item details
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListTile(
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              subtitleBuilder(item),
                              style: TextStyle(color: color.withOpacity(0.8)),
                            ),
                            dense: true,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsAndRecentActivitySection(
    DashboardController controller,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insert_chart_outlined,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'أكثر 5 أصناف تم صرفها مؤخراً',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Obx(
                  () => SizedBox(
                    height: 220,
                    child: _buildBarChart(controller, theme),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: theme.colorScheme.secondary,
                ),
                title: const Text(
                  'آخر عمليات الصرف',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Divider(height: 1),
              Obx(
                () => SizedBox(
                  height: 220,
                  child: controller.recentTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد عمليات صرف مؤخراً',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: controller.recentTransactions.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) {
                            final transaction =
                                controller.recentTransactions[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.secondary
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.outbox,
                                  color: theme.colorScheme.secondary,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                'صرف ${transaction.quantityDisbursed} من ${controller.getItemNameById(transaction.itemId)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'yyyy-MM-dd, hh:mm a',
                                ).format(transaction.transactionDate),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(DashboardController controller, ThemeData theme) {
    // --- ✅ الحل: استخدام البيانات المحسوبة من الـ Controller ---
    final sortedItems = controller.top5DisbursedItems;

    if (sortedItems.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد بيانات كافية للرسم البياني',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (sortedItems.isNotEmpty ? sortedItems.first.value * 1.2 : 10),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: Colors.blueGrey, // Removed due to deprecation/type error if custom color is used, omitting falls back to default
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${sortedItems[group.x.toInt()].key}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.toY).toString(),
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < sortedItems.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      sortedItems[index].key,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 42,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (sortedItems.first.value / 4).clamp(
            1.0,
            double.infinity,
          ),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: sortedItems.asMap().entries.map((entry) {
          final index = entry.key;
          final itemData = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: itemData.value.toDouble(),
                gradient: LinearGradient(
                  colors: [theme.colorScheme.secondary, theme.primaryColor],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 24, // Wider bars
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
