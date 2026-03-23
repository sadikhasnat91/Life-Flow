import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_model.dart';
import '../services/database_service.dart';

class HabitController extends GetxController {
  final habits = <HabitModel>[].obs;
  final selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadHabits();
  }

  void loadHabits() {
    habits.value = DatabaseService.getAllHabits();
  }

  List<HabitModel> get activeHabits =>
      habits.where((h) => h.isActive).toList();

  int get todayCompletedCount {
    final now = DateTime.now();
    return habits.where((h) => h.isCompletedOn(now)).length;
  }

  double get todayProgress {
    final active = activeHabits;
    if (active.isEmpty) return 0;
    final now = DateTime.now();
    final completed = active.where((h) => h.isCompletedOn(now)).length;
    return completed / active.length;
  }

  int get longestStreak {
    if (habits.isEmpty) return 0;
    return habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
  }

  Future<void> addHabit({
    required String title,
    String icon = '⭐',
    int colorValue = 0xFF6C63FF,
    String? reminderTime,
  }) async {
    final habit = HabitModel(
      id: const Uuid().v4(),
      title: title,
      icon: icon,
      createdAt: DateTime.now(),
      colorValue: colorValue,
      reminderTime: reminderTime,
    );
    await DatabaseService.addHabit(habit);
    loadHabits();
  }

  Future<void> toggleHabitDate(HabitModel habit, DateTime date) async {
    habit.toggleDate(date);
    await DatabaseService.updateHabit(habit);
    loadHabits();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await DatabaseService.updateHabit(habit);
    loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    await DatabaseService.deleteHabit(id);
    loadHabits();
  }

  // Weekly data for chart (last 7 days)
  Map<String, int> get weeklyData {
    final now = DateTime.now();
    final data = <String, int>{};
    final active = activeHabits;
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key =
          '${day.month}/${day.day}';
      data[key] = active.where((h) => h.isCompletedOn(day)).length;
    }
    return data;
  }
}
