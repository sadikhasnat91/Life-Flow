import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/goal_controller.dart';
import '../../controllers/habit_controller.dart';
import '../../controllers/note_controller.dart';
import '../../controllers/profile_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => TaskController(), fenix: true);
    Get.lazyPut(() => GoalController(), fenix: true);
    Get.lazyPut(() => HabitController(), fenix: true);
    Get.lazyPut(() => NoteController(), fenix: true);
  }
}
