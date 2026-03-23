import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/task_controller.dart';
import '../../utils/helpers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/common_widgets.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  ctrl.showCompleted.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: 22,
                ),
                onPressed: () =>
                    ctrl.showCompleted.value = !ctrl.showCompleted.value,
                tooltip: 'Toggle completed',
              )),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              onChanged: (v) => ctrl.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: Obx(() => ctrl.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => ctrl.searchQuery.value = '',
                      )
                    : const SizedBox.shrink()),
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: ctrl.filterPriority.value == -1,
                      onTap: () => ctrl.filterPriority.value = -1,
                    ),
                    _FilterChip(
                      label: 'High',
                      selected: ctrl.filterPriority.value == 2,
                      onTap: () => ctrl.filterPriority.value = 2,
                      color: AppTheme.accentPink,
                    ),
                    _FilterChip(
                      label: 'Medium',
                      selected: ctrl.filterPriority.value == 1,
                      onTap: () => ctrl.filterPriority.value = 1,
                      color: AppTheme.accentOrange,
                    ),
                    _FilterChip(
                      label: 'Low',
                      selected: ctrl.filterPriority.value == 0,
                      onTap: () => ctrl.filterPriority.value = 0,
                      color: AppTheme.accentGreen,
                    ),
                  ],
                )),
          ),
          const SizedBox(height: 8),

          // Task list
          Expanded(
            child: Obx(() {
              final tasks = ctrl.filteredTasks;
              if (tasks.isEmpty) {
                return const EmptyState(
                  icon: Icons.task_alt,
                  title: 'No tasks found',
                  subtitle: 'Tap + to create your first task',
                );
              }
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 50),
                    duration: const Duration(milliseconds: 400),
                    child: Dismissible(
                      key: Key(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                      ),
                      onDismissed: (_) => ctrl.deleteTask(task.id),
                      child: GlassCard(
                        onTap: () => Get.to(() => AddTaskScreen(task: task)),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => ctrl.toggleComplete(task),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: task.isCompleted
                                      ? AppTheme.accentGreen
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: task.isCompleted
                                        ? AppTheme.accentGreen
                                        : (isDark
                                            ? AppTheme.darkSubtext
                                            : AppTheme.lightSubtext),
                                    width: 2,
                                  ),
                                ),
                                child: task.isCompleted
                                    ? const Icon(Icons.check,
                                        size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: task.isCompleted
                                          ? (isDark
                                              ? AppTheme.darkSubtext
                                              : AppTheme.lightSubtext)
                                          : null,
                                    ),
                                  ),
                                  if (task.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        task.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? AppTheme.darkSubtext
                                              : AppTheme.lightSubtext,
                                        ),
                                      ),
                                    ),
                                  if (task.deadline != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.schedule,
                                              size: 14,
                                              color: isDark
                                                  ? AppTheme.darkSubtext
                                                  : AppTheme.lightSubtext),
                                          const SizedBox(width: 4),
                                          Text(
                                            Helpers.formatDateTime(
                                                task.deadline!),
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
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            PriorityBadge(priority: task.priority, small: true),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddTaskScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryColor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? c.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? c
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkBorder
                      : AppTheme.lightBorder),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? c : null,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
