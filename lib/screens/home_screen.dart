import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';
import '../widgets/stats_card.dart';
import '../widgets/task_list_item.dart';
import '../widgets/habit_list_item.dart';
import '../widgets/ai_insight_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DailyFlow',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      background: Paint()
                        ..shader = AppTheme.primaryGradient.createShader(
                          const Rect.fromLTWH(0, 0, 200, 30),
                        ),
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  context.watch<ThemeProvider>().isDarkMode 
                    ? Icons.light_mode 
                    : Icons.dark_mode,
                ),
                onPressed: () => context.read<ThemeProvider>().toggleTheme(),
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Insight Card
                  const AIInsightCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Stats
                  Text(
                    'Today\'s Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Consumer2<TaskProvider, HabitProvider>(
                    builder: (context, taskProvider, habitProvider, child) {
                      return Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Tasks',
                              value: '${taskProvider.getTodayTasks().length}',
                              subtitle: '${taskProvider.getTodayTasks().where((t) => t.isCompleted).length} completed',
                              icon: Icons.task,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsCard(
                              title: 'Habits',
                              value: '${habitProvider.getTodayHabits().length}',
                              subtitle: '${habitProvider.getCompletedTodayHabits().length} completed',
                              icon: Icons.repeat,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Today's Tasks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Tasks',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to tasks screen
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      final todayTasks = taskProvider.getTodayTasks();
                      if (todayTasks.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.task_outlined,
                                size: 48,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks for today',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add some tasks to get started',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Column(
                        children: todayTasks.take(3).map((task) => 
                          TaskListItem(task: task)
                        ).toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Today's Habits
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Habits',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to habits screen
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Consumer<HabitProvider>(
                    builder: (context, habitProvider, child) {
                      final todayHabits = habitProvider.getTodayHabits();
                      if (todayHabits.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.repeat_outlined,
                                size: 48,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No habits for today',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create some habits to build consistency',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Column(
                        children: todayHabits.take(3).map((habit) => 
                          HabitListItem(habit: habit)
                        ).toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 100), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show add task/habit dialog
          _showAddDialog(context);
        },
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
  
  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add New',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _AddOptionCard(
                    title: 'Task',
                    subtitle: 'Add a new task',
                    icon: Icons.task,
                    color: AppTheme.primaryBlue,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to add task screen
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AddOptionCard(
                    title: 'Habit',
                    subtitle: 'Create a new habit',
                    icon: Icons.repeat,
                    color: AppTheme.primaryGreen,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to add habit screen
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AddOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AddOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 