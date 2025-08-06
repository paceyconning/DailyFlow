import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/habit.dart';

class AIMemoryService {
  static final AIMemoryService _instance = AIMemoryService._internal();
  factory AIMemoryService() => _instance;
  AIMemoryService._internal();

  // Memory keys
  static const String _taskHistoryKey = 'ai_task_history';
  static const String _habitHistoryKey = 'ai_habit_history';
  static const String _userPatternsKey = 'ai_user_patterns';
  static const String _productivityStatsKey = 'ai_productivity_stats';
  static const String _preferencesKey = 'ai_preferences';
  static const String _aiInsightsHistoryKey = 'ai_insights_history';

  /// Store task data for AI memory
  Future<void> storeTaskData(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Store current tasks
    final taskData = tasks.map((task) => {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'priority': task.priority.name,
      'category': task.category.name,
      'isCompleted': task.isCompleted,
      'dueDate': task.dueDate?.toIso8601String(),
      'createdAt': task.createdAt.toIso8601String(),
      'completedAt': task.completedAt?.toIso8601String(),
      'estimatedMinutes': task.estimatedMinutes,
      'tags': task.tags,
    }).toList();

    await prefs.setString(_taskHistoryKey, jsonEncode(taskData));
    
    // Update productivity stats
    await _updateProductivityStats(tasks);
  }

  /// Store habit data for AI memory
  Future<void> storeHabitData(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Store current habits
    final habitData = habits.map((habit) => {
      'id': habit.id,
      'title': habit.title,
      'description': habit.description,
      'category': habit.category.name,
      'frequency': habit.frequencyLabel,
      'isActive': habit.isActive,
      'currentStreak': habit.currentStreak,
      'longestStreak': habit.longestStreak,
      'completions': habit.completions.map((key, value) => MapEntry(key, value.toIso8601String())),
      'createdAt': habit.createdAt.toIso8601String(),
      'targetCount': habit.targetCount,
      'currentCount': habit.currentCount,
    }).toList();

    await prefs.setString(_habitHistoryKey, jsonEncode(habitData));
    
    // Update user patterns
    await _updateUserPatterns(habits);
  }

  /// Get task history for AI analysis
  Future<List<Map<String, dynamic>>> getTaskHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final taskHistoryJson = prefs.getString(_taskHistoryKey);
    
    if (taskHistoryJson != null) {
      try {
        final List<dynamic> taskData = jsonDecode(taskHistoryJson);
        return taskData.map((task) => task as Map<String, dynamic>).toList();
      } catch (e) {
        print('Error parsing task history: $e');
      }
    }
    
