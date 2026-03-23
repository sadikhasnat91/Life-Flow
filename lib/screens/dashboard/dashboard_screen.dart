import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/goal_controller.dart';
import '../../controllers/habit_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = Get.find<TaskController>();
    final goalCtrl = Get.find<GoalController>();
    final habitCtrl = Get.find<HabitController>();
    final profileCtrl = Get.find<ProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Helpers.greeting(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppTheme.darkSubtext
                                      : AppTheme.lightSubtext,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profileCtrl.profile.value?.name ?? 'User',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            (profileCtrl.profile.value?.name ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quote Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, Color(0xFF8B83FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.format_quote,
                                  color: Colors.white70, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Daily Motivation',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            Helpers.dailyQuote(AppConstants.motivationalQuotes),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Progress Overview
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: FadeInDown(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: "Today's Overview"),
                        Row(
                          children: [
                            Expanded(
                              child: _OverviewCard(
                                icon: Icons.task_alt,
                                label: 'Tasks',
                                value:
                                    '${taskCtrl.completedCount}/${taskCtrl.tasks.length}',
                                percent: taskCtrl.completionRate,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _OverviewCard(
                                icon: Icons.flag_rounded,
                                label: 'Goals',
                                value:
                                    '${goalCtrl.completedCount}/${goalCtrl.goals.length}',
                                percent: goalCtrl.overallProgress,
                                color: AppTheme.accentPink,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _OverviewCard(
                                icon: Icons.local_fire_department,
                                label: 'Habits',
                                value:
                                    '${habitCtrl.todayCompletedCount}/${habitCtrl.activeHabits.length}',
                                percent: habitCtrl.todayProgress,
                                color: AppTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Today's Tasks
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        const SectionHeader(title: "Today's Tasks"),
                        if (taskCtrl.todayTasks.isEmpty)
                          GlassCard(
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: AppTheme.accentGreen, size: 32),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'No tasks scheduled for today. Enjoy your day!',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...taskCtrl.todayTasks.take(3).map((task) {
                            return GlassCard(
                              onTap: () => taskCtrl.toggleComplete(task),
                              child: Row(
                                children: [
                                  Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: task.isCompleted
                                        ? AppTheme.accentGreen
                                        : AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  PriorityBadge(
                                      priority: task.priority, small: true),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),

              // Active Goals
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        const SectionHeader(title: 'Active Goals'),
                        if (goalCtrl.activeGoals.isEmpty)
                          GlassCard(
                            child: Row(
                              children: [
                                Icon(Icons.emoji_events,
                                    color: AppTheme.accentYellow, size: 32),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Set your first goal to get started!',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...goalCtrl.activeGoals.take(2).map((goal) {
                            return GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          goal.title,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Helpers.timeRemaining(goal.targetDate),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: goal.isOverdue
                                              ? AppTheme.accentPink
                                              : AppTheme.accentGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: goal.progress,
                                      minHeight: 6,
                                      backgroundColor: AppTheme.primaryColor
                                          .withValues(alpha: 0.1),
                                      valueColor:
                                          const AlwaysStoppedAnimation(
                                              AppTheme.primaryColor),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(goal.progress * 100).toInt()}% complete',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppTheme.darkSubtext
                                          : AppTheme.lightSubtext,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),

              // Habits summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        const SectionHeader(title: "Today's Habits"),
                        if (habitCtrl.activeHabits.isEmpty)
                          GlassCard(
                            child: Row(
                              children: [
                                Icon(Icons.repeat,
                                    color: AppTheme.accentOrange, size: 32),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Build your first habit today!',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...habitCtrl.activeHabits.take(4).map((habit) {
                            final isDone =
                                habit.isCompletedOn(DateTime.now());
                            return GlassCard(
                              onTap: () => habitCtrl.toggleHabitDate(
                                  habit, DateTime.now()),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(habit.colorValue)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(habit.icon,
                                          style:
                                              const TextStyle(fontSize: 20)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          habit.title,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '🔥 ${habit.currentStreak} day streak',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppTheme.darkSubtext
                                                : AppTheme.lightSubtext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isDone
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: isDone
                                        ? AppTheme.accentGreen
                                        : (isDark
                                            ? AppTheme.darkSubtext
                                            : AppTheme.lightSubtext),
                                    size: 28,
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double percent;
  final Color color;

  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 28,
            lineWidth: 4,
            percent: percent.clamp(0, 1),
            center: Icon(icon, size: 20, color: color),
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.15),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
            ),
          ),
        ],
      ),
    );
  }
}
