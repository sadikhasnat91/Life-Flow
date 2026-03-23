import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/goal_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class GoalController extends GetxController {
  final goals = <GoalModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  void loadGoals() {
    goals.value = DatabaseService.getAllGoals();
    goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
  }

  List<GoalModel> get activeGoals =>
      goals.where((g) => !g.isCompleted).toList();

  List<GoalModel> get completedGoals =>
      goals.where((g) => g.isCompleted).toList();

  int get completedCount => completedGoals.length;

  double get overallProgress {
    if (goals.isEmpty) return 0;
    double total = 0;
    for (final g in goals) {
      total += g.progress;
    }
    return total / goals.length;
  }

  Future<void> addGoal({
    required String title,
    String description = '',
    required DateTime targetDate,
    List<String>? milestones,
  }) async {
    final goal = GoalModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      milestones: milestones,
      milestoneCompleted:
          milestones != null ? List.filled(milestones.length, false) : null,
    );
    await DatabaseService.addGoal(goal);
    await NotificationService.scheduleGoalNotifications(
      goalId: goal.id,
      goalTitle: goal.title,
      targetDate: targetDate,
    );
    loadGoals();
  }

  Future<void> toggleMilestone(GoalModel goal, int index) async {
    goal.milestoneCompleted[index] = !goal.milestoneCompleted[index];
    // Check if all milestones completed
    if (goal.milestoneCompleted.every((e) => e)) {
      goal.isCompleted = true;
      await NotificationService.cancelGoalNotifications(goal.id);
    }
    await DatabaseService.updateGoal(goal);
    loadGoals();
  }

  Future<void> toggleComplete(GoalModel goal) async {
    goal.isCompleted = !goal.isCompleted;
    if (goal.isCompleted) {
      await NotificationService.cancelGoalNotifications(goal.id);
    } else {
      await NotificationService.scheduleGoalNotifications(
        goalId: goal.id,
        goalTitle: goal.title,
        targetDate: goal.targetDate,
      );
    }
    await DatabaseService.updateGoal(goal);
    loadGoals();
  }

  Future<void> updateGoal(GoalModel goal) async {
    await NotificationService.cancelGoalNotifications(goal.id);
    if (!goal.isCompleted) {
      await NotificationService.scheduleGoalNotifications(
        goalId: goal.id,
        goalTitle: goal.title,
        targetDate: goal.targetDate,
      );
    }
    await DatabaseService.updateGoal(goal);
    loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await NotificationService.cancelGoalNotifications(id);
    await DatabaseService.deleteGoal(id);
    loadGoals();
  }
}