    return [];
  }

  /// Get habit history for AI analysis
  Future<List<Map<String, dynamic>>> getHabitHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final habitHistoryJson = prefs.getString(_habitHistoryKey);
    
    if (habitHistoryJson != null) {
      try {
        final List<dynamic> habitData = jsonDecode(habitHistoryJson);
        return habitData.map((habit) => habit as Map<String, dynamic>).toList();
      } catch (e) {
        print('Error parsing habit history: $e');
      }
    }
    
    return [];
  }

  /// Get user patterns for AI analysis
  Future<Map<String, dynamic>> getUserPatterns() async {
    final prefs = await SharedPreferences.getInstance();
    final patternsJson = prefs.getString(_userPatternsKey);
    
    if (patternsJson != null) {
      try {
        return jsonDecode(patternsJson);
      } catch (e) {
        print('Error parsing user patterns: $e');
      }
    }
    
    return {};
  }

  /// Get productivity stats for AI analysis
  Future<Map<String, dynamic>> getProductivityStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_productivityStatsKey);
    
    if (statsJson != null) {
      try {
        return jsonDecode(statsJson);
      } catch (e) {
        print('Error parsing productivity stats: $e');
      }
    }
    
    return {};
  }

  /// Store AI insights history
  Future<void> storeAIInsight(Map<String, dynamic> insight) async {
    final prefs = await SharedPreferences.getInstance();
    final insightsJson = prefs.getString(_aiInsightsHistoryKey);
    
    List<Map<String, dynamic>> insights = [];
    if (insightsJson != null) {
      try {
        final List<dynamic> insightsData = jsonDecode(insightsJson);
        insights = insightsData.map((i) => i as Map<String, dynamic>).toList();
      } catch (e) {
        print('Error parsing AI insights history: $e');
      }
    }
    
    // Add timestamp to insight
    insight['timestamp'] = DateTime.now().toIso8601String();
    insights.add(insight);
    
    // Keep only last 50 insights
    if (insights.length > 50) {
      insights = insights.sublist(insights.length - 50);
    }
    
    await prefs.setString(_aiInsightsHistoryKey, jsonEncode(insights));
  }

  /// Get AI insights history
  Future<List<Map<String, dynamic>>> getAIInsightsHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final insightsJson = prefs.getString(_aiInsightsHistoryKey);
    
    if (insightsJson != null) {
      try {
        final List<dynamic> insightsData = jsonDecode(insightsJson);
        return insightsData.map((i) => i as Map<String, dynamic>).toList();
      } catch (e) {
        print('Error parsing AI insights history: $e');
      }
    }
    
    return [];
  }

  /// Store user preferences for AI personalization
  Future<void> storeUserPreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, jsonEncode(preferences));
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_preferencesKey);
    
    if (preferencesJson != null) {
      try {
        return jsonDecode(preferencesJson);
      } catch (e) {
        print('Error parsing user preferences: $e');
      }
    }
    
    return {};
  }

  /// Get comprehensive user data for AI analysis
  Future<Map<String, dynamic>> getComprehensiveUserData() async {
    final taskHistory = await getTaskHistory();
    final habitHistory = await getHabitHistory();
    final userPatterns = await getUserPatterns();
    final productivityStats = await getProductivityStats();
    final userPreferences = await getUserPreferences();
    final aiInsightsHistory = await getAIInsightsHistory();

    return {
      'taskHistory': taskHistory,
      'habitHistory': habitHistory,
      'userPatterns': userPatterns,
      'productivityStats': productivityStats,
      'userPreferences': userPreferences,
      'aiInsightsHistory': aiInsightsHistory,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Update productivity statistics
  Future<void> _updateProductivityStats(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final stats = await getProductivityStats();
    
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;
    final highPriorityTasks = tasks.where((t) => t.priority == TaskPriority.high).length;
    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    
    // Calculate completion rates by category
    final categoryStats = <String, Map<String, dynamic>>{};
    for (final task in tasks) {
      final category = task.category.name;
      if (!categoryStats.containsKey(category)) {
        categoryStats[category] = {'total': 0, 'completed': 0};
      }
      categoryStats[category]!['total'] = (categoryStats[category]!['total'] as int) + 1;
      if (task.isCompleted) {
        categoryStats[category]!['completed'] = (categoryStats[category]!['completed'] as int) + 1;
      }
    }
    
    // Update stats
    stats['totalTasks'] = (stats['totalTasks'] ?? 0) + totalTasks;
    stats['completedTasks'] = (stats['completedTasks'] ?? 0) + completedTasks;
    stats['highPriorityTasks'] = highPriorityTasks;
    stats['overdueTasks'] = overdueTasks;
    stats['completionRate'] = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    stats['categoryStats'] = categoryStats;
    stats['lastUpdated'] = DateTime.now().toIso8601String();
    
    await prefs.setString(_productivityStatsKey, jsonEncode(stats));
  }

  /// Update user patterns based on habits
  Future<void> _updateUserPatterns(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final patterns = await getUserPatterns();
    
    // Analyze habit patterns
    final activeHabits = habits.where((h) => h.isActive).length;
    final avgStreak = habits.isNotEmpty 
        ? habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / habits.length 
        : 0;
    
    // Category preferences
    final categoryCounts = <String, int>{};
    for (final habit in habits) {
      final category = habit.category.name;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    
    // Frequency preferences
    final frequencyCounts = <String, int>{};
    for (final habit in habits) {
      final frequency = habit.frequencyLabel;
      frequencyCounts[frequency] = (frequencyCounts[frequency] ?? 0) + 1;
    }
    
    // Update patterns
    patterns['activeHabits'] = activeHabits;
    patterns['averageStreak'] = avgStreak;
    patterns['categoryPreferences'] = categoryCounts;
    patterns['frequencyPreferences'] = frequencyCounts;
    patterns['lastUpdated'] = DateTime.now().toIso8601String();
    
    await prefs.setString(_userPatternsKey, jsonEncode(patterns));
  }

  /// Clear all AI memory data
  Future<void> clearAllMemory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_taskHistoryKey);
    await prefs.remove(_habitHistoryKey);
    await prefs.remove(_userPatternsKey);
    await prefs.remove(_productivityStatsKey);
    await prefs.remove(_preferencesKey);
    await prefs.remove(_aiInsightsHistoryKey);
  }

  /// Get memory usage statistics
  Future<Map<String, dynamic>> getMemoryUsage() async {
    final taskHistory = await getTaskHistory();
    final habitHistory = await getHabitHistory();
    final aiInsightsHistory = await getAIInsightsHistory();
    
    return {
      'taskRecords': taskHistory.length,
      'habitRecords': habitHistory.length,
      'aiInsights': aiInsightsHistory.length,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
} 