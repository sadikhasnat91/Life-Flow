import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 1)
class GoalModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime targetDate;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  List<String> milestones;

  @HiveField(7)
  List<bool> milestoneCompleted;

  GoalModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.targetDate,
    this.isCompleted = false,
    required this.createdAt,
    List<String>? milestones,
    List<bool>? milestoneCompleted,
  })  : milestones = milestones ?? [],
        milestoneCompleted = milestoneCompleted ?? [];

  double get progress {
    if (isCompleted) return 1.0;
    if (milestones.isEmpty) return 0.0;
    final completed = milestoneCompleted.where((e) => e).length;
    return completed / milestones.length;
  }

  bool get isOverdue => !isCompleted && DateTime.now().isAfter(targetDate);

  Duration get timeRemaining => targetDate.difference(DateTime.now());
}
