import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../services/analytics_service.dart';
import '../utils/theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh analytics
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analytics refreshed')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Productivity Overview
            _buildProductivityOverview(context),
            const SizedBox(height: 24),
            
            // Task Analytics
            _buildTaskAnalytics(context),
            const SizedBox(height: 24),
            
            // Habit Analytics
            _buildHabitAnalytics(context),
            const SizedBox(height: 24),
            
            // Weekly Progress
            _buildWeeklyProgress(context),
            const SizedBox(height: 24),
            
            // Insights
            _buildInsights(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityOverview(BuildContext context) {
    return Consumer2<TaskProvider, HabitProvider>(
      builder: (context, taskProvider, habitProvider, child) {
        final completedTasks = taskProvider.tasks.where((t) => t.isCompleted).length;
        final totalTasks = taskProvider.tasks.length;
        final activeHabits = habitProvider.habits.where((h) => h.isActive).length;
        final totalHabits = habitProvider.habits.length;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productivity Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Tasks Completed',
                        value: '$completedTasks',
                        subtitle: 'of $totalTasks total',
                        icon: Icons.task,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Habits Active',
                        value: '$activeHabits',
                        subtitle: 'of $totalHabits total',
                        icon: Icons.repeat,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskAnalytics(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final completionRate = taskProvider.completionRate;
        final totalTasks = taskProvider.totalTasksCount;
        final completedTasks = taskProvider.completedTasksCount;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Analytics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Completion Rate
                _AnalyticsRow(
                  label: 'Completion Rate',
                  value: '${(completionRate * 100).toInt()}%',
                  icon: Icons.check_circle,
                  color: AppTheme.primaryGreen,
                ),
                
                const SizedBox(height: 12),
                
                // Total Tasks
                _AnalyticsRow(
                  label: 'Total Tasks',
                  value: '$totalTasks',
                  icon: Icons.task,
                  color: AppTheme.primaryBlue,
                ),
                
                const SizedBox(height: 12),
                
                // Completed Tasks
                _AnalyticsRow(
                  label: 'Completed Tasks',
                  value: '$completedTasks',
                  icon: Icons.done_all,
                  color: AppTheme.primaryGreen,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitAnalytics(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final totalHabits = habitProvider.habits.length;
        final activeHabits = habitProvider.habits.where((h) => h.isActive).length;
        final avgStreak = habitProvider.habits.isNotEmpty 
            ? habitProvider.habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / habitProvider.habits.length 
            : 0;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habit Analytics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Active Habits
                _AnalyticsRow(
                  label: 'Active Habits',
                  value: '$activeHabits',
                  icon: Icons.repeat,
                  color: AppTheme.primaryGreen,
                ),
                
                const SizedBox(height: 12),
                
                // Average Streak
                _AnalyticsRow(
                  label: 'Average Streak',
                  value: '${avgStreak.toStringAsFixed(1)} days',
                  icon: Icons.local_fire_department,
                  color: AppTheme.primaryOrange,
                ),
                
                const SizedBox(height: 12),
                
                // Total Habits
                _AnalyticsRow(
                  label: 'Total Habits',
                  value: '$totalHabits',
                  icon: Icons.list,
                  color: AppTheme.primaryBlue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyProgress(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Placeholder for weekly progress chart
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Weekly progress chart coming soon...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Insights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Placeholder for insights
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI-powered insights will appear here based on your productivity patterns.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
} 