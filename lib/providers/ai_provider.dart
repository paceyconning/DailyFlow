import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';
import '../models/task.dart';
import '../models/habit.dart';

class AIProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  
  // AI State
  Map<String, dynamic> _insights = {};
  List<Task> _prioritizedTasks = [];
  List<Map<String, dynamic>> _habitSuggestions = [];
  String _motivationalMessage = '';
  bool _isLoading = false;
  bool _isServerAvailable = false;
  List<String> _availableModels = [];

  // Getters
  Map<String, dynamic> get insights => _insights;
  List<Task> get prioritizedTasks => _prioritizedTasks;
  List<Map<String, dynamic>> get habitSuggestions => _habitSuggestions;
  String get motivationalMessage => _motivationalMessage;
  bool get isLoading => _isLoading;
  bool get isServerAvailable => _isServerAvailable;
  List<String> get availableModels => _availableModels;

  /// Initialize AI provider and check server availability
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      _isServerAvailable = await _aiService.isServerAvailable();
      if (_isServerAvailable) {
        _availableModels = await _aiService.getAvailableModels();
      }
    } catch (e) {
      print('AI Provider initialization error: $e');
      _isServerAvailable = false;
    }
    
    _setLoading(false);
    notifyListeners();
  }

  /// Generate comprehensive AI insights
  Future<void> generateInsights({
    required List<Task> tasks,
    required List<Habit> habits,
    required Map<String, dynamic> userStats,
  }) async {
    if (!_isServerAvailable) {
      _insights = {
        'insights': [
          {
            'title': 'Start Small',
            'description': 'Focus on completing 3 important tasks today to build momentum.',
            'action': 'Pick your top 3 tasks and tackle them first.',
            'type': 'productivity'
          },
          {
            'title': 'Build Consistency',
            'description': 'Your habit streaks show you\'re building good routines.',
            'action': 'Keep up the great work with your daily habits!',
            'type': 'habit'
          },
          {
            'title': 'Track Progress',
            'description': 'Monitor your completion rates to identify patterns.',
            'action': 'Review your analytics to see what\'s working best.',
            'type': 'motivation'
          }
        ],
        'priority_tasks': [],
        'motivational_message': 'You\'re making great progress! Keep up the momentum.'
      };
      notifyListeners();
      return;
    }

    _setLoading(true);
    
    try {
      _insights = await _aiService.generateInsights(
        tasks: tasks,
        habits: habits,
        userStats: userStats,
      );
    } catch (e) {
      print('Failed to generate insights: $e');
      _insights = {
        'insights': [
          {
            'title': 'Start Small',
            'description': 'Focus on completing 3 important tasks today to build momentum.',
            'action': 'Pick your top 3 tasks and tackle them first.',
            'type': 'productivity'
          },
          {
            'title': 'Build Consistency',
            'description': 'Your habit streaks show you\'re building good routines.',
            'action': 'Keep up the great work with your daily habits!',
            'type': 'habit'
          },
          {
            'title': 'Track Progress',
            'description': 'Monitor your completion rates to identify patterns.',
            'action': 'Review your analytics to see what\'s working best.',
            'type': 'motivation'
          }
        ],
        'priority_tasks': [],
        'motivational_message': 'You\'re making great progress! Keep up the momentum.'
      };
    }
    
    _setLoading(false);
    notifyListeners();
  }

  /// Prioritize tasks using AI
  Future<void> prioritizeTasks(List<Task> tasks) async {
    if (!_isServerAvailable) {
      _prioritizedTasks = tasks;
      notifyListeners();
      return;
    }

    _setLoading(true);
    
    try {
      _prioritizedTasks = await _aiService.prioritizeTasks(tasks);
    } catch (e) {
      print('Failed to prioritize tasks: $e');
      _prioritizedTasks = tasks;
    }
    
    _setLoading(false);
    notifyListeners();
  }

  /// Generate habit suggestions
  Future<void> generateHabitSuggestions({
    required List<Habit> currentHabits,
    required Map<String, dynamic> userStats,
  }) async {
    if (!_isServerAvailable) {
      _habitSuggestions = [
        {
          'title': 'Morning Routine',
          'description': 'Start your day with a consistent morning routine for better productivity.',
          'frequency': 'daily',
          'category': 'productivity',
          'difficulty': 'medium'
        },
        {
          'title': 'Evening Reflection',
          'description': 'Take 5 minutes each evening to reflect on your day and plan tomorrow.',
          'frequency': 'daily',
          'category': 'productivity',
          'difficulty': 'easy'
        }
      ];
      notifyListeners();
      return;
    }

    _setLoading(true);
    
    try {
      _habitSuggestions = await _aiService.generateHabitSuggestions(
        currentHabits: currentHabits,
        userStats: userStats,
      );
    } catch (e) {
      print('Failed to generate habit suggestions: $e');
      _habitSuggestions = [
        {
          'title': 'Morning Routine',
          'description': 'Start your day with a consistent morning routine for better productivity.',
          'frequency': 'daily',
          'category': 'productivity',
          'difficulty': 'medium'
        },
        {
          'title': 'Evening Reflection',
          'description': 'Take 5 minutes each evening to reflect on your day and plan tomorrow.',
          'frequency': 'daily',
          'category': 'productivity',
          'difficulty': 'easy'
        }
      ];
    }
    
    _setLoading(false);
    notifyListeners();
  }

  /// Generate motivational message
  Future<void> generateMotivationalMessage({
    required Map<String, dynamic> userStats,
    required List<Task> recentTasks,
    required List<Habit> recentHabits,
  }) async {
    if (!_isServerAvailable) {
      _motivationalMessage = 'You\'re doing great! Every small step counts toward your goals.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    
    try {
      _motivationalMessage = await _aiService.generateMotivationalMessage(
        userStats: userStats,
        recentTasks: recentTasks,
        recentHabits: recentHabits,
      );
    } catch (e) {
      print('Failed to generate motivational message: $e');
      _motivationalMessage = 'You\'re doing great! Every small step counts toward your goals.';
    }
    
    _setLoading(false);
    notifyListeners();
  }

  /// Refresh all AI data
  Future<void> refreshAllAI({
    required List<Task> tasks,
    required List<Habit> habits,
    required Map<String, dynamic> userStats,
  }) async {
    await Future.wait([
      generateInsights(tasks: tasks, habits: habits, userStats: userStats),
      prioritizeTasks(tasks),
      generateHabitSuggestions(currentHabits: habits, userStats: userStats),
      generateMotivationalMessage(
        userStats: userStats,
        recentTasks: tasks.take(5).toList(),
        recentHabits: habits.take(5).toList(),
      ),
    ]);
  }

  /// Check server availability
  Future<void> checkServerAvailability() async {
    _isServerAvailable = await _aiService.isServerAvailable();
    if (_isServerAvailable && _availableModels.isEmpty) {
      _availableModels = await _aiService.getAvailableModels();
    }
    notifyListeners();
  }

  /// Get insight by type
  List<Map<String, dynamic>> getInsightsByType(String type) {
    final insights = _insights['insights'] as List?;
    if (insights == null) return [];
    
    return insights
        .where((insight) => insight['type'] == type)
        .map((insight) => insight as Map<String, dynamic>)
        .toList();
  }

  /// Get productivity insights
  List<Map<String, dynamic>> getProductivityInsights() {
    return getInsightsByType('productivity');
  }

  /// Get habit insights
  List<Map<String, dynamic>> getHabitInsights() {
    return getInsightsByType('habit');
  }

  /// Get motivational insights
  List<Map<String, dynamic>> getMotivationalInsights() {
    return getInsightsByType('motivation');
  }

  /// Get task insights
  List<Map<String, dynamic>> getTaskInsights() {
    return getInsightsByType('task');
  }

  /// Get priority tasks from insights
  List<String> getPriorityTasks() {
    return List<String>.from(_insights['priority_tasks'] ?? []);
  }

  /// Clear all AI data
  void clear() {
    _insights = {};
    _prioritizedTasks = [];
    _habitSuggestions = [];
    _motivationalMessage = '';
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 