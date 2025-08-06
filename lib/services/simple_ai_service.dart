import '../models/task.dart';
import '../models/habit.dart';
import 'ai_memory_service.dart';

class SimpleAIService {
  static final SimpleAIService _instance = SimpleAIService._internal();
  factory SimpleAIService() => _instance;
  SimpleAIService._internal();

  // AI Memory Service
  final AIMemoryService _memoryService = AIMemoryService();

  /// Generate basic insights for free users
  Future<Map<String, dynamic>> generateInsights({
    required List<Task> tasks,
    required List<Habit> habits,
    required Map<String, dynamic> userStats,
  }) async {
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;
    final activeHabits = habits.where((h) => h.isActive).length;
    final avgStreak = habits.isNotEmpty 
        ? habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / habits.length 
        : 0;

    // Store data in AI memory
    await _memoryService.storeTaskData(tasks);
    await _memoryService.storeHabitData(habits);
    
    // Get user data for enhanced insights
    final userData = await _memoryService.getComprehensiveUserData();
    final taskHistory = userData['taskHistory'] as List? ?? [];
    final habitHistory = userData['habitHistory'] as List? ?? [];
    final userPatterns = userData['userPatterns'] as Map<String, dynamic>? ?? {};

    final insights = <Map<String, dynamic>>[];

    // Enhanced productivity insight with memory
    if (totalTasks > 0) {
      final completionRate = completedTasks / totalTasks;
      final historicalCompletionRate = userData['productivityStats']?['completionRate'] ?? 0.0;
      
      if (completionRate < 0.5) {
        insights.add({
          'title': 'Focus on Completion',
          'description': 'Based on your history, try to complete at least half of your tasks today to build momentum.',
          'action': 'Pick your 3 most important tasks and complete them first.',
          'type': 'productivity'
        });
      } else if (completionRate >= 0.8) {
        insights.add({
          'title': 'Excellent Progress!',
          'description': 'You\'re completing most of your tasks. Keep up the great work!',
          'action': 'Consider adding more challenging tasks to push yourself further.',
          'type': 'productivity'
        });
      } else {
        insights.add({
          'title': 'Good Progress',
          'description': 'You\'re making steady progress on your tasks.',
          'action': 'Focus on completing the remaining tasks to finish strong.',
          'type': 'productivity'
        });
      }
    }

    // Enhanced habit insight with memory
    if (activeHabits > 0) {
      final historicalAvgStreak = userPatterns['averageStreak'] ?? 0.0;
      final categoryPreferences = userPatterns['categoryPreferences'] as Map<String, dynamic>? ?? {};
      
      if (avgStreak >= 7) {
        insights.add({
          'title': 'Strong Habits',
          'description': 'Your habit streaks show excellent consistency. You\'re building lasting routines.',
          'action': 'Consider adding a new habit to expand your positive routines.',
          'type': 'habit'
        });
      } else if (avgStreak >= 3) {
        insights.add({
          'title': 'Building Consistency',
          'description': 'You\'re developing good habit patterns. Keep going!',
          'action': 'Focus on maintaining your current streaks to build lasting habits.',
          'type': 'habit'
        });
      } else {
        insights.add({
          'title': 'Start Small',
          'description': 'Focus on building one habit at a time to establish consistency.',
          'action': 'Choose one habit to focus on and track it daily.',
          'type': 'habit'
        });
      }
    }

    // Motivation insight
    if (insights.length < 3) {
      insights.add({
        'title': 'Track Your Progress',
        'description': 'Monitor your daily completion rates to identify patterns and improve.',
        'action': 'Review your analytics regularly to see what\'s working best.',
        'type': 'motivation'
      });
    }

    return {
      'insights': insights,
      'priority_tasks': _getPriorityTasks(tasks),
      'motivational_message': _generateMotivationalMessage(userStats, tasks, habits),
    };
  }

