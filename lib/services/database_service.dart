import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/goal_model.dart';
import '../models/habit_model.dart';
import '../models/note_model.dart';
import '../models/user_profile_model.dart';

class DatabaseService {
  static const String taskBox = 'tasks';
  static const String goalBox = 'goals';
  static const String habitBox = 'habits';
  static const String noteBox = 'notes';
  static const String profileBox = 'profile';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(NoteModelAdapter());
    Hive.registerAdapter(UserProfileModelAdapter());

    await Hive.openBox<TaskModel>(taskBox);
    await Hive.openBox<GoalModel>(goalBox);
    await Hive.openBox<HabitModel>(habitBox);
    await Hive.openBox<NoteModel>(noteBox);
    await Hive.openBox<UserProfileModel>(profileBox);
  }

  // ─── Tasks ───
  static Box<TaskModel> get tasks => Hive.box<TaskModel>(taskBox);

  static Future<void> addTask(TaskModel task) async {
    await tasks.put(task.id, task);
  }

  static Future<void> updateTask(TaskModel task) async {
    await task.save();
  }

  static Future<void> deleteTask(String id) async {
    await tasks.delete(id);
  }

  static List<TaskModel> getAllTasks() => tasks.values.toList();

  // ─── Goals ───
  static Box<GoalModel> get goals => Hive.box<GoalModel>(goalBox);

  static Future<void> addGoal(GoalModel goal) async {
    await goals.put(goal.id, goal);
  }

  static Future<void> updateGoal(GoalModel goal) async {
    await goal.save();
  }

  static Future<void> deleteGoal(String id) async {
    await goals.delete(id);
  }

  static List<GoalModel> getAllGoals() => goals.values.toList();

  // ─── Habits ───
  static Box<HabitModel> get habits => Hive.box<HabitModel>(habitBox);

  static Future<void> addHabit(HabitModel habit) async {
    await habits.put(habit.id, habit);
  }

  static Future<void> updateHabit(HabitModel habit) async {
    await habit.save();
  }

  static Future<void> deleteHabit(String id) async {
    await habits.delete(id);
  }

  static List<HabitModel> getAllHabits() => habits.values.toList();

  // ─── Notes ───
  static Box<NoteModel> get notes => Hive.box<NoteModel>(noteBox);

  static Future<void> addNote(NoteModel note) async {
    await notes.put(note.id, note);
  }

  static Future<void> updateNote(NoteModel note) async {
    await note.save();
  }

  static Future<void> deleteNote(String id) async {
    await notes.delete(id);
  }

  static List<NoteModel> getAllNotes() => notes.values.toList();

  // ─── Profile ───
  static Box<UserProfileModel> get profileStore =>
      Hive.box<UserProfileModel>(profileBox);

  static UserProfileModel getProfile() {
    if (profileStore.isEmpty) {
      final profile = UserProfileModel(createdAt: DateTime.now());
      profileStore.put('default', profile);
      return profile;
    }
    return profileStore.get('default')!;
  }

  static Future<void> updateProfile(UserProfileModel profile) async {
    await profileStore.put('default', profile);
  }
}
