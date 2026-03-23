import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/goal_controller.dart';
import '../../utils/helpers.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _milestoneCtrl = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 7));
  final List<String> _milestones = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _milestoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('New Goal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: 'Goal title',
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
                hintText: 'Describe your goal...',
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

            // Target Date
            Text(
              'Target Date & Time',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickTargetDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, size: 20,
                        color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext),
                    const SizedBox(width: 12),
                    Text(Helpers.formatDateTime(_targetDate)),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, size: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Milestones
            Text(
              'Milestones (optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _milestoneCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Add a milestone',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addMilestone,
                  icon: const Icon(Icons.add_circle),
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_milestones.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8,
                        color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_milestones[i])),
                    GestureDetector(
                      onTap: () => setState(() => _milestones.removeAt(i)),
                      child: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),

            // Notification info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active,
                      color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You\'ll be notified 1 day, 1 hour, and 10 minutes before deadline, plus an alarm at the exact time.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
                child: const Text(
                  'Create Goal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMilestone() {
    if (_milestoneCtrl.text.trim().isNotEmpty) {
      setState(() {
        _milestones.add(_milestoneCtrl.text.trim());
        _milestoneCtrl.clear();
      });
    }
  }

  Future<void> _pickTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_targetDate),
    );
    if (time == null) return;
    setState(() {
      _targetDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a goal title',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.find<GoalController>().addGoal(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      targetDate: _targetDate,
      milestones: _milestones.isNotEmpty ? _milestones : null,
    );
    Get.back();
  }
}
