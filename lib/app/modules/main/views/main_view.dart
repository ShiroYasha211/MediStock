import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medistock/app/modules/00_dashboard/views/dashboard_view.dart';
import 'package:medistock/app/modules/01_items_management/views/items_view.dart';
import 'package:medistock/app/modules/02_orders_management/views/oreders_view.dart';
import 'package:medistock/app/modules/03_beneficiaries_mangement/views/beneficiaries_view.dart';
import 'package:medistock/app/modules/04_transactions_management/views/transactions_view.dart';
import 'package:medistock/app/modules/05_settings_management/views/settings_view.dart';
import '../controllers/main_controller.dart';

// Same temporary pages
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Row(
          children: [
            // --- PROFESSIONAL SIDE NAVIGATION RAIL ---
            Obx(
                  () => NavigationRail(
                extended: controller.isRailExtended.value,
                minExtendedWidth: 220,
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: controller.changePage,
                leading: _buildRailHeader(context, controller),
                // We will add a footer for settings/logout later
                // trailing: _buildRailFooter(context, controller),
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

            // --- MAIN CONTENT AREA ---
            Expanded(
              child: Column(
                children: [
                  _buildCustomAppBar(context, controller),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      // Using an AnimatedSwitcher for a smooth transition between pages
                      // --- ✅ الحل: استخدام GetX<MainController> بدلاً من Obx ---
                      child: Obx(() {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: KeyedSubtree(
                            // إعطاء مفتاح فريد لكل صفحة يحل مشكلة إعادة البناء
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

  // --- NEW WIDGETS FOR THE PROFESSIONAL LOOK ---

  Widget _buildRailHeader(BuildContext context, MainController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Obx(() => Column(
        children: [
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo_icon.png', height: 40), // <<-- NOTE: ADD A LOGO ICON
              if (controller.isRailExtended.value) ...[
                const SizedBox(width: 12),
                Text(
                  'MediStock',
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          // Divider
          if (controller.isRailExtended.value)
            Divider(
              color: Colors.white.withOpacity(0.2),
              indent: 20,
              endIndent: 20,
            )
          else
            const SizedBox(height: 12),
        ],
      )),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, MainController controller) {
    final theme = Theme.of(context);
    return Material(
      elevation: theme.appBarTheme.elevation ?? 0,
      shadowColor: theme.appBarTheme.shadowColor,
      child: Container(
        height: 60,
        color: theme.appBarTheme.backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Toggle button
            IconButton(
              icon: Icon(Icons.menu, color: theme.colorScheme.onSurfaceVariant),
              onPressed: controller.toggleRail,
              tooltip: 'إظهار/إخفاء القائمة',
            ),
            const SizedBox(width: 16),
            // Page Title
            Obx(() => Text(
              _getAppBarTitle(controller.selectedIndex.value),
              style: theme.appBarTheme.titleTextStyle,
            )),
            const Spacer(),
            // Search Bar (Example)
            SizedBox(
              width: 250,
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن صنف...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: theme.colorScheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // User Profile (Example)
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text('A', style: TextStyle(color: theme.colorScheme.primary)),
                ),
                const SizedBox(width: 8),
                Text('admin', style: theme.textTheme.bodyMedium)
              ],
            )
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0: return 'لوحة التحكم';
      case 1: return 'إدارة الأصناف';
      case 2: return 'أوامر الصرف';
      case 3: return 'سجل عمليات الصرف';
      case 4: return 'إدارة المستفيدين';
      case 5: return 'الإعدادات العامة';
      default: return 'MediStock';
    }
  }
}
