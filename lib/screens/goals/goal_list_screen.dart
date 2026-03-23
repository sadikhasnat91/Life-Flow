import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/goal_controller.dart';
import '../../utils/helpers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/common_widgets.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';

class GoalListScreen extends StatelessWidget {
  const GoalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<GoalController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: Obx(() {
        if (ctrl.goals.isEmpty) {
          return const EmptyState(
            icon: Icons.flag_rounded,
            title: 'No goals yet',
            subtitle: 'Set ambitious goals and track your progress',
          );
        }
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // Stats bar
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  _StatBadge(
                    icon: Icons.flag,
                    label: 'Active',
                    count: ctrl.activeGoals.length,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _StatBadge(
                    icon: Icons.check_circle,
                    label: 'Done',
                    count: ctrl.completedCount,
                    color: AppTheme.accentGreen,
                  ),
                  const SizedBox(width: 12),
                  _StatBadge(
                    icon: Icons.warning_amber,
                    label: 'Overdue',
                    count:
                        ctrl.goals.where((g) => g.isOverdue).length,
                    color: AppTheme.accentPink,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (ctrl.activeGoals.isNotEmpty) ...[
              const SectionHeader(title: 'Active Goals'),
              ...ctrl.activeGoals.asMap().entries.map((entry) {
                final goal = entry.value;
                return FadeInUp(
                  delay: Duration(milliseconds: entry.key * 80),
                  duration: const Duration(milliseconds: 500),
                  child: GlassCard(
                    onTap: () => Get.to(() => GoalDetailScreen(goal: goal)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: goal.isOverdue
                                    ? AppTheme.accentPink.withValues(alpha: 0.15)
                                    : AppTheme.primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                goal.isOverdue
                                    ? Icons.warning_amber
                                    : Icons.flag_rounded,
                                size: 20,
                                color: goal.isOverdue
                                    ? AppTheme.accentPink
                                    : AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Due: ${Helpers.formatDateTime(goal.targetDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: goal.isOverdue
                                          ? AppTheme.accentPink
                                          : (isDark
                                              ? AppTheme.darkSubtext
                                              : AppTheme.lightSubtext),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Helpers.timeRemaining(goal.targetDate),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: goal.isOverdue
                                    ? AppTheme.accentPink
                                    : AppTheme.accentGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: goal.progress,
                            minHeight: 6,
                            backgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation(
                                AppTheme.primaryColor),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(goal.progress * 100).toInt()}% complete',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppTheme.darkSubtext
                                    : AppTheme.lightSubtext,
                              ),
                            ),
                            if (goal.milestones.isNotEmpty)
                              Text(
                                '${goal.milestoneCompleted.where((e) => e).length}/${goal.milestones.length} milestones',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppTheme.darkSubtext
                                      : AppTheme.lightSubtext,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            if (ctrl.completedGoals.isNotEmpty) ...[
              const SizedBox(height: 16),
              const SectionHeader(title: 'Completed'),
              ...ctrl.completedGoals.map((goal) {
                return GlassCard(
                  onTap: () => Get.to(() => GoalDetailScreen(goal: goal)),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events,
                          color: AppTheme.accentYellow, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          goal.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      const Icon(Icons.check_circle,
                          color: AppTheme.accentGreen),
                    ],
                  ),
                );
              }),
            ],
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddGoalScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkSubtext
                        : AppTheme.lightSubtext,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
