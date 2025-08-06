import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../utils/theme.dart';

class AIInsightCard extends StatelessWidget {
  const AIInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskProvider, HabitProvider>(
      builder: (context, taskProvider, habitProvider, child) {
        final todayTasks = taskProvider.getTodayTasks();
        final todayHabits = habitProvider.getTodayHabits();
        final completedTasks = todayTasks.where((t) => t.isCompleted).length;
        final completedHabits = habitProvider.getCompletedTodayHabits().length;
        final overdueTasks = taskProvider.getOverdueTasks();
        
        String insight;
        String subtitle;
        IconData icon;
        Color color;
        
        // Generate AI insight based on current state
        if (todayTasks.isEmpty && todayHabits.isEmpty) {
          insight = 'Welcome to DailyFlow!';
          subtitle = 'Start by adding your first task or habit to begin your productivity journey.';
          icon = Icons.rocket_launch;
          color = AppTheme.primaryBlue;
        } else if (completedTasks == todayTasks.length && completedHabits == todayHabits.length) {
          insight = 'Amazing work today!';
          subtitle = 'You\'ve completed all your tasks and habits. You\'re on fire! 🔥';
          icon = Icons.celebration;
          color = AppTheme.primaryGreen;
        } else if (overdueTasks.isNotEmpty) {
          insight = 'You have overdue tasks';
          subtitle = 'Consider prioritizing these tasks to stay on track.';
          icon = Icons.warning;
          color = AppTheme.primaryRed;
        } else if (completedTasks > 0 && completedTasks < todayTasks.length) {
          insight = 'Great progress!';
          subtitle = 'You\'ve completed ${completedTasks}/${todayTasks.length} tasks. Keep going!';
          icon = Icons.trending_up;
          color = AppTheme.primaryOrange;
        } else if (completedHabits > 0) {
          insight = 'Building consistency!';
          subtitle = 'You\'ve completed ${completedHabits}/${todayHabits.length} habits today.';
          icon = Icons.repeat;
          color = AppTheme.primaryGreen;
        } else {
          insight = 'Ready to start?';
          subtitle = 'You have ${todayTasks.length} tasks and ${todayHabits.length} habits for today.';
          icon = Icons.play_arrow;
          color = AppTheme.primaryBlue;
        }
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Insight',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 