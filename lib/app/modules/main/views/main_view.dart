import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medistock/app/modules/00_dashboard/views/dashboard_view.dart';
import 'package:medistock/app/modules/01_items_management/views/items_view.dart';
import 'package:medistock/app/modules/02_orders_management/views/oreders_view.dart';
import 'package:medistock/app/modules/03_beneficiaries_mangement/views/beneficiaries_view.dart';
import 'package:medistock/app/modules/04_transactions_management/views/transactions_view.dart';
import 'package:medistock/app/modules/05_settings_management/views/settings_view.dart';
import '../controllers/main_controller.dart';

final List<Widget> _mainPages = [
  const DashboardView(),
  const ItemsView(),
  const OrdersView(),
  const TransactionsView(),
  const BeneficiariesView(),
  const SettingsView(),
];

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Row(
          children: [
            // --- القائمة الجانبية ---
            Obx(
              () => NavigationRail(
                extended: controller.isRailExtended.value,
                minExtendedWidth: 220,
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: controller.changePage,
                leading: _buildRailHeader(context, controller),
                destinations: const [
                  NavigationRailDestination(
                    padding: EdgeInsets.only(bottom: 8),
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('لوحة التحكم'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.only(bottom: 8),
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: Text('الأصناف'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.only(bottom: 8),
                    icon: Icon(Icons.description_outlined),
                    selectedIcon: Icon(Icons.description),
                    label: Text('أوامر الصرف'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.only(bottom: 8),
                    icon: Icon(Icons.sync_alt_rounded),
                    selectedIcon: Icon(Icons.sync_alt_rounded),
                    label: Text('سجل الصرف'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.only(bottom: 8),
                    icon: Icon(Icons.groups_outlined),
                    selectedIcon: Icon(Icons.groups),
                    label: Text('المستفيدون'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.only(bottom: 8),
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('الإعدادات'),
                  ),
                ],
              ),
            ),

            // --- المحتوى الرئيسي ---
            Expanded(
              child: Column(
                children: [
                  _buildCustomAppBar(context, controller, theme),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Obx(() {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: KeyedSubtree(
                            key: ValueKey<int>(controller.selectedIndex.value),
                            child: _mainPages[controller.selectedIndex.value],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- شريط الرأس في القائمة الجانبية ---
  Widget _buildRailHeader(BuildContext context, MainController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Obx(
        () => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo_icon.png', height: 40),
                if (controller.isRailExtended.value) ...[
                  const SizedBox(width: 12),
                  Text(
                    'MediStock',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            if (controller.isRailExtended.value)
              Divider(
                color: Colors.white.withOpacity(0.2),
                indent: 20,
                endIndent: 20,
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // --- شريط التطبيق المخصص ---
  Widget _buildCustomAppBar(
    BuildContext context,
    MainController controller,
    ThemeData theme,
  ) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // زر القائمة
          IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: controller.toggleRail,
            tooltip: 'إظهار/إخفاء القائمة',
          ),
          const SizedBox(width: 16),

          // عنوان الصفحة
          Obx(
            () => Text(
              _getAppBarTitle(controller.selectedIndex.value),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const Spacer(),

          // ملف المستخدم
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'المسؤول',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'لوحة التحكم';
      case 1:
        return 'إدارة الأصناف';
      case 2:
        return 'أوامر الصرف';
      case 3:
        return 'سجل عمليات الصرف';
      case 4:
        return 'إدارة المستفيدين';
      case 5:
        return 'الإعدادات العامة';
      default:
        return 'MediStock';
    }
  }
}
