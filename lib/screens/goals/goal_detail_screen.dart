import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/goal_controller.dart';
import '../../models/goal_model.dart';
import '../../utils/helpers.dart';
import '../../widgets/glass_card.dart';

class GoalDetailScreen extends StatelessWidget {
  final GoalModel goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<GoalController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              Get.dialog(AlertDialog(
                title: const Text('Delete Goal?'),
                content:
                    const Text('This action cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ctrl.deleteGoal(goal.id);
                      Get.back();
                      Get.back();
                    },
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ));
            },
          ),
        ],
      ),
      body: Obx(() {
        // Force rebuild when goals update
        ctrl.goals.length;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress circle
              Center(
                child: CircularPercentIndicator(
                  radius: 70,
                  lineWidth: 10,
                  percent: goal.progress.clamp(0, 1),
                  center: Text(
                    '${(goal.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  progressColor: goal.isCompleted
                      ? AppTheme.accentGreen
                      : AppTheme.primaryColor,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 800,
                ),
              ),
              const SizedBox(height: 24),

              // Title & description
              Center(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (goal.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text(
                      goal.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppTheme.darkSubtext
                            : AppTheme.lightSubtext,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Status badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: Helpers.formatDate(goal.targetDate),
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  _InfoChip(
                    icon: goal.isOverdue ? Icons.warning : Icons.timer,
                    label: Helpers.timeRemaining(goal.targetDate),
                    color: goal.isOverdue
                        ? AppTheme.accentPink
                        : AppTheme.accentGreen,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Milestones
              if (goal.milestones.isNotEmpty) ...[
                Text(
                  'Milestones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(goal.milestones.length, (i) {
                  final done = goal.milestoneCompleted[i];
                  return GlassCard(
                    onTap: () => ctrl.toggleMilestone(goal, i),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done ? AppTheme.accentGreen : Colors.transparent,
                            border: Border.all(
                              color: done
                                  ? AppTheme.accentGreen
                                  : (isDark
                                      ? AppTheme.darkSubtext
                                      : AppTheme.lightSubtext),
                              width: 2,
                            ),
                          ),
                          child: done
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            goal.milestones[i],
                            style: TextStyle(
                              fontSize: 15,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: done
                                  ? (isDark
                                      ? AppTheme.darkSubtext
                                      : AppTheme.lightSubtext)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Complete goal button
              if (!goal.isCompleted)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ctrl.toggleComplete(goal);
                      Get.back();
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark as Completed',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
