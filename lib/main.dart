import 'package:get_storage/get_storage.dart';
import 'package:medistock/app/core/services/theme_service.dart';
import 'package:medistock/app/core/theme/app_theme.dart';
import 'package:medistock/app/modules/main/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'package:window_manager/window_manager.dart';

Future<void> main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await GetStorage.init();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1400, 820), // الحجم الأولي للنافذة
    minimumSize: Size(1360, 800), // أقل حجم مسموح به
    center: true, // جعل النافذة تظهر في منتصف الشاشة
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show(); // إظهار النافذة
    await windowManager.focus(); // التركيز عليها
  });
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
      themeMode: ThemeService().theme,
      darkTheme: AppTheme.darkTheme,
      home: const MainView(),
    );
  }
}
