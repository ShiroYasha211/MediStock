import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'package:medistock/app/core/services/theme_service.dart';
import 'package:medistock/app/core/theme/app_theme.dart';
import 'package:medistock/app/modules/main/views/main_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- تهيئة التخزين المحلي ---
  await GetStorage.init();

  // --- إعداد نافذة سطح المكتب ---
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1400, 820),
    minimumSize: Size(1360, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // --- تهيئة قاعدة البيانات لبيئة سطح المكتب ---
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MediStock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeService().theme,
      home: const MainView(),
    );
  }
}
