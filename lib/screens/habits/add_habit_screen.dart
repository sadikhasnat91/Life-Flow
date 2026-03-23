import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/habit_controller.dart';
import '../../utils/constants.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _titleCtrl = TextEditingController();
  String _selectedIcon = '⭐';
  int _selectedColor = 0xFF6C63FF;

  final List<int> _colorOptions = [
    0xFF6C63FF, 0xFFFF6B9D, 0xFFFF8A65, 0xFF66BB6A,
    0xFFFFCA28, 0xFF42A5F5, 0xFFAB47BC, 0xFF26A69A,
    0xFFEC407A, 0xFF7E57C2,
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('New Habit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon selector
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(_selectedColor).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(_selectedIcon,
                      style: const TextStyle(fontSize: 40)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: 'Habit name',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            const Divider(height: 32),

            // Icon picker
            Text(
              'Choose Icon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.habitIcons.map((icon) {
                final selected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? Color(_selectedColor).withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? Color(_selectedColor)
                            : (isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder),
                      ),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Color picker
            Text(
              'Choose Color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colorOptions.map((color) {
                final selected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Color(color).withValues(alpha: 0.4),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(_selectedColor),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Create Habit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a habit name',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.find<HabitController>().addHabit(
      title: _titleCtrl.text.trim(),
      icon: _selectedIcon,
      colorValue: _selectedColor,
    );
    Get.back();
  }
}
