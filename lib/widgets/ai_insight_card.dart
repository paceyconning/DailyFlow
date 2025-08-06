import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/ai_provider.dart';
import '../utils/theme.dart';

class AIInsightCard extends StatefulWidget {
  const AIInsightCard({super.key});

  @override
  State<AIInsightCard> createState() => _AIInsightCardState();
}

class _AIInsightCardState extends State<AIInsightCard> {
  @override
  void initState() {
    super.initState();
    // Trigger AI insights generation when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateInsights();
    });
  }

  void _generateInsights() {
    final aiProvider = context.read<AIProvider>();
    final taskProvider = context.read<TaskProvider>();
    final habitProvider = context.read<HabitProvider>();
    
    final tasks = taskProvider.tasks;
    final habits = habitProvider.habits;
    final userStats = {
      'completionRate': taskProvider.completionRate,
      'mostProductiveTime': 'Morning',
      'averageStreak': habits.isNotEmpty 
          ? habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / habits.length 
          : 0,
    };

    aiProvider.generateInsights(
      tasks: tasks,
      habits: habits,
      userStats: userStats,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<TaskProvider, HabitProvider, AIProvider>(
      builder: (context, taskProvider, habitProvider, aiProvider, child) {
        final todayTasks = taskProvider.getTodayTasks();
        final todayHabits = habitProvider.getTodayHabits();
        final completedTasks = todayTasks.where((t) => t.isCompleted).length;
        final completedHabits = habitProvider.getCompletedTodayHabits().length;
        final overdueTasks = taskProvider.getOverdueTasks();
        
        // Get AI insights
        final insights = aiProvider.insights;
        final motivationalMessage = aiProvider.motivationalMessage;
        final isLoading = aiProvider.isLoading;
        
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
          // Use AI-generated insights
          final aiInsights = insights['insights'] as List;
          if (aiInsights.isNotEmpty) {
            final firstInsight = aiInsights.first as Map<String, dynamic>;
            insight = firstInsight['title'] ?? 'AI Insight';
            subtitle = firstInsight['description'] ?? motivationalMessage;
            
            // Set color based on insight type
            final type = firstInsight['type'] ?? 'productivity';
            switch (type) {
              case 'productivity':
                color = AppTheme.primaryBlue;
                icon = Icons.trending_up;
                break;
              case 'habit':
                color = AppTheme.primaryGreen;
                icon = Icons.repeat;
                break;
              case 'motivation':
                color = AppTheme.primaryOrange;
                icon = Icons.psychology;
                break;
              case 'task':
                color = AppTheme.primaryPurple;
                icon = Icons.task;
                break;
              default:
                color = AppTheme.primaryBlue;
                icon = Icons.psychology;
            }
          } else {
            // Fallback to basic insights
            _generateBasicInsight(
              todayTasks, todayHabits, completedTasks, completedHabits, overdueTasks,
              (i, s, ic, c) {
                insight = i;
                subtitle = s;
                icon = ic;
                color = c;
              },
            );
          }
        } else {
          // Fallback to basic insights
          _generateBasicInsight(
            todayTasks, todayHabits, completedTasks, completedHabits, overdueTasks,
            (i, s, ic, c) {
              insight = i;
              subtitle = s;
              icon = ic;
              color = c;
            },
          );
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
                      ],
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
                             if (!isLoading)
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: color.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: _generateInsights,
                  tooltip: 'Refresh AI insights',
                ),
            ],
          ),
        );
      },
    );
  }

  void _generateBasicInsight(
    List tasks,
    List habits,
    int completedTasks,
    int completedHabits,
    List overdueTasks,
    Function(String, String, IconData, Color) callback,
  ) {
    String insight;
    String subtitle;
    IconData icon;
    Color color;
    
    if (tasks.isEmpty && habits.isEmpty) {
      insight = 'Welcome to DailyFlow!';
      subtitle = 'Start by adding your first task or habit to begin your productivity journey.';
      icon = Icons.rocket_launch;
      color = AppTheme.primaryBlue;
    } else if (completedTasks == tasks.length && completedHabits == habits.length) {
      insight = 'Amazing work today!';
      subtitle = 'You\'ve completed all your tasks and habits. You\'re on fire! 🔥';
      icon = Icons.celebration;
      color = AppTheme.primaryGreen;
    } else if (overdueTasks.isNotEmpty) {
      insight = 'You have overdue tasks';
      subtitle = 'Consider prioritizing these tasks to stay on track.';
      icon = Icons.warning;
      color = AppTheme.primaryRed;
    } else if (completedTasks > 0 && completedTasks < tasks.length) {
      insight = 'Great progress!';
      subtitle = 'You\'ve completed $completedTasks/${tasks.length} tasks. Keep going!';
      icon = Icons.trending_up;
      color = AppTheme.primaryOrange;
    } else if (completedHabits > 0) {
      insight = 'Building consistency!';
      subtitle = 'You\'ve completed $completedHabits/${habits.length} habits today.';
      icon = Icons.repeat;
      color = AppTheme.primaryGreen;
    } else {
      insight = 'Ready to start?';
      subtitle = 'You have ${tasks.length} tasks and ${habits.length} habits for today.';
      icon = Icons.play_arrow;
      color = AppTheme.primaryBlue;
    }
    
    callback(insight, subtitle, icon, color);
  }
} 