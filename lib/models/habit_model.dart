import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 2)
class HabitModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String icon;

  @HiveField(3)
  List<String> completedDates; // stored as yyyy-MM-dd strings

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  int colorValue;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  String? reminderTime; // stored as HH:mm

  HabitModel({
    required this.id,
    required this.title,
    this.icon = '⭐',
    List<String>? completedDates,
    required this.createdAt,
    this.colorValue = 0xFF6C63FF,
    this.isActive = true,
    this.reminderTime,
  }) : completedDates = completedDates ?? [];

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = List<String>.from(completedDates)..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (int i = 0; i < sorted.length; i++) {
      final dateStr = _formatDate(checkDate);
      if (sorted.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (i == 0) {
        // Check if today is not yet marked but yesterday was
        checkDate = checkDate.subtract(const Duration(days: 1));
        final yesterdayStr = _formatDate(checkDate);
        if (sorted.contains(yesterdayStr)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else {
        break;
      }
    }
    return streak;
  }

  int get longestStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = List<String>.from(completedDates)..sort();
    int longest = 1;
    int current = 1;

    for (int i = 1; i < sorted.length; i++) {
      final prev = DateTime.parse(sorted[i - 1]);
      final curr = DateTime.parse(sorted[i]);
      if (curr.difference(prev).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (curr.difference(prev).inDays > 1) {
        current = 1;
      }
    }
    return longest;
  }

  bool isCompletedOn(DateTime date) {
    return completedDates.contains(_formatDate(date));
  }

  void toggleDate(DateTime date) {
    final dateStr = _formatDate(date);
    if (completedDates.contains(dateStr)) {
      completedDates.remove(dateStr);
    } else {
      completedDates.add(dateStr);
    }
  }

  double get weeklyProgress {
    final now = DateTime.now();
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      if (isCompletedOn(day)) count++;
    }
    return count / 7;
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
