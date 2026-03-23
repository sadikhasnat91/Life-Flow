import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskController extends GetxController {
  final tasks = <TaskModel>[].obs;
  final searchQuery = ''.obs;
  final filterPriority = (-1).obs; // -1 = all
  final showCompleted = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  void loadTasks() {
    tasks.value = DatabaseService.getAllTasks();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<TaskModel> get filteredTasks {
    var list = tasks.toList();

    if (searchQuery.value.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              t.description
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    if (filterPriority.value >= 0) {
      list = list.where((t) => t.priority == filterPriority.value).toList();
    }

    if (!showCompleted.value) {
      list = list.where((t) => !t.isCompleted).toList();
    }

    return list;
  }

  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    return tasks.where((t) {
      if (t.deadline == null) return false;
      return t.deadline!.year == now.year &&
          t.deadline!.month == now.month &&
          t.deadline!.day == now.day;
    }).toList();
  }

  int get completedCount => tasks.where((t) => t.isCompleted).length;

  double get completionRate =>
      tasks.isEmpty ? 0 : completedCount / tasks.length;

  Future<void> addTask({
    required String title,
    String description = '',
    DateTime? deadline,
    int priority = 1,
    String? category,
  }) async {
    final task = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      deadline: deadline,
      priority: priority,
      createdAt: DateTime.now(),
      category: category,
    );
    await DatabaseService.addTask(task);
    loadTasks();
    // Schedule notifications in background (don't block UI)
    if (deadline != null) {
      NotificationService.scheduleTaskReminder(
        taskId: task.id,
        taskTitle: task.title,
        deadline: deadline,
      );
    }
  }

  Future<void> toggleComplete(TaskModel task) async {
    task.isCompleted = !task.isCompleted;
    await DatabaseService.updateTask(task);
    if (task.isCompleted) {
      await NotificationService.cancelTaskNotifications(task.id);
    }
    loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await DatabaseService.updateTask(task);
    loadTasks();
    // Reschedule notifications in background
    if (task.deadline != null && !task.isCompleted) {
      NotificationService.cancelTaskNotifications(task.id).then((_) {
        NotificationService.scheduleTaskReminder(
          taskId: task.id,
          taskTitle: task.title,
          deadline: task.deadline!,
        );
      });
    }
  }

  Future<void> deleteTask(String id) async {
    await NotificationService.cancelTaskNotifications(id);
    await DatabaseService.deleteTask(id);
    loadTasks();
  }
}
