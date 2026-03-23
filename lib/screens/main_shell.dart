import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard/dashboard_screen.dart';
import 'tasks/task_list_screen.dart';
import 'goals/goal_list_screen.dart';
import 'habits/habit_list_screen.dart';
import 'notes/note_list_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatelessWidget {
  MainShell({super.key});

  final _currentIndex = 0.obs;

  final _screens = const [
    DashboardScreen(),
    TaskListScreen(),
    GoalListScreen(),
    HabitListScreen(),
    NoteListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: _currentIndex.value,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex.value,
              onTap: (i) => _currentIndex.value = i,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.task_alt_outlined),
                  activeIcon: Icon(Icons.task_alt),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.flag_outlined),
                  activeIcon: Icon(Icons.flag),
                  label: 'Goals',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.repeat_rounded),
                  activeIcon: Icon(Icons.repeat),
                  label: 'Habits',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.note_alt_outlined),
                  activeIcon: Icon(Icons.note_alt),
                  label: 'Notes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ));
  }
}
