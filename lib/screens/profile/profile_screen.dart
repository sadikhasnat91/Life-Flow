import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/goal_controller.dart';
import '../../controllers/habit_controller.dart';

import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';
import '../../services/export_service.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();
    final taskCtrl = Get.find<TaskController>();
    final goalCtrl = Get.find<GoalController>();
    final habitCtrl = Get.find<HabitController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final profile = profileCtrl.profile.value;
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // Avatar & Name
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.15),
                      child: Text(
                        (profile?.name ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => _editName(context, profileCtrl),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile?.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.edit,
                              size: 18,
                              color: isDark
                                  ? AppTheme.darkSubtext
                                  : AppTheme.lightSubtext),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since ${_memberSince(profile?.createdAt)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.darkSubtext
                            : AppTheme.lightSubtext,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Stats
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  _StatCard(
                    icon: Icons.task_alt,
                    label: 'Tasks Done',
                    value: '${taskCtrl.completedCount}',
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.emoji_events,
                    label: 'Goals Hit',
                    value: '${goalCtrl.completedCount}',
                    color: AppTheme.accentYellow,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Best Streak',
                    value: '${habitCtrl.longestStreak}',
                    color: AppTheme.accentOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Settings
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            profileCtrl.isDarkMode.value
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Dark Mode',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Switch.adaptive(
                          value: profileCtrl.isDarkMode.value,
                          onChanged: (_) => profileCtrl.toggleDarkMode(),
                        ),
                      ],
                    ),
                  ),
                  GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.accentOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: AppTheme.accentOrange, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Notifications',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Switch.adaptive(
                          value: profile?.notificationsEnabled ?? true,
                          onChanged: (_) => profileCtrl.toggleNotifications(),
                        ),
                      ],
                    ),
                  ),
                  GlassCard(
                    onTap: () => ExportService.exportData(),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.accentGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.download_outlined,
                              color: AppTheme.accentGreen, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Export Data (PDF)',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: isDark
                                ? AppTheme.darkSubtext
                                : AppTheme.lightSubtext),
                      ],
                    ),
                  ),
                  GlassCard(
                    onTap: () async {
                      await NotificationService.showInstant(
                        id: 777777,
                        title: '🔔 Instant Test',
                        body: 'Notifications are working!',
                      );
                      Get.snackbar('Sent', 'Check your notification shade',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_active,
                              color: AppTheme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Test Notification (Instant)',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: isDark
                                ? AppTheme.darkSubtext
                                : AppTheme.lightSubtext),
                      ],
                    ),
                  ),
                  GlassCard(
                    onTap: () async {
                      await NotificationService.testScheduledNotification();
                      Get.snackbar('Scheduled',
                          'A test notification will arrive in 5 seconds',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.accentPink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.schedule,
                              color: AppTheme.accentPink, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Test Scheduled (5 sec)',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: isDark
                                ? AppTheme.darkSubtext
                                : AppTheme.lightSubtext),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // App info
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    Color(0xFF8B83FF)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.auto_awesome,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppConstants.appName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'v${AppConstants.appVersion} • ${AppConstants.appTagline}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'LifeFlow helps you manage tasks, goals, habits, and notes — all in one beautiful app.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppTheme.darkSubtext
                                : AppTheme.lightSubtext,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void _editName(BuildContext context, ProfileController ctrl) {
    final nameCtrl = TextEditingController(text: ctrl.profile.value?.name);
    Get.dialog(AlertDialog(
      title: const Text('Edit Name'),
      content: TextField(
        controller: nameCtrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Your name'),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (nameCtrl.text.trim().isNotEmpty) {
              ctrl.updateName(nameCtrl.text.trim());
            }
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }

  String _memberSince(DateTime? date) {
    if (date == null) return 'today';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkSubtext
                    : AppTheme.lightSubtext,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
