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
    final analytics = AnalyticsService();
    
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
                    value: '${analytics.totalTasksCompleted}',
                    icon: Icons.task,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnalyticsCard(
                    title: 'Habits Completed',
                    value: '${analytics.totalHabitsCompleted}',
                    icon: Icons.repeat,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AnalyticsCard(
                    title: 'Sessions',
                    value: '${analytics.totalSessions}',
                    icon: Icons.timer,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnalyticsCard(
                    title: 'Active Minutes',
                    value: '${analytics.totalActiveMinutes}',
                    icon: Icons.access_time,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskAnalytics(BuildContext context) {
    final analytics = AnalyticsService();
    final taskProvider = context.watch<TaskProvider>();
    
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
              value: '${(taskProvider.completionRate * 100).toInt()}%',
              icon: Icons.check_circle,
              color: AppTheme.primaryGreen,
            ),
            
            const SizedBox(height: 12),
            
            // Most Productive Category
            _AnalyticsRow(
              label: 'Most Productive Category',
              value: analytics.mostProductiveCategory,
              icon: Icons.category,
              color: AppTheme.primaryBlue,
            ),
            
            const SizedBox(height: 12),
            
            // Most Productive Time
            _AnalyticsRow(
              label: 'Most Productive Time',
              value: analytics.mostProductiveTime,
              icon: Icons.schedule,
              color: AppTheme.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitAnalytics(BuildContext context) {
    final analytics = AnalyticsService();
    final habitProvider = context.watch<HabitProvider>();
    
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
            
            // Today's Completion Rate
            _AnalyticsRow(
              label: 'Today\'s Completion Rate',
              value: '${(habitProvider.todayCompletionRate * 100).toInt()}%',
              icon: Icons.trending_up,
              color: AppTheme.primaryGreen,
            ),
            
            const SizedBox(height: 12),
            
            // Longest Streak
            _AnalyticsRow(
              label: 'Longest Streak',
              value: '${analytics.longestHabitStreak} days',
              icon: Icons.local_fire_department,
              color: AppTheme.primaryOrange,
            ),
            
            const SizedBox(height: 12),
            
            // Average Completion Rate
            _AnalyticsRow(
              label: 'Average Completion Rate',
              value: '${(analytics.averageHabitCompletionRate * 100).toInt()}%',
              icon: Icons.analytics,
              color: AppTheme.primaryPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress(BuildContext context) {
    final analytics = AnalyticsService();
    final weeklyProgress = analytics.weeklyTaskProgress;
    
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
            
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < 7; i++)
                    _WeeklyBar(
                      day: _getDayLabel(i),
                      value: weeklyProgress[i],
                      maxValue: weeklyProgress.isNotEmpty ? weeklyProgress.reduce((a, b) => a > b ? a : b) : 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(BuildContext context) {
    final analytics = AnalyticsService();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Insights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.1),
                    AppTheme.primaryPurple.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Productivity Insight',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analytics.productivityInsight,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayLabel(int index) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[index];
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
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

class _WeeklyBar extends StatelessWidget {
  final String day;
  final int value;
  final int maxValue;

  const _WeeklyBar({
    required this.day,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final height = maxValue > 0 ? (value / maxValue) * 60 : 0.0;
    
    return Column(
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
} 