import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/bindings/app_binding.dart';
import 'app/theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'screens/main_shell.dart';
import 'controllers/profile_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await DatabaseService.init();
  await NotificationService.init();

  runApp(const LifeFlowApp());
}

class LifeFlowApp extends StatelessWidget {
  const LifeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppBinding().dependencies();

    final profileCtrl = Get.find<ProfileController>();
    final initialMode =
        profileCtrl.isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

    return GetMaterialApp(
      title: 'LifeFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialMode,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      home: MainShell(),
    );
  }
}