  /// Basic task prioritization for free users
  List<Task> prioritizeTasks(List<Task> tasks) {
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    
    // Simple prioritization: high priority first, then by due date
    pendingTasks.sort((a, b) {
      // High priority tasks first
      if (a.priority == TaskPriority.high && b.priority != TaskPriority.high) return -1;
      if (b.priority == TaskPriority.high && a.priority != TaskPriority.high) return 1;
      
      // Then by due date (earliest first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      
      // Then by creation date (oldest first)
      return a.createdAt.compareTo(b.createdAt);
    });
    
    return pendingTasks;
  }

  /// Generate basic habit suggestions
  List<Map<String, dynamic>> generateHabitSuggestions({
    required List<Habit> currentHabits,
    required Map<String, dynamic> userStats,
  }) {
    final suggestions = <Map<String, dynamic>>[];
    
    // Check if user has morning routine
    final hasMorningRoutine = currentHabits.any((h) => 
        h.title.toLowerCase().contains('morning') || 
        h.title.toLowerCase().contains('wake'));
    
    if (!hasMorningRoutine) {
      suggestions.add({
        'title': 'Morning Routine',
        'description': 'Start your day with a consistent morning routine for better productivity.',
        'frequency': 'daily',
        'category': 'productivity',
        'difficulty': 'medium'
      });
    }

    // Check if user has evening reflection
    final hasEveningReflection = currentHabits.any((h) => 
        h.title.toLowerCase().contains('evening') || 
        h.title.toLowerCase().contains('reflect'));
    
    if (!hasEveningReflection) {
      suggestions.add({
        'title': 'Evening Reflection',
        'description': 'Take 5 minutes each evening to reflect on your day and plan tomorrow.',
        'frequency': 'daily',
        'category': 'productivity',
        'difficulty': 'easy'
      });
    }

    // Check if user has health habits
    final hasHealthHabits = currentHabits.any((h) => 
        h.category == HabitCategory.health);
    
    if (!hasHealthHabits) {
      suggestions.add({
        'title': 'Daily Exercise',
        'description': 'Include 30 minutes of physical activity in your daily routine.',
        'frequency': 'daily',
        'category': 'health',
        'difficulty': 'medium'
      });
    }

    // If we don't have enough suggestions, add generic ones
    while (suggestions.length < 2) {
      suggestions.add({
        'title': 'Read Daily',
        'description': 'Read for 20 minutes each day to expand your knowledge.',
        'frequency': 'daily',
        'category': 'learning',
        'difficulty': 'easy'
      });
    }

    return suggestions;
  }

  /// Generate motivational message
  String generateMotivationalMessage({
    required Map<String, dynamic> userStats,
    required List<Task> recentTasks,
    required List<Habit> recentHabits,
  }) {
    final completionRate = userStats['completionRate'] ?? 0.0;
    final avgStreak = userStats['averageStreak'] ?? 0.0;

    if (completionRate > 0.8) {
      return 'You\'re absolutely crushing it! Your high completion rate shows incredible discipline.';
    } else if (completionRate > 0.5) {
      return 'Great progress! You\'re consistently completing tasks and building momentum.';
    } else if (avgStreak > 5) {
      return 'Your habit streaks are impressive! You\'re building lasting positive routines.';
    } else if (recentTasks.isNotEmpty || recentHabits.isNotEmpty) {
      return 'Every step counts! You\'re making progress and building better habits.';
    } else {
      return 'You\'re doing great! Every small step counts toward your goals.';
    }
  }

  /// Get priority tasks based on simple rules
  List<String> _getPriorityTasks(List<Task> tasks) {
    final highPriorityTasks = tasks
        .where((t) => !t.isCompleted && t.priority == TaskPriority.high)
        .take(3)
        .map((t) => t.title)
        .toList();
    
    return highPriorityTasks;
  }

  /// Generate motivational message
  String _generateMotivationalMessage(Map<String, dynamic> userStats, List<Task> tasks, List<Habit> habits) {
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;
    
    if (totalTasks > 0 && completedTasks / totalTasks > 0.7) {
      return 'You\'re making excellent progress! Keep up the momentum.';
    } else if (habits.isNotEmpty) {
      return 'Your habit tracking shows dedication. Every day counts!';
    } else {
      return 'You\'re doing great! Every small step counts toward your goals.';
    }
  }
} 