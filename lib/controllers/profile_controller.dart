import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_profile_model.dart';
import '../services/database_service.dart';

class ProfileController extends GetxController {
  final profile = Rxn<UserProfileModel>();
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    profile.value = DatabaseService.getProfile();
    isDarkMode.value = profile.value?.isDarkMode ?? false;
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> updateName(String name) async {
    final p = profile.value!;
    p.name = name;
    await DatabaseService.updateProfile(p);
    profile.refresh();
  }

  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    final p = profile.value!;
    p.isDarkMode = isDarkMode.value;
    await DatabaseService.updateProfile(p);
    _applyTheme();
    profile.refresh();
  }

  Future<void> toggleNotifications() async {
    final p = profile.value!;
    p.notificationsEnabled = !p.notificationsEnabled;
    await DatabaseService.updateProfile(p);
    profile.refresh();
  }
}
