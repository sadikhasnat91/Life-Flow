import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/habit_controller.dart';
import '../../models/habit_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/common_widgets.dart';
import 'add_habit_screen.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  HabitModel? _selectedHabit;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HabitController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: Obx(() {
        if (ctrl.habits.isEmpty) {
          return const EmptyState(
            icon: Icons.repeat,
            title: 'No habits yet',
            subtitle: 'Build positive habits one day at a time',
          );
        }
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // Weekly progress chart
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Overview',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: ctrl.activeHabits.length.toDouble() + 1,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final keys =
                                      ctrl.weeklyData.keys.toList();
                                  if (value.toInt() < keys.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        keys[value.toInt()],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? AppTheme.darkSubtext
                                              : AppTheme.lightSubtext,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: ctrl.weeklyData.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.value.toDouble(),
                                  color: AppTheme.primaryColor,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: ctrl.activeHabits.length.toDouble(),
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.08),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Calendar View for selected habit
            if (_selectedHabit != null) ...[
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_selectedHabit!.icon} ${_selectedHabit!.title}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () =>
                                setState(() => _selectedHabit = null),
                          ),
                        ],
                      ),
                      TableCalendar(
                        firstDay: DateTime.now()
                            .subtract(const Duration(days: 365)),
                        lastDay: DateTime.now(),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) =>
                            setState(() => _calendarFormat = format),
                        onPageChanged: (focusedDay) =>
                            setState(() => _focusedDay = focusedDay),
                        eventLoader: (day) {
                          if (_selectedHabit!.isCompletedOn(day)) {
                            return ['done'];
                          }
                          return [];
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: AppTheme.accentGreen,
                            shape: BoxShape.circle,
                          ),
                          markerSize: 6,
                          markersMaxCount: 1,
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonShowsNext: false,
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!selectedDay.isAfter(DateTime.now())) {
                            ctrl.toggleHabitDate(_selectedHabit!, selectedDay);
                            setState(() => _focusedDay = focusedDay);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Habit list
            const SectionHeader(title: "Today's Habits"),
            ...ctrl.activeHabits.asMap().entries.map((entry) {
              final habit = entry.value;
              final isDone = habit.isCompletedOn(DateTime.now());

              return FadeInUp(
                delay: Duration(milliseconds: entry.key * 60),
                duration: const Duration(milliseconds: 400),
                child: Dismissible(
                  key: Key(habit.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                  ),
                  onDismissed: (_) => ctrl.deleteHabit(habit.id),
                  child: GlassCard(
                    onTap: () =>
                        ctrl.toggleHabitDate(habit, DateTime.now()),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selectedHabit = habit),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color:
                                  Color(habit.colorValue).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(habit.icon,
                                  style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Text('🔥 ',
                                      style: TextStyle(fontSize: 12)),
                                  Text(
                                    '${habit.currentStreak} day streak',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppTheme.darkSubtext
                                          : AppTheme.lightSubtext,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '⭐ Best: ${habit.longestStreak}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppTheme.darkSubtext
                                          : AppTheme.lightSubtext,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? AppTheme.accentGreen
                                : Colors.transparent,
                            border: Border.all(
                              color: isDone
                                  ? AppTheme.accentGreen
                                  : (isDark
                                      ? AppTheme.darkSubtext
                                      : AppTheme.lightBorder),
                              width: 2,
                            ),
                          ),
                          child: isDone
                              ? const Icon(Icons.check,
                                  size: 20, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddHabitScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
