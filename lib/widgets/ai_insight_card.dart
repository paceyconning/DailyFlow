import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../utils/theme.dart';

class AIInsightCard extends StatefulWidget {
  const AIInsightCard({super.key});

  @override
  State<AIInsightCard> createState() => _AIInsightCardState();
}

class _AIInsightCardState extends State<AIInsightCard> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAI();
    });
  }

  void _initializeAI() {
    if (!_hasInitialized) {
      final aiProvider = context.read<AIProvider>();
      final taskProvider = context.read<TaskProvider>();
      final habitProvider = context.read<HabitProvider>();
      
      // Generate initial insights
      aiProvider.generateInsights(
        tasks: taskProvider.tasks,
        habits: habitProvider.habits,
        userStats: _getUserStats(taskProvider, habitProvider),
      );
      
      setState(() {
        _hasInitialized = true;
      });
    }
  }

  Map<String, dynamic> _getUserStats(TaskProvider taskProvider, HabitProvider habitProvider) {
    final completedTasks = taskProvider.tasks.where((t) => t.isCompleted).length;
    final totalTasks = taskProvider.tasks.length;
    final activeHabits = habitProvider.habits.where((h) => h.isActive).length;
    final avgStreak = habitProvider.habits.isNotEmpty 
        ? habitProvider.habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / habitProvider.habits.length 
        : 0;

    return {
      'completionRate': totalTasks > 0 ? completedTasks / totalTasks : 0.0,
      'averageStreak': avgStreak,
      'activeHabits': activeHabits,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AIProvider, TaskProvider, HabitProvider>(
      builder: (context, aiProvider, taskProvider, habitProvider, child) {
        final isLoading = aiProvider.isLoading;
        final insights = aiProvider.insights;
        
        String insight = 'Welcome to DailyFlow!';
        String subtitle = 'Start by adding your first task or habit to begin your productivity journey.';
        IconData icon = Icons.rocket_launch;
        Color color = AppTheme.primaryBlue;
        
        if (isLoading) {
          insight = 'Analyzing your data...';
          subtitle = 'AI is generating personalized insights for you.';
          icon = Icons.psychology;
          color = AppTheme.primaryPurple;
        } else if (insights.isNotEmpty && insights['insights'] != null) {
          final insightsList = insights['insights'] as List?;
          if (insightsList != null && insightsList.isNotEmpty) {
            final firstInsight = insightsList.first as Map<String, dynamic>;
            insight = firstInsight['title'] ?? 'Productivity Insight';
            subtitle = firstInsight['description'] ?? 'Keep up the great work!';
            
            // Set icon and color based on insight type
            final type = firstInsight['type'] ?? 'motivation';
            switch (type) {
              case 'productivity':
                icon = Icons.trending_up;
                color = AppTheme.primaryGreen;
                break;
              case 'habit':
                icon = Icons.repeat;
                color = AppTheme.primaryOrange;
                break;
              case 'task':
                icon = Icons.task;
                color = AppTheme.primaryBlue;
                break;
              default:
                icon = Icons.psychology;
                color = AppTheme.primaryPurple;
            }
          }
        } else if (taskProvider.tasks.isNotEmpty || habitProvider.habits.isNotEmpty) {
          // Generate basic insights based on user data
          final stats = _getUserStats(taskProvider, habitProvider);
          final completionRate = stats['completionRate'] as double;
          final avgStreak = stats['averageStreak'] as double;
          
          if (completionRate > 0.8) {
            insight = 'Excellent Progress!';
            subtitle = 'You\'re completing most of your tasks. Keep up the momentum!';
            icon = Icons.trending_up;
            color = AppTheme.primaryGreen;
          } else if (completionRate > 0.5) {
            insight = 'Good Progress';
            subtitle = 'You\'re making steady progress. Focus on completing the remaining tasks.';
            icon = Icons.task;
            color = AppTheme.primaryBlue;
          } else if (avgStreak > 5) {
            insight = 'Strong Habits';
            subtitle = 'Your habit streaks show excellent consistency. You\'re building lasting routines.';
            icon = Icons.repeat;
            color = AppTheme.primaryOrange;
          } else if (taskProvider.tasks.isNotEmpty || habitProvider.habits.isNotEmpty) {
            insight = 'Building Momentum';
            subtitle = 'Every step counts! You\'re making progress and building better habits.';
            icon = Icons.psychology;
            color = AppTheme.primaryPurple;
          }
        }

        return Card(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      aiProvider.isUsingAdvancedAI ? 'Advanced AI Insight' : 'AI Insight',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (aiProvider.isUsingAdvancedAI) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.star,
                        color: AppTheme.primaryPurple,
                        size: 12,
                      ),
                    ],
                    if (isLoading) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (!isLoading)
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: color.withOpacity(0.7),
                          size: 20,
                        ),
                        onPressed: () {
                          aiProvider.generateInsights(
                            tasks: taskProvider.tasks,
                            habits: habitProvider.habits,
                            userStats: _getUserStats(taskProvider, habitProvider),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
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
                            insight,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (insights.isNotEmpty && insights['insights'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insights['motivational_message'] ?? 'Keep up the great work!',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
} 