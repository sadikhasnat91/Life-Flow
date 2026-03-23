import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime? deadline;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  int priority; // 0=low, 1=medium, 2=high

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String? category;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.deadline,
    this.isCompleted = false,
    this.priority = 1,
    required this.createdAt,
    this.category,
  });

  String get priorityLabel {
    switch (priority) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Medium';
    }
  }
}
