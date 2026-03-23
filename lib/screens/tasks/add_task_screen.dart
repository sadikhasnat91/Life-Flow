import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../utils/helpers.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _deadline;
  int _priority = 1;
  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _deadline = widget.task!.deadline;
      _priority = widget.task!.priority;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                Get.find<TaskController>().deleteTask(widget.task!.id);
                Get.back();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Task title',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add description...',
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Divider(height: 32),

            // Priority
            Text(
              'Priority',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(3, (i) {
                final labels = ['Low', 'Medium', 'High'];
                final colors = [
                  AppTheme.accentGreen,
                  AppTheme.accentOrange,
                  AppTheme.accentPink,
                ];
                final selected = _priority == i;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? colors[i].withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? colors[i]
                                : (isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.lightBorder),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              color: selected ? colors[i] : null,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Deadline
            Text(
              'Deadline',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: isDark
                          ? AppTheme.darkSubtext
                          : AppTheme.lightSubtext,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _deadline != null
                          ? Helpers.formatDateTime(_deadline!)
                          : 'Set deadline (optional)',
                      style: TextStyle(
                        color: _deadline != null
                            ? null
                            : (isDark
                                ? AppTheme.darkSubtext
                                : AppTheme.lightSubtext),
                      ),
                    ),
                    const Spacer(),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: const Icon(Icons.close, size: 18),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isEditing ? 'Update Task' : 'Create Task',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime:
          _deadline != null ? TimeOfDay.fromDateTime(_deadline!) : TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a task title',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final ctrl = Get.find<TaskController>();
    if (_isEditing) {
      final task = widget.task!;
      task.title = _titleCtrl.text.trim();
      task.description = _descCtrl.text.trim();
      task.deadline = _deadline;
      task.priority = _priority;
      ctrl.updateTask(task);
    } else {
      ctrl.addTask(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        deadline: _deadline,
        priority: _priority,
      );
    }
    Get.back();
  }
}
